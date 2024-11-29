import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:isu_canner/screens/home_screen.dart';
import 'package:isu_canner/services/logout.dart';
import 'package:isu_canner/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../style/custom_app_bar.dart';
import '../../style/custom_drawer.dart';
import '../../variables/ip_address.dart';
import '../client/welcome_popUp.dart';
import '../office_staff/qr_scanner.dart';
import 'package:http/http.dart' as http;

class StaffHomepage extends StatefulWidget {
  final User user;

  const StaffHomepage({super.key, required this.user});

  @override
  State<StaffHomepage> createState() => _StaffHomepageState();
}

class _StaffHomepageState extends State<StaffHomepage> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  List<String> officeList = [];
  String? selectedTo;

  @override
  void initState() {
    super.initState();
    _fetchAllOffice();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomePopup();
    });
    
    print("Calling _fetchAllOffice...");

  }

  void _showWelcomePopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WelcomePopup(user: widget.user);
      },
    );
  }


  Widget _buildStatusContainer(String title, String count, {double verticalOffset = -30.0}) {
    return Flexible(
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 40.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.greenAccent.shade100,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start horizontally
            mainAxisAlignment: MainAxisAlignment.start, // Align content to the top vertically
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start, // Align text within its container to the start
              ),
              SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.start, // Align text within its container to the start
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaChart({double verticalOffset = -50.0}) {
    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.8, // Adjusted aspect ratio for a slightly compressed fit
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20, // Adjust interval as needed
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10), // Smaller font size for Y-axis labels
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return Text('Mon', style: TextStyle(fontSize: 10));
                        case 1:
                          return Text('Tue', style: TextStyle(fontSize: 10));
                        case 2:
                          return Text('Wed', style: TextStyle(fontSize: 10));
                        case 3:
                          return Text('Thu', style: TextStyle(fontSize: 10));
                        case 4:
                          return Text('Fri', style: TextStyle(fontSize: 10));
                        case 5:
                          return Text('Sat', style: TextStyle(fontSize: 10));
                        case 6:
                          return Text('Sun', style: TextStyle(fontSize: 10));
                        default:
                          return Text('');
                      }
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 100, // Set Y-axis to range from 0 to 100
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, 10),
                    FlSpot(1, 30),
                    FlSpot(2, 20),
                    FlSpot(3, 50),
                    FlSpot(4, 40),
                    FlSpot(5, 60),
                    FlSpot(6, 30),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.3)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StatusCounts>(
      future: fetchStatusCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final statusCounts = snapshot.data!;
          return Scaffold(
            appBar: StaffCustomAppBar(),
            drawer: StaffCustomDrawer(),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 5.0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatusContainer("Pending", statusCounts.pending),
                          _buildStatusContainer("Task Completed", statusCounts.completed),
                        ],
                      ),
                      _buildAreaChart(),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () => _showPopupForm(context), // Wrap in a lambda function
                          child: const Text('Send Message'),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerPage(),
                  ),
                );

                if (result != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Scanned QR Code"),
                      content: Text(result),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              backgroundColor: Colors.grey,
              elevation: 4.0,
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 50.0,
              ),
            ),
          );
        } else {
          return const Center(child: Text("No data available"));
        }
      },
    );
  }

  Future<void> _fetchAllOffice() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final String? department = prefs.getString('department');
    print('Fetching office list...');

    final response = await http.get(
      Uri.parse('$ipaddress/all_office/${department.toString()}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        officeList = data.cast<String>();
      });
      print(response.body);
    } else {
      print('Failed to load office list: ${response.statusCode} ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
      setState(() {
        officeList = [];
      });
    }
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
              DropdownButtonFormField<String>(
                value: selectedTo,
                items: officeList.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTo = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'To:'),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message:'),
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
                if (selectedTo != null) {
                  await _saveToDatabase(
                    selectedTo!,
                    messageController.text,
                  );
                  // Clear the controllers after submission
                  messageController.clear();

                  Navigator.of(context).pop();
                } else {
                  // Handle validation if no option is selected
                  print('Please select an option');
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveToDatabase(String to, String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String? department = prefs.getString('department');
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/message_office/${department.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'message': message,
          'target_department': to,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('API Response: $data');

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

}



class StatusCounts {
  final String pending;
  final String completed;


  StatusCounts({
    required this.pending,
    required this.completed,

  });

  factory StatusCounts.fromJson(Map<String, dynamic> json) {
    return StatusCounts(
      pending: json['pending'].toString(),
      completed: json['completed'].toString(),

    );
  }
}

Future<StatusCounts> fetchStatusCounts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getInt('userId').toString();
  String? token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('$ipaddress/staff_chart/${userId.toString()}'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return StatusCounts.fromJson(json.decode(response.body));
  } else {
    print('Failed to load data: ${response.statusCode} ${response.body}');
    throw Exception('Failed to load status counts');
  }
}
