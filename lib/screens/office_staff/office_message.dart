
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessageOfficeScreen extends StatefulWidget {
  final String title;
  final String office;
  final String target_office;
  final String message;
  final String date;
  final String name;

  MessageOfficeScreen({required this.title, required this.message, required this.date,
                      required this.office, required this.target_office, required this.name});

  @override
  _MessageOfficeScreenState createState() => _MessageOfficeScreenState();
}

class _MessageOfficeScreenState extends State<MessageOfficeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  final TextEditingController messageController = TextEditingController();
  bool isResuming = false; // Flag to prevent multiple clicks
  bool canResume = false;
  bool isFinishing = false;
  bool isTaskFinished = false;
  bool isStopFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )
      ..forward();
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date or 'Today'
            Text(
              widget.date,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              'From: ${widget.name}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 30),
            // The message content
            Text(
              widget.message,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}