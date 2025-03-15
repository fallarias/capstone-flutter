import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/background_widget.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Row containing the images
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/isu.png', width: 90, height: 90),
                    const SizedBox(width: 90),
                    Image.asset('assets/images/ict.png', width: 100, height: 100),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'ISU - CANNER',
                  style: GoogleFonts.zillaSlab(
                    textStyle: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Document Monitoring and Tracking System',
                  style: GoogleFonts.zillaSlab(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFF00A87E), // Change text color here
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Container(
                  height: 5,
                  width: 320,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFF00A87E), // Change text color here
                    ),
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

