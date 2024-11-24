import 'package:flutter/material.dart';
import '../../model/user.dart';

class WelcomePopup extends StatelessWidget {
  final User user;

  const WelcomePopup({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xff0f965e),
                  Color(0xff00f83a),
                  Color(0xff6aff8c),
                  Color(0xff00f83a),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Must be white for the gradient to show
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${user.firstname} ${user.lastname}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'User ID: ${user.id}\nEmail: ',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  TextSpan(
                    text: user.email,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),

          ],
        ),
      ),
    );
  }
}
