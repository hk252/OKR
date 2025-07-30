import 'package:flutter/material.dart';
import 'package:project/Screen1.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) =>  Screen1()),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF37B6BF), // Set to match the icon's color
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // color: Colors.blueGrey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              SizedBox(height: 120,),

              Container(
                child: Column(
                  children: [
                    Image.asset(
                      'img/icon.png',
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 30,),
                    Text("OKR's App",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25, color: Colors.white),),

                    SizedBox(height: 120,),

                    TextButton(
                      onPressed: () {
                        // Navigate to the next screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Screen1()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white, // Match the background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded edges
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70), // Padding for size
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.blueGrey, // White text color
                          fontSize: 18, // Larger font size for readability
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
