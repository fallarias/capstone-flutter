import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../variables/ip_address.dart';
import 'package:http/http.dart' as http;

class MessageDetailScreen extends StatefulWidget {
  final String title;
  final String message;
  final String date;
  final String office;

  MessageDetailScreen({required this.title, required this.message, required this.date, required this.office});

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  final TextEditingController messageController = TextEditingController();
  bool isResuming = false; // Flag to prevent multiple clicks
  bool canResume = false;
  bool isFinishing = false;
  bool isTaskFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    checkResumeTransaction();
    loadTaskStatus();
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
            SizedBox(height: 10),

            // "From: (office)"
            Text(
              'From: ${widget.office}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 20),

            Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            // The message content
            Text(
              widget.message,
              style: TextStyle(fontSize: 16),
            ),
            Center(
              child: FadeTransition(
                opacity: _opacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTaskFinished ? Colors.grey : Colors.blue, // Grey if disabled
                          disabledBackgroundColor: Colors.grey,
                        ),
                        onPressed: isTaskFinished ? null : () => _showPopupForm(context),
                        child: const Text('Stop Transaction'),
                      ),
                    ),
                    SizedBox(height: 10), // Add spacing between buttons
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canResume ? Colors.blue : Colors.grey, // Change button color based on state
                          disabledBackgroundColor: Colors.grey, // Optional: Set the disabled color
                        ),
                        onPressed: canResume && !isResuming ? resumeTransaction : null, // Disable button if cannot resume or is already resuming
                        child: const Text('Resume Transaction'),
                      ),
                    ),
                    SizedBox(height: 10), // Add spacing between buttons
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (canResume || isTaskFinished) ? Colors.grey : Colors.blue,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        onPressed: (canResume || isTaskFinished) ? null : () => _showConfirmationDialog(context),
                        child: const Text('Finish Task'),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: resetTaskStatus,
                        child: const Text('Reset Task Status'),
                      ),
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

  Future<void> checkResumeTransaction() async {
    setState(() {
      isResuming = true; // Disable the button when clicked
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? transactionId = prefs.getString('transaction_id');
    final String? department = prefs.getString('department');
    try {
      final response = await http.get(
        Uri.parse('$ipaddress/check_resume_transaction/${transactionId
            .toString()}/${department.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('API Response: $data');

        // Update the canResume flag based on the response
        setState(() {
          canResume = data['can_resume'];
        });

        // // Optionally show a message if already resumed
        // if (!canResume) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //           'Already resumed the transaction. Resuming transaction is not allowed.'),
        //       duration: Duration(seconds: 3),
        //     ),
        //   );
        // }
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

  Future<void> finishTransaction() async {
    if (!mounted) return; // Ensure the widget is still mounted before updating state

    setState(() {
      isFinishing = true; // Disable the button temporarily when clicked
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? transactionId = prefs.getString('transaction_id');
    String? auditId = prefs.getString('audit_id');
    final String? department = prefs.getString('department');

    // Log the values for debugging
    print('Token: $token');
    print('Transaction ID: $transactionId');
    print('Audit ID: $auditId');
    print('Department: $department');

    try {
      final response = await http.post(
        Uri.parse('$ipaddress/finish_transaction/${transactionId.toString()}/${department.toString()}'
                  '/${auditId.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Mark the task as finished
        await prefs.setBool('isTaskFinished', true);
        if (mounted) {
          setState(() {
            isTaskFinished = true;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The Task is set to finished.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Failed to finish transaction. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to finish the task. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Something went wrong: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isFinishing = false; // Re-enable the button temporarily
        });
      }
    }
  }

  Future<void> resetTaskStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTaskFinished', false);
    setState(() {
      isTaskFinished = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task status has been reset to not finished.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    if (!mounted) return; // Make sure the widget is still mounted

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to finish the task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                if (mounted) finishTransaction(); // Ensure finishTransaction is called only if the widget is still mounted
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadTaskStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTaskFinished = prefs.getBool('isTaskFinished') ?? false;
    });
  }

}

