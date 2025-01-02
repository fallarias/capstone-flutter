import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../variables/ip_address.dart';
import 'package:http/http.dart' as http;

class MessageNotificationScreen extends StatefulWidget {
  final String title;
  final String fullname;
  final String message;
  final String date;
  final String startTime;
  final String deadlineTime;
  final String finishTime;
  final String office;

  MessageNotificationScreen({required this.title, required this.message, required this.startTime,
                            required this.date, required this.office, required this.deadlineTime
                            , required this.finishTime, required this.fullname});

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageNotificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  final TextEditingController messageController = TextEditingController();
  bool isResuming = false; // Flag to prevent multiple clicks

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
            SizedBox(height: 10),

            // "From: (office)"
            Text(
              'From: ${widget.fullname} (${widget.office})',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 20),

            Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 20),
            // The message content
            Text(
              'Starting Time: ${widget.startTime}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Deadline Time: ${widget.deadlineTime}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              widget.finishTime != null
                  ? 'Finished Time: ${widget.finishTime}'
                  : 'Finished Time: Not available',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }


  void _showPopupForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _saveToDatabase(
                  messageController.text,
                );
                messageController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveToDatabase(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? transactionId = prefs.getString('transaction_id');
    final String? department = prefs.getString('department');
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/lack_requirement/${transactionId.toString()}/${department.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('API Response: $data');
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction already exists. Resuming transaction does not allowed.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Failed to create transaction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Something went wrong: $e');
    }
  }

  Future<void> resumeTransaction() async {
    setState(() {
      isResuming = true; // Disable the button when clicked
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? transactionId = prefs.getString('transaction_id');
    final String? department = prefs.getString('department');
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/resume_transaction/${transactionId.toString()}/${department.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('API Response: $data');
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Already resumed the transaction. Resuming transaction does not allowed.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Failed to resume transaction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Something went wrong: $e');
    } finally {
      setState(() {
        isResuming = false; // Re-enable the button after the process completes
      });
    }
  }
}

