import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IroningPage extends StatefulWidget {
  const IroningPage({Key? key}) : super(key: key);

  @override
  State<IroningPage> createState() => _IroningPageState();
}

class _IroningPageState extends State<IroningPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _calculatedPrice = 0.0;
  final double _ratePerKg = 80.0; // Updated rate for ironing per kg in KSh
  bool _expressService = false;
  bool _readyForPickup = false;  // New field for ready for pickup status

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
        // Generate a unique orderId using Firestore's document ID
        String orderId = FirebaseFirestore.instance.collection('ironing_bookings').doc().id;

        // Save booking data to Firestore
        await FirebaseFirestore.instance.collection('ironing_bookings').doc(orderId).set({
          'orderId': orderId,  // Add orderId
          'name': _nameController.text,
          'phone': _phoneController.text,
          'date': _dateController.text,
          'address': _addressController.text,
          'weight': double.tryParse(_weightController.text),
          'price': _calculatedPrice,
          'expressService': _expressService,
          'readyForPickup': _readyForPickup,  // Save the "Ready for Pickup" status
          ''
              '': FieldValue.serverTimestamp(),
          'status': 'Pending',  // Added status field
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ironing booked! Total: KSh ${_calculatedPrice.toStringAsFixed(2)}')),
        );

        // Reset the form
        _formKey.currentState!.reset();
        _nameController.clear();
        _phoneController.clear();
        _dateController.clear();
        _addressController.clear();
        _weightController.clear();
        setState(() {
          _expressService = false;
          _readyForPickup = false;  // Reset the "Ready for Pickup" status
          _calculatedPrice = 0.0;
        });
      } catch (e) {
        // Handle Firestore errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking ironing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ironing Service Booking'),
        backgroundColor: Colors.deepOrange, // Custom color for consistency
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Ironing Service Booking',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepOrange),
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
              _buildTextFormField(_weightController, 'Weight (kg)', TextInputType.number, onChanged: (value) => _calculatePrice()),
              const SizedBox(height: 15),
              _buildPriceDisplay(),
              const SizedBox(height: 15),
              _buildExpressServiceSwitch(),
              const SizedBox(height: 15),
              _buildReadyForPickupSwitch(),  // New switch for "Ready for Pickup"
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build text form fields
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

  // Helper to build the date field
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

  // Helper to display price
  Widget _buildPriceDisplay() {
    return Text(
      'Price: KSh ${_calculatedPrice.toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
    );
  }

  // Helper to build express service switch
  Widget _buildExpressServiceSwitch() {
    return SwitchListTile(
      title: const Text('Express Service'),
      subtitle: const Text('Get your ironing done faster (Extra charges may apply)'),
      value: _expressService,
      onChanged: (value) {
        setState(() {
          _expressService = value;
        });
      },
    );
  }

  // Helper to build ready for pickup switch
  Widget _buildReadyForPickupSwitch() {
    return SwitchListTile(
      title: const Text('Ready for Pickup'),
      subtitle: const Text('Indicate if the ironing is ready for pickup'),
      value: _readyForPickup,
      onChanged: (value) {
        setState(() {
          _readyForPickup = value;
        });
      },
    );
  }

  // Helper to build the submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitBooking,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Submit Booking', style: TextStyle(fontSize: 16)),
    );
  }
}
