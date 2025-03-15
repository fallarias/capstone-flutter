import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl package
import 'package:shared_preferences/shared_preferences.dart';
import '../../variables/ip_address.dart';
import 'messageScreen.dart';
import 'office_message.dart';

class NotificationTransaction extends StatefulWidget {
  @override
  State<NotificationTransaction> createState() =>
      _NotificationTransactionState();
}

class _NotificationTransactionState extends State<NotificationTransaction>
    with SingleTickerProviderStateMixin {
  List<dynamic> notifications = [];
  List<dynamic> messages = [];
  bool isLoading = true;
  String errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkForUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? department = prefs.getString('department');
    String userId = prefs.getInt('userId')?.toString() ?? '';

    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'User ID not found.';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('$ipaddress/staff_notification/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> transactions = data['transactions'] ?? [];
      final List<dynamic> message = data['message'] ?? [];

      // Save data in SharedPreferences
      await prefs.setString('notifications', json.encode(transactions));
      await prefs.setString('messages', json.encode(message));

      setState(() {
        notifications = transactions
            .where((task) => task['office_name'] == department && task['staff_id'].toString() == userId)
            .toList();
        messages = message
            .where((task) => task['target_department'] == department)
            .toList();
        isLoading = false;
      });

      // Notify MessageDetailScreen if there are new messages
      if (notifications.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? auditId = prefs.getString('audit_id');

        if (auditId != null) {
          bool? isFinished = prefs.getBool('isTaskFinished_$auditId');
          if (isFinished == null) {
            // Set default values only if no state exists
            await prefs.setBool('isTaskFinished_$auditId', false);
            await prefs.setBool('canResume_$auditId', false);
            await prefs.setBool('isStopFinished_$auditId', false);
          }
        }
      }

    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'No Current Notifications';
      });
    }
  }

  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final DateFormat formatter = DateFormat('hh:mm a'); // Format to 'hh:mm AM/PM'
      return formatter.format(parsedDate);
    } catch (e) {
      return dateTime; // If parsing fails, return the original string
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF052B1D),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 15,), // Change to any icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),// Change background color
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white), // Change title text color
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Change selected tab text color
          unselectedLabelColor: Colors.white70, // Optional: Change unselected tab text color
          indicatorColor: Colors.white, // Optional: Change indicator color
          tabs: const [
            Tab(text: 'Transaction Messages'),
            Tab(text: 'Office Messages'),
          ],
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(),
          _buildMessageList(),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }
    if (notifications.isEmpty) {
      return Center(child: Text('No notifications available.'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final title =
            "Transaction No. " + notification['transaction_id'].toString();
        final office = notification['office_name'] ?? 'Unknown';
        final startTime = formatDateTime(notification['start'] ?? '');
        final deadlineTime = formatDateTime(notification['deadline'] ?? '');
        final task = notification['task'] ?? '';
        final date = formatDateTime(notification['start'] ?? 'Today');

        return GestureDetector(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'transaction_id', notification['transaction_id'].toString());
            await prefs.setString(
                'audit_id', notification['audit_id'].toString());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessageDetailScreen(
                  title: title,
                  task: task,
                  date: date,
                  office: office,
                  start: startTime,
                  deadline: deadlineTime,
                ),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF052B1D),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              task,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              date,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }
    if (messages.isEmpty) {
      return Center(child: Text('No messages available.'));
    }

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final title = message['department'] ?? 'No Title';
        final target_department = message['target_department'] ?? 'Unknown Department';
        final department = message['department'] ?? 'Unknown Department';
        final messageText = message['message'] ?? 'No Message';
        final sentTime = formatDateTime(message['start'] ?? 'Today');
        final names = message['user']['email'] ?? 'no name';

        return GestureDetector(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('message_id', message['id'].toString());
            await prefs.setString('department', department);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessageOfficeScreen(
                  title: title,
                  target_office: target_department,
                  office: department,
                  message: messageText,
                  date: sentTime,
                  name: names,
                ),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[300],
              child: Icon(Icons.message, color: Colors.white),
            ),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              messageText,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              sentTime,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
