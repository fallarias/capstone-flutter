import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../office_staff/refresh_notifier.dart';
import '../../variables/ip_address.dart';
import 'package:http/http.dart' as http;

class MessageDetailScreen extends StatefulWidget {
  final String title;
  final String task;
  final String date;
  final String office;
  final String start;
  final String deadline;

  MessageDetailScreen({required this.title, required this.task, required this.date,
                      required this.office, required this.start, required this.deadline});

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
  bool isStopFinished = false;

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
    resetStateForNewMessage();
    _listenForTaskStatusChanges();
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
        backgroundColor: Color(0xFF052B1D), // Change background color
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white), // Add back arrow icon
          onPressed: () {
            // Define what happens when the back button is pressed
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
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
              'To: ${widget.office}',
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
              'Task: ${widget.task}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Starting Time: ${widget.start}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Deadline Time: ${widget.deadline}',
              style: TextStyle(fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150.0),
              child: Center(
                child: FadeTransition(
                  opacity: _opacity,
                  child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isStopFinished || canResume
                                    ? Colors.grey
                                    : Color(0xFF052B1D),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: isStopFinished
                                  ? null
                                  : () {
                                _showPopupForm(context);
                              },
                              child: const Text('Stop Transaction'),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canResume && !isResuming
                                    ? Colors.grey // Disabled state: grey
                                    : Color(0xFF052B1D), // Normal state: dark green
                                foregroundColor: Colors.white, // White text color
                              ),
                              onPressed: canResume && !isResuming
                                  ? () {
                                resumeTransaction();
                                setState(() {
                                  canResume = false;
                                  isTaskFinished = true;
                                });
                              }
                                  : null, // Disable button if condition is true
                              child: const Text('Resume Transaction'),
                            ),
                          ),


                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (canResume || isTaskFinished)
                                    ? Colors.grey
                                    : Color(0xFF052B1D),
                                foregroundColor: Colors.white, // Ensures text color is white
                                disabledBackgroundColor: Colors.grey,
                                disabledForegroundColor: Colors.white, // White text even when disabled
                              ),
                              onPressed: (canResume || isTaskFinished)
                                  ? null
                                  : () => _showConfirmationDialog(context),
                              child: const Text('Finish Task'),
                            ),
                          ),

                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF052B1D),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: resetTaskStatus,
                              child: const Text('Reset Task Status'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
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
                await _saveToDatabase(messageController.text);
                messageController.clear();
                Navigator.of(context).pop();

                setState(() {
                  canResume = true; // Enable Resume Transaction button
                  isTaskFinished = true; // Stop Transaction now considered as in-progress
                });
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
    String? auditId = prefs.getString('audit_id');
    String userId = prefs.getInt('userId').toString();
    final String? department = prefs.getString('department');
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/lack_requirement/${transactionId.toString()}/${department.toString()}'
            '/${userId.toString()}'),
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

        await saveTaskStatus(finished: false, resume: true, stop: true); // Save consistent states

        setState(() {
          canResume = true; // Enable Resume Transaction button
          isTaskFinished = false; // Ensure task is not marked finished
          isStopFinished = true; // Mark Stop Transaction as finished
        });
        // Save that stop transaction is finished
        await prefs.setBool('isStopFinished_$auditId', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message saved successfully.'),
            duration: Duration(seconds: 3),
          ),
        );
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
      isResuming = true; // Disable the Resume button while processing
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? transactionId = prefs.getString('transaction_id');
    String? auditId = prefs.getString('audit_id');
    String userId = prefs.getInt('userId').toString();
    final String? department = prefs.getString('department');

    try {
      final response = await http.post(
        Uri.parse('$ipaddress/resume_transaction/${transactionId.toString()}/${department.toString()}'
            '/${userId.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('API Response: $data');

        await saveTaskStatus(finished: false, resume: false, stop: true);
        // Save that stop transaction is finished
        await prefs.setBool('isStopFinished_$auditId', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task Resume Successfully.'),
            duration: Duration(seconds: 3),
          ),
        );

      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction already resumed. Resuming not allowed.'),
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
        isResuming = false; // Re-enable Resume button after processing
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
    String userId = prefs.getInt('userId').toString();
    final String? department = prefs.getString('department');

    // Log the values for debugging
    print('Token: $token');
    print('Transaction ID: $transactionId');
    print('Audit ID: $auditId');
    print('Department: $department');

    try {
      final response = await http.post(
        Uri.parse('$ipaddress/finish_transaction/${transactionId.toString()}/${department.toString()}'
                  '/${auditId.toString()}/${userId.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Mark the task as finished
        await saveTaskStatus(finished: true, resume: false, stop: true);
        // Save that stop transaction is finished
        await prefs.setBool('isStopFinished_$auditId', true);
         if (mounted) {
           setState(() {
             isTaskFinished = true; // Disable Finish Task button
             isStopFinished = true; // Disable Stop Transaction button
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

    // Get all keys in SharedPreferences
    Set<String> keys = prefs.getKeys();

    // Identify and remove all keys related to audit tasks
    for (String key in keys) {
      if (key.startsWith('isTaskFinished_') || key.startsWith('canResume_') || key.startsWith('isStopFinished_')) {
        await prefs.remove(key);
      }
    }

    // Reset state variables
    setState(() {
      isTaskFinished = false; // Re-enable Stop Transaction
      canResume = false; // Disable Resume Transaction
      isStopFinished = false; // Disable Stop Transaction button
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All task statuses have been reset.'),
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
                refreshNotifier.value = true;
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
    String? auditId = prefs.getString('audit_id');

    if (auditId != null) {
      setState(() {
        isTaskFinished = prefs.getBool('isTaskFinished_$auditId') ?? false;
        canResume = prefs.getBool('canResume_$auditId') ?? false;
        isStopFinished = prefs.getBool('isStopFinished_$auditId') ?? false;
      });
      print('Task Status - Finished: $isTaskFinished, Resume: $canResume, Stop: $isStopFinished');
    } else {
      print('Audit ID is null, cannot load task status.');
    }
  }


  Future<void> saveTaskStatus({required bool finished, required bool resume, required bool stop}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? auditId = prefs.getString('audit_id'); // Unique identifier for the task

    if (auditId != null) {
      await prefs.setBool('isTaskFinished_$auditId', finished);
      await prefs.setBool('canResume_$auditId', resume);
      await prefs.setBool('isStopFinished_$auditId', stop);
    }

    setState(() {
      isTaskFinished = finished;
      canResume = resume;
      isStopFinished = stop;
    });
    print('Task Status - Finished: $isTaskFinished, Resume: $canResume, Stop: $isStopFinished');
  }


  void resetStateForNewMessage() {
    // Call this only for a new task, not during navigation back.
    setState(() {
      isTaskFinished = false;
      canResume = false;
      isStopFinished = false;
    });
  }


  void _listenForTaskStatusChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? auditId = prefs.getString('audit_id');

    Timer.periodic(const Duration(seconds: 10), (timer) async {
      bool? storedTaskFinished = prefs.getBool('isTaskFinished_$auditId') ?? false;
      bool? storedCanResume = prefs.getBool('canResume_$auditId') ?? false;
      bool? storedStopFinished = prefs.getBool('isStopFinished_$auditId') ?? false;

      if (mounted) {
        setState(() {
          // Only update the state if the stored values differ from the current ones
          if (isTaskFinished != storedTaskFinished) {
            isTaskFinished = storedTaskFinished;
          }
          if (canResume != storedCanResume) {
            canResume = storedCanResume;
          }
          if (isStopFinished != storedStopFinished) {
            isStopFinished = storedStopFinished;
          }
        });
      }
    });
  }


}

