import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/quarter_goals_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
        ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent.shade100),
        useMaterial3: true,
      ),
      home: const QuartersScreen(),
    );
  }
}

class QuartersScreen extends StatefulWidget {
  const QuartersScreen({super.key});

  @override
  _QuartersScreenState createState() => _QuartersScreenState();
}

class _QuartersScreenState extends State<QuartersScreen> {
  final Color buttonBackgroundColor =
  const Color(0xFFD3E0EC); // White background for buttons
  final Color buttonTextColor = const Color(0xFF76A8C1); // Blue text color

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("img/bk.png"), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF75B3E3),
                      Color(0xFF89D1F4)
                    ], // Incision Blue Gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Quarters',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                        tooltip: "Logout",
                      ),
                    ],
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuarterButton(context,
                        'First Quarter',

                    ),
                    const SizedBox(height: 16),
                    _buildQuarterButton(context, 'Second Quarter'),
                    const SizedBox(height: 16),
                    _buildQuarterButton(context, 'Third Quarter'),
                    const SizedBox(height: 16),
                    _buildQuarterButton(context, 'Fourth Quarter'),
                    const SizedBox(height: 30),
                    Image.asset(
                      'img/logo.png', // Ensure correct path
                      height: 100,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuarterButton(BuildContext context, String title) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor, // White background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Softer edges
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 4, // Subtle shadow for depth
        ),
        onPressed: () {
          //
          String quarterId;
          if (title == 'First Quarter') {
            quarterId = 'Q1';
          } else if (title == 'Second Quarter') {
            quarterId = 'Q2';
          } else if (title == 'Third Quarter') {
            quarterId = 'Q3';
          } else {
            quarterId = 'Q4';
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuarterGoalsPage(
                quarterId: quarterId,
                quarterName: title,
              ),
            ),
          );
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: buttonTextColor, // Blue text color
          ),
        ),
      ),
    );
  }
}

class QuarterDetailScreen extends StatelessWidget {
  final String title;
  const QuarterDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0072CE),
                Color(0xFF00549E)
              ], // Incision Blue Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '$title Details',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}