import 'package:flutter/material.dart';
import 'laundry_page.dart';
import 'dry_cleaning_page.dart';
import 'ironing_page.dart';
import 'login_page.dart'; // Ensure you have a LoginPage for the redirection
import 'notification_page.dart'; // Import NotificationPage
import 'order_status_page.dart'; // Import the OrderStatusPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
        backgroundColor: Colors.blueAccent,
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
          ),
          // Order Status Icon (Navigating to OrderStatusPage)
          IconButton(
            icon: const Icon(Icons.list_alt, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderStatusPage()),
              );
            },
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.exit_to_app, size: 30),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Categories
              ServiceCategories(),
              SizedBox(height: 20),
              // Latest Orders/Status
              LatestOrders(),
              SizedBox(height: 20),
              // Offers Section
              OffersSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCategories extends StatelessWidget {
  const ServiceCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a Service',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 10),
        ServiceCard(
          serviceName: 'Laundry',
          icon: Icons.local_laundry_service,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LaundryPage()),
            );
          },
        ),
        ServiceCard(
          serviceName: 'Dry Cleaning',
          icon: Icons.cleaning_services,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DryCleaningPage()),
            );
          },
        ),
        ServiceCard(
          serviceName: 'Ironing',
          icon: Icons.iron,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const IroningPage()),
            );
          },
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String serviceName;
  final IconData icon;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.serviceName,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blueAccent,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(serviceName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        onTap: onTap,
      ),
    );
  }
}

class LatestOrders extends StatelessWidget {
  const LatestOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 10),
          Text('You have no recent orders at the moment.'),
        ],
      ),
    );
  }
}

class OffersSection extends StatelessWidget {
  const OffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Offers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 10),
          Text('No current offers at the moment. Stay tuned!'),
        ],
      ),
    );
  }
}
