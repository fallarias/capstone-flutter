import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl package
import 'package:shared_preferences/shared_preferences.dart';
import '../../variables/ip_address.dart';
import 'messageScreen.dart';

class NotificationTransaction extends StatefulWidget {
  @override
  State<NotificationTransaction> createState() => _NotificationTransaction();
}

class _NotificationTransaction extends State<NotificationTransaction> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
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
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        notifications = data
            .where((task) => task['office_name'] == department)
            .toList();
        isLoading = false;
      });
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
      appBar: AppBar(title: Text('Messages')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty && errorMessage.isEmpty
          ? Center(child: Text('No notifications available.'))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final title = "Transaction No.  " + notification['transaction_id'].toString();
          final office = notification['office_name'] ?? 'Unknown';
          // Format start and deadline times with AM/PM
          final startTime = formatDateTime(notification['start'] ?? '');
          final deadlineTime = formatDateTime(notification['deadline'] ?? '');

          final message = 'The new transaction starting at $startTime and the deadline at $deadlineTime';
          final date = notification['created_at'] ?? 'Today';

          return GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('transaction_id', notification['transaction_id'].toString());
              await prefs.setString('audit_id', notification['audit_id'].toString());
              // Navigate to the MessageDetailScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageDetailScreen(
                    title: title,
                    message: message,
                    date: date,
                    office: office,
                  ),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                message,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                date,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
