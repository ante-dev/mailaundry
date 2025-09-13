import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core dependency
import 'package:flutter/foundation.dart'; // For kIsWeb check
import 'login_page.dart'; // Import the login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for web and mobile
  await _initializeFirebase();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAoyhjr80DyjoE5zP7Yg_TYyH7okipGKiU",
        authDomain: "laundry-app-775bb.firebaseapp.com",
        projectId: "laundry-app-775bb",
        storageBucket: "laundry-app-775bb.appspot.com", // Fixed potential typo in storageBucket
        messagingSenderId: "488446909033",
        appId: "1:488446909033:web:0902d20820a71c67df60f8",
        measurementId: "G-YKTZQPWKS3",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App',
      debugShowCheckedModeBanner: false, // Removes the debug banner for cleaner UI
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity, // Platform-adaptive visuals
      ),
      home: LoginScreen(), // Set the initial screen to LoginScreen
    );
  }
}
