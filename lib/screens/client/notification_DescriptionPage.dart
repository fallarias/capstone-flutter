import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../variables/ip_address.dart';
import 'LackRequirements.dart';
import 'MessageUnreadRead.dart';

class NotificationDescriptionPage extends StatefulWidget {
  @override
  State<NotificationDescriptionPage> createState() => _NotificationDescriptionPageState();
}

class _NotificationDescriptionPageState extends State<NotificationDescriptionPage> {
  List<dynamic> notifications = [];
  List<dynamic> messages = [];
  List<dynamic> unfinished = [];
  List<dynamic> displayList = [];
  bool isLoading = true;
  String errorMessage = '';
  int unreadItems = 0;
  Set<int> readItems = {};

  @override
  void initState() {
    super.initState();
    _loadReadItems();
    _checkForUpdates();
  }

  Future<void> _loadReadItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final readItemsString = prefs.getString('readItems') ?? '';
    setState(() {
      readItems = Set<int>.from(jsonDecode(readItemsString).cast<int>());
    });
  }

  Future<void> _saveReadItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('readItems', jsonEncode(readItems.toList()));
  }

  Future<void> _checkForUpdates() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String userId = prefs.getInt('userId')?.toString() ?? '';

    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'User ID not found.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$ipaddress/notifications/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Data: $data');
        setState(() {
          notifications = (data['finishedAudits'] as List)
              .where((task) => task['finished'] != null && task['finished'] is String)
              .map((task) {
                return {
                  ...task,
                  'user': task['user'] ?? {}, // Include the 'user' relationship
                };
              })
              .toList();
          unfinished = (data['UnfinishedAudits'] as List)
              .where((unfinish) => unfinish['finished'] == null)
              .map((unfinish) {
                return {
                  ...unfinish,
                  'user': unfinish['user'] ?? {}, // Include the 'user' relationship
                };
              })
              .toList();
          messages = (data['messages'] as List)
              .where((stop) => stop['message'] != null && stop['department'] is String)
              .map((stop) {
                return {
                  ...stop,
                  'user': stop['user'] ?? {}, // Include the 'user' relationship
                };
              })
              .toList();

          print('Unfinished Audits: ${data['UnfinishedAudits']}');

          displayList = [...notifications, ...unfinished];
          print(displayList);
          unreadItems = (messages.length + notifications.length) - readItems.length;
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = response.statusCode == 404
              ? 'No Current Notifications'
              : 'Error fetching notifications: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Invalid date';
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final DateFormat formatter = DateFormat('hh:mm a');
      return formatter.format(parsedDate);
    } catch (e) {
      print('Error parsing date in formatDateTime: $dateTime - Error: $e'); // Debug log
      return 'Invalid date';
    }
  }

  String formatDate(String? dateTime) {
    if (dateTime == null) return 'Invalid date';
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final DateFormat formatter = DateFormat('MMM dd, yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      print('Error parsing date in formatDateTime: $dateTime - Error: $e'); // Debug log
      return 'Invalid date';
    }
  }

  // Renamed second function to avoid conflict
  String formatDateForDisplay(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Invalid Date';
    try {
      print("Parsing date in formatDateForDisplay: $dateTime"); // Debug log
      final DateTime parsedDate = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(parsedDate);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays <= 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(parsedDate);
      }
    } catch (e) {
      print('Error parsing date in formatDateForDisplay: $dateTime - Error: $e'); // Debug log
      return 'Invalid date'; // Return a clearer message
    }
  }

  void _onMessageTap(dynamic message, int index) {
    final int messageId = index;

    if (!readItems.contains(messageId)) {
      setState(() {
        unreadItems--;
        readItems.add(messageId);
        _saveReadItems();
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LackRequirementsScreen(
          title: "Transaction No.  " + message['transaction_id'].toString(),
          startTime: formatDateTime(message['start']) + ", " + formatDate(message['start']),
          deadlineTime: formatDateTime(message['deadline'] ?? '')+ ", " + formatDate(message['deadline']),
          finishTime: formatDateTime(message['finished'] ?? '') + ", " + formatDate(message['finished']),
          fullname: message['user']['lastname'] + ', ' + message['user']['firstname'],
          message: message['message'] ?? 'No message', // Fallback if message is null
          date: formatDateForDisplay(message['created_at']) ?? 'Today', // Fallback if date is null
          office: message['department'],
        ),
      ),
    );
  }

  void _onNotificationTap(dynamic notification, int index) {
    final int notificationId = index + messages.length;

    if (!readItems.contains(notificationId)) {
      setState(() {
        unreadItems--;
        readItems.add(notificationId);
        _saveReadItems();
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageNotificationScreen(
          title: "Transaction No.  " + notification['transaction_id'].toString(),
          fullname: notification['user']['lastname'] + ', ' + notification['user']['firstname'],
          startTime: formatDateTime(notification['start']) + ", " + formatDate(notification['start']),
          deadlineTime: formatDateTime(notification['deadline'] ?? '') + ", " + formatDate(notification['deadline']),
          finishTime: notification['finished'] != null
              ? formatDateTime(notification['finished']) + ", " + formatDate(notification['finished'])
              : 'not',
          message: 'Transaction starting at ${formatDateTime(notification['start'])} with a deadline of ${formatDateTime(notification['deadline'])}',
          date: formatDateForDisplay(notification['created_at']) ?? 'Today', // Fallback if date is null
          office: notification['office_name'],

        ),
      ),
    );
  }

  Widget buildMessageTile(dynamic message, int index) {
    final date = formatDateForDisplay(message['created_at']);
    final officeName = "Transaction No.  " + message['transaction_id'].toString();
    return GestureDetector(
      onTap: () => _onMessageTap(message, index),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.message, color: Colors.white),
        ),
        title: Text(officeName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Lack of Requirements', overflow: TextOverflow.ellipsis),
        trailing: Text(date, style: TextStyle(color: Colors.grey)),
        tileColor: readItems.contains(index) ? Colors.white : Colors.grey[300],
      ),
    );
  }

  Widget buildNotificationTile(dynamic notification, int index) {
    final date = formatDateForDisplay(notification['created_at']);
    final officeName = "Transaction No.  " + notification['transaction_id'].toString();
    return GestureDetector(
      onTap: () => _onNotificationTap(notification, index),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(officeName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('New Message', overflow: TextOverflow.ellipsis),
        trailing: Text(date, style: TextStyle(color: Colors.grey)),
        tileColor: readItems.contains(index + messages.length) ? Colors.white : Colors.grey[300],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Message  ', // First part of the message
                style: TextStyle(fontSize: 26, color: Colors.black), // Default style
                children: [
                  TextSpan(
                    text: '(', // Closing parenthesis
                    style: TextStyle(fontSize: 16, color: Colors.black), // Default style for closing parenthesis
                  ),
                  TextSpan(
                    text: unreadItems > 0 ? '$unreadItems unread messages' : 'No unread messages', // Text inside parentheses
                    style: TextStyle(fontSize: 16, color: Colors.red), // Red color for the text inside parentheses
                  ),
                  TextSpan(
                    text: ')', // Closing parenthesis
                    style: TextStyle(fontSize: 16, color: Colors.black), // Default style for closing parenthesis
                  ),
                ],
              ),
            ),
          ],


        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (displayList.isEmpty && messages.isEmpty && errorMessage.isEmpty)
          ? Center(child: Text('No notifications available.'))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: messages.length + displayList.length,
        itemBuilder: (context, index) {
          final reversedIndex =
              (messages.length + displayList.length) - index - 1;

          if (reversedIndex < messages.length) {
            final message = messages[reversedIndex];
            return buildMessageTile(message, reversedIndex);
          } else {
            final notificationIndex =
                reversedIndex - messages.length;
            final notification = displayList[notificationIndex];
            return buildNotificationTile(notification, notificationIndex);
          }
        },
      ),
    );
  }
}
