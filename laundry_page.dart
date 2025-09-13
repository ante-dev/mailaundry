import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaundryPage extends StatefulWidget {
  const LaundryPage({Key? key}) : super(key: key);

  @override
  State<LaundryPage> createState() => _LaundryPageState();
}

class _LaundryPageState extends State<LaundryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _calculatedPrice = 0.0;
  final double _ratePerKg = 80.0; // Laundry rate per kg in KSh
  bool _expressService = false;
  bool _readyForPickup = false; // Field for "Ready for Pickup" status

  void _calculatePrice() {
    if (_weightController.text.isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      if (weight != null && weight > 0) {
        setState(() {
          _calculatedPrice = weight * _ratePerKg;
        });
      } else {
        setState(() {
          _calculatedPrice = 0.0;
        });
      }
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate a unique document reference
        DocumentReference docRef =
        FirebaseFirestore.instance.collection('laundry_bookings').doc();

        // Use Firestore's generated ID as the `orderId`
        String orderId = docRef.id;

        // Save booking data to Firestore
        await docRef.set({
          'orderId': orderId, // Store orderId
          'name': _nameController.text,
          'phone': _phoneController.text,
          'date': _dateController.text,
          'address': _addressController.text,
          'weight': double.tryParse(_weightController.text),
          'price': _calculatedPrice,
          'expressService': _expressService,
          'readyForPickup': _readyForPickup,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'Pending',
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laundry booked! Order ID: $orderId')),
        );

        // Reset the form
        _resetForm();
      } catch (e) {
        // Handle Firestore errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking laundry: $e')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _phoneController.clear();
    _dateController.clear();
    _addressController.clear();
    _weightController.clear();
    setState(() {
      _expressService = false;
      _readyForPickup = false;
      _calculatedPrice = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Service Booking'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Laundry Service Booking',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(_nameController, 'Full Name', TextInputType.name),
              const SizedBox(height: 15),
              _buildTextFormField(_phoneController, 'Phone Number', TextInputType.phone),
              const SizedBox(height: 15),
              _buildDateField(),
              const SizedBox(height: 15),
              _buildTextFormField(_addressController, 'Pickup Address', TextInputType.text, maxLines: 2),
              const SizedBox(height: 15),
              _buildTextFormField(_weightController, 'Weight (kg)', TextInputType.number,
                  onChanged: (value) => _calculatePrice()),
              const SizedBox(height: 15),
              _buildPriceDisplay(),
              const SizedBox(height: 15),
              _buildExpressServiceSwitch(),
              const SizedBox(height: 15),
              _buildReadyForPickupSwitch(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, TextInputType inputType,
      {int maxLines = 1, Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      keyboardType: inputType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (inputType == TextInputType.number && double.tryParse(value) == null) {
          return 'Please enter a valid $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Service Date',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
            }
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildPriceDisplay() {
    return Text(
      'Price: KSh ${_calculatedPrice.toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
    );
  }

  Widget _buildExpressServiceSwitch() {
    return SwitchListTile(
      title: const Text('Express Service'),
      subtitle: const Text('Get your laundry done faster (Extra charges may apply)'),
      value: _expressService,
      onChanged: (value) {
        setState(() {
          _expressService = value;
        });
      },
    );
  }

  Widget _buildReadyForPickupSwitch() {
    return SwitchListTile(
      title: const Text('Ready for Pickup'),
      subtitle: const Text('Indicate if the laundry is ready for pickup'),
      value: _readyForPickup,
      onChanged: (value) {
        setState(() {
          _readyForPickup = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitBooking,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Submit Booking', style: TextStyle(fontSize: 16)),
    );
  }
}
