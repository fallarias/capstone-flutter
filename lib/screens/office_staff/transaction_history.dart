import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl package
import 'package:shared_preferences/shared_preferences.dart';
import '../../variables/ip_address.dart'; // Your IP address
import 'messageScreen.dart';
import 'office_message.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  State<TransactionHistory> createState() => TransactionHistoryPage();
}

class TransactionHistoryPage extends State<TransactionHistory> {
  List<Map<String, dynamic>> scan = []; // To store the notifications as maps
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkForScanUpdates();
  }

  Future<void> _checkForScanUpdates() async {
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

    // Adding detailed logs for debugging
    print('User ID: $userId');
    print('Token: $token');
    print('Department: $department');

    final response = await http.get(
      Uri.parse('$ipaddress/staff_scanned_history/${department.toString()}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          isLoading = false;
          scan = data.cast<Map<String, dynamic>>(); // Cast the list to a list of maps
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error parsing the data: $e';
        });
        print('Error parsing the response body: $e');
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'API request failed with status code: ${response.statusCode}';
      });
      print('API request failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.green, // Adjust color as per your theme
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Loading state
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(child: Text(errorMessage))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey, width: 1),
                    columnWidths: const {
                      0: FractionColumnWidth(0.2), // ID No.
                      1: FractionColumnWidth(0.5), // Transaction Name
                      2: FractionColumnWidth(0.3), // Date
                    },
                    children: [
                      // Table Header
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'ID No.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Transaction Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Table Rows (Data)
                      ...scan.map(
                            (transaction) {
                          // Format the date using intl package
                          String formattedDate = '';
                          try {
                            DateTime date = DateTime.parse(transaction['finished']);
                            formattedDate = DateFormat('yyyy-MM-dd h:mm a').format(date);
                          } catch (e) {
                            formattedDate = 'Invalid Date';
                          }

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['transaction_id'].toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['task'] ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  formattedDate,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
