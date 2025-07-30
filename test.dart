import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Logs out the user
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Screen"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Calls the logout function
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hello!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),


          ],
        ),
      ),
    );
  }
}
