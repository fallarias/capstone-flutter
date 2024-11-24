import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../variables/ip_address.dart';
import 'MessageUnreadRead.dart';

class NotificationDescriptionPage extends StatefulWidget {
  @override
  State<NotificationDescriptionPage> createState() => _NotificationDescriptionPageState();
}

class _NotificationDescriptionPageState extends State<NotificationDescriptionPage> {
  List<dynamic> notifications = [];
  List<dynamic> messages = [];
  List<dynamic> unfinished = [];
  bool isLoading = true;
  String errorMessage = '';
  int unreadItems = 0;
  Set<int> readItems = {};

  @override
  void initState() {
    super.initState();
    _loadReadItems();
    _checkForUpdates();
    _loadCachedUnfinished();
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

  Future<void> _loadCachedUnfinished() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedUnfinishedString = prefs.getString('cachedUnfinished') ?? '[]';
    setState(() {
      unfinished = jsonDecode(cachedUnfinishedString);
    });
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

        // Retrieve the locally cached unfinished items
        final cachedUnfinishedString = prefs.getString('cachedUnfinished') ?? '[]';
        final List<dynamic> cachedUnfinished = jsonDecode(cachedUnfinishedString);

        // Parse new unfinished items from the response
        final List<dynamic> newUnfinished = (data['UnfinishedAudits'] as List)
            .where((unfinish) => unfinish['finished'] == null && unfinish['start'] != null)
            .toList();

        // Merge the cached and new unfinished items
        final mergedUnfinished = [...cachedUnfinished, ...newUnfinished];

        // Remove duplicates based on a unique identifier, e.g., transaction_id
        final uniqueUnfinished = {for (var item in mergedUnfinished) item['transaction_id']: item}.values.toList();

        // Save the updated unfinished list to SharedPreferences
        await prefs.setString('cachedUnfinished', jsonEncode(uniqueUnfinished));

        setState(() {
          notifications = (data['finishedAudits'] as List)
              .where((task) => task['finished'] != null && task['finished'] is String)
              .toList();
          messages = (data['messages'] as List)
              .where((stop) => stop['message'] != null && stop['department'] is String)
              .toList();
          unfinished = uniqueUnfinished;
          unreadItems = (messages.length + notifications.length + unfinished.length) - readItems.length;
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
        builder: (context) => MessageNotificationScreen(
          title: 'Kulang na requirements',
          message: message['message'] ?? 'No message', // Fallback if message is null
          date: message['created_at'] ?? 'Today', // Fallback if date is null
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
          message: 'Transaction starting at ${formatDateTime(notification['start'])} with a deadline of ${formatDateTime(notification['deadline'])}',
          date: notification['created_at'] ?? 'Today', // Fallback if date is null
          office: notification['office_name'],
        ),
      ),
    );
  }

  void _onUnfinishNotificationTap(dynamic unFinish, int index) {
    final int unFinishId = index + unfinished.length;

    if (!readItems.contains(unFinishId)) {
      setState(() {
        unreadItems--;
        readItems.add(unFinishId);
        _saveReadItems();
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageNotificationScreen(
          title: "Transaction No.  " + unFinish['transaction_id'].toString(),
          message: 'Transaction starting at ${formatDateTime(unFinish['start'])} with a deadline of ${formatDateTime(unFinish['deadline'])}',
          date: unFinish['created_at'] ?? 'Today', // Fallback if date is null
          office: unFinish['office_name'],
        ),
      ),
    );
  }

  Widget buildMessageTile(dynamic message, int index) {
    final date = formatDateForDisplay(message['created_at']);
    final officeName = "Transaction No.  " + message['transaction_id'].toString();
    final req = 'Lack Requirement';

    return GestureDetector(
      onTap: () => _onMessageTap(message, index),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.message, color: Colors.white),
        ),
        title: Text(officeName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(req, overflow: TextOverflow.ellipsis),
        trailing: Text(date, style: TextStyle(color: Colors.grey)),
        tileColor: readItems.contains(index) ? Colors.white : Colors.grey[300],
      ),
    );
  }

  Widget buildNotificationTile(dynamic notification, int index) {
    final date = formatDateForDisplay(notification['created_at']);
    final officeName = "Transaction No.  " + notification['transaction_id'].toString();
    final message = 'New Message';
    return GestureDetector(
      onTap: () => _onNotificationTap(notification, index),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(officeName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message, overflow: TextOverflow.ellipsis),
        trailing: Text(date, style: TextStyle(color: Colors.grey)),
        tileColor: readItems.contains(index + messages.length) ? Colors.white : Colors.grey[300],
      ),
    );
  }

  Widget buildUnfinishedTile(dynamic unfinishedItem, int index) {
    final date = formatDateForDisplay(unfinishedItem['created_at']);
    final startTime = formatDateTime(unfinishedItem['start']);
    final message = 'New Update';//'Unfinished audit started at $startTime.';
    final officeName = "Transaction No.  " + unfinishedItem['transaction_id'].toString();

    return GestureDetector(
      onTap: () => _onUnfinishNotificationTap(unfinishedItem, index),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(officeName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message, overflow: TextOverflow.ellipsis),
        trailing: Text(date, style: TextStyle(color: Colors.grey)),
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
          : (notifications.isEmpty && messages.isEmpty && errorMessage.isEmpty)
          ? Center(child: Text('No notifications available.'))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
                itemCount: messages.length + notifications.length + unfinished.length,
                itemBuilder: (context, index) {
                  final reversedIndex = (messages.length + notifications.length + unfinished.length) - index - 1;

                  if (reversedIndex < messages.length) {
                    // Handle messages
                    final message = messages[reversedIndex];
                    return buildMessageTile(message, reversedIndex);
                  } else if (reversedIndex < messages.length + notifications.length) {
                    // Handle notifications
                    final notificationIndex = reversedIndex - messages.length;
                    final notification = notifications[notificationIndex];
                    return buildNotificationTile(notification, notificationIndex);
                  } else {
                    // Handle unfinished audits
                    final unfinishedIndex = reversedIndex - messages.length - notifications.length;
                    final unfinishedItem = unfinished[unfinishedIndex];
                    return buildUnfinishedTile(unfinishedItem, unfinishedIndex);
                }
          },
      ),
    );
  }
}
