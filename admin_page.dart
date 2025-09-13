import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();

  // Fetch order suggestions based on user input
  Future<List<String>> _fetchOrderSuggestions(String query) async {
    List<String> suggestions = [];

    // Fetch all order documents and filter by query
    try {
      QuerySnapshot ironingBookings = await _firestore.collection('ironing_bookings').get();
      QuerySnapshot laundryBookings = await _firestore.collection('laundry_bookings').get();
      QuerySnapshot dryCleaningBookings = await _firestore.collection('dry_cleaning_bookings').get();

      // Combine and filter all order IDs based on the query
      suggestions.addAll(
        ironingBookings.docs
            .map((doc) => doc.id)
            .where((id) => id.contains(query)),
      );
      suggestions.addAll(
        laundryBookings.docs
            .map((doc) => doc.id)
            .where((id) => id.contains(query)),
      );
      suggestions.addAll(
        dryCleaningBookings.docs
            .map((doc) => doc.id)
            .where((id) => id.contains(query)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching order suggestions: $e')),
      );
    }

    return suggestions.toSet().toList(); // Remove duplicates
  }

  Future<void> _selectPickupDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        _pickupDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _schedulePickup(String orderId) async {
    if (_pickupDateController.text.isNotEmpty) {
      try {
        DateTime pickupDate = DateTime.parse(_pickupDateController.text);

        DocumentSnapshot ironingDoc = await _firestore.collection('ironing_bookings').doc(orderId).get();
        DocumentSnapshot laundryDoc = await _firestore.collection('laundry_bookings').doc(orderId).get();
        DocumentSnapshot dryCleaningDoc = await _firestore.collection('dry_cleaning_bookings').doc(orderId).get();

        if (!ironingDoc.exists && !laundryDoc.exists && !dryCleaningDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order not found!')),
          );
          return;
        }

        if (ironingDoc.exists) {
          await _firestore.collection('ironing_bookings').doc(orderId).update({
            'pickupScheduled': pickupDate.toIso8601String(),
            'status': 'Ready for Pickup',
          });
        } else if (laundryDoc.exists) {
          await _firestore.collection('laundry_bookings').doc(orderId).update({
            'pickupScheduled': pickupDate.toIso8601String(),
            'status': 'Ready for Pickup',
          });
        } else if (dryCleaningDoc.exists) {
          await _firestore.collection('dry_cleaning_bookings').doc(orderId).update({
            'pickupScheduled': pickupDate.toIso8601String(),
            'status': 'Ready for Pickup',
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pickup scheduled for order $orderId')),
        );

        _pickupDateController.clear();
        _orderIdController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scheduling pickup: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid pickup date')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    try {
      QuerySnapshot ironingBookings = await _firestore.collection('ironing_bookings').get();
      QuerySnapshot laundryBookings = await _firestore.collection('laundry_bookings').get();
      QuerySnapshot dryCleaningBookings = await _firestore.collection('dry_cleaning_bookings').get();

      List<Map<String, dynamic>> allBookings = [];
      allBookings.addAll(ironingBookings.docs.map((doc) => doc.data() as Map<String, dynamic>));
      allBookings.addAll(laundryBookings.docs.map((doc) => doc.data() as Map<String, dynamic>));
      allBookings.addAll(dryCleaningBookings.docs.map((doc) => doc.data() as Map<String, dynamic>));

      return allBookings;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings: $e')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Manage Bookings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Autocomplete widget for Order ID
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return await _fetchOrderSuggestions(textEditingValue.text);
              },
              onSelected: (String selection) {
                _orderIdController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Order ID',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _selectPickupDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _pickupDateController,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _schedulePickup(_orderIdController.text),
              child: const Text('Schedule Pickup'),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No bookings found.'));
                  } else {
                    List<Map<String, dynamic>> bookings = snapshot.data!;
                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        var booking = bookings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Order ID: ${booking['orderId']}'),
                            subtitle: Text(
                                'Name: ${booking['name']}\nStatus: ${booking['status']}'),
                            trailing: booking['status'] == 'Ready for Pickup'
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
