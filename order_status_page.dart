import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Dashboard'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 30),
            onPressed: () {
              // Navigate to the notification page
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(child: OrderStatusPage()),
          ],
        ),
      ),
    );
  }
}

class OrderStatusPage extends StatelessWidget {
  const OrderStatusPage({super.key});

  Stream<List<Order>> getOrdersFromFirestore() {
    return Stream.fromFuture(Future.wait([
      FirebaseFirestore.instance.collection('laundry_bookings').get(),
      FirebaseFirestore.instance.collection('dry_cleaning_bookings').get(),
      FirebaseFirestore.instance.collection('ironing_bookings').get(),
    ])).map((queries) {
      List<Order> orders = [];
      orders.addAll(queries[0].docs.map((doc) => Order.fromFirestore(doc.data(), 'Laundry')));
      orders.addAll(queries[1].docs.map((doc) => Order.fromFirestore(doc.data(), 'Dry Cleaning')));
      orders.addAll(queries[2].docs.map((doc) => Order.fromFirestore(doc.data(), 'Ironing')));
      return orders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: getOrdersFromFirestore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading orders'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  'No orders found.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return OrderCard(order: orders[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  Future<void> _deleteOrder(String orderId, String service, BuildContext context) async {
    try {
      if (service == 'Laundry') {
        await FirebaseFirestore.instance.collection('laundry_bookings').doc(orderId).delete();
      } else if (service == 'Dry Cleaning') {
        await FirebaseFirestore.instance.collection('dry_cleaning_bookings').doc(orderId).delete();
      } else if (service == 'Ironing') {
        await FirebaseFirestore.instance.collection('ironing_bookings').doc(orderId).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.indigo.shade200,
          child: Icon(order.icon, color: Colors.white),
        ),
        title: Text(
          order.orderId,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Service: ${order.service}\nStatus: ${order.status}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              order.status == 'Ready for Pickup'
                  ? Icons.check_circle
                  : Icons.access_time,
              color: order.status == 'Ready for Pickup' ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteOrder(order.orderId, order.service, context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Order {
  final String orderId;
  final String status;
  final String service;
  final IconData icon;

  Order({
    required this.orderId,
    required this.status,
    required this.service,
    required this.icon,
  });

  factory Order.fromFirestore(Map<String, dynamic> data, String service) {
    return Order(
      orderId: data['orderId'] ?? 'Unknown Order',
      status: data['status'] ?? 'Pending',
      service: service,
      icon: getServiceIcon(service),
    );
  }

  static IconData getServiceIcon(String service) {
    switch (service) {
      case 'Laundry':
        return Icons.local_laundry_service;
      case 'Ironing':
        return Icons.iron;
      case 'Dry Cleaning':
        return Icons.cleaning_services;
      default:
        return Icons.help;
    }
  }
}
