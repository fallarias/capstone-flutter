import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:isu_canner/screens/office_staff/transaction_history.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomePopup();
    });
    _chartData = fetchChartData();
  }

  void _showWelcomePopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasShownPopup = prefs.getBool('hasShownPopup') ?? false;

    if (!hasShownPopup) {
      // Show the welcome popup
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return WelcomePopup(user: widget.user);
        },
      );

      // Set flag to true after showing the popup
      await prefs.setBool('hasShownPopup', true);
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
              TextField(
                controller: toController,
                decoration: const InputDecoration(labelText: 'To'),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'ID'),
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
                  toController.text,
                  messageController.text,
                  idController.text,
                );
                // Clear the controllers after submission
                toController.clear();
                messageController.clear();
                idController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveToDatabase(String to, String message, String id) async {
    // Add database code here, e.g., using Firebase Firestore:
    /*
    await FirebaseFirestore.instance.collection('messages').add({
      'to': to,
      'message': message,
      'id': id,
      'timestamp': FieldValue.serverTimestamp(),
    });
    */
  }

  Widget _buildStatusContainer(String title, String count, {double verticalOffset = -30.0}) {
    return Flexible(
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: GestureDetector(
          onTap: () {
            // Action to be performed when tapped
            print('Status container tapped: $title');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionHistory(),
              ),
            );
          },
          child: Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 40.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade100,
              borderRadius: BorderRadius.circular(15),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart({double verticalOffset = -80.0}) {
    return FutureBuilder<ChartData>(
      future: _chartData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data!;
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
              child: Column(
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'My Request',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // Chart
                  AspectRatio(
                    aspectRatio: 1.8,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < data.days.length) {
                                  return Text(
                                    data.days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }
                                return Text('');
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
                        barGroups: List.generate(
                          data.values.length,
                              (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: data.values[index],
                                color: Colors.blue,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: data.values.reduce((a, b) => a > b ? a : b),
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Transform.translate(
                    offset: Offset(0, 22.0), // Move 22.0 pixels down along the Y-axis
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0), // Add padding around the text
                        child: Text(
                          'Dashboard', // Your title text here
                          style: TextStyle(
                            fontSize: 24, // Customize font size
                            fontWeight: FontWeight.bold, // Make it bold
                            color: Colors.black, // Customize color
                          ),
                        ),
                      ),
                    ),

                  ),

                  // Content Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Add padding around content
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Status Grid
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

                            // Area Chart
                            SizedBox(height: 16.0), // Add spacing before the chart
                            _buildBarChart(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 6.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, size: 30),
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => StaffHomepage(user: widget.user)),
                      );
                    },
                  ),

                  const SizedBox(width: 48), // Space for the FAB
                  IconButton(
                    icon: const Icon(Icons.logout, size: 30,),
                    color: Colors.green,
                    onPressed: () async {
                      await logout(context);
                    },
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: ClipOval(
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QRScannerPage()),
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
                backgroundColor: Colors.green,
                elevation: 6.0,
                child: const Icon(Icons.qr_code_scanner_rounded, size: 38.0),
              ),
            ),

          );
        } else {
          return const Center(child: Text("No data available"));
        }
      },
    );
  }



  late Future<ChartData> _chartData;

  Future<ChartData> fetchChartData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? department = prefs.getString('department');

    final response = await http.get(
      Uri.parse('$ipaddress/line_chart/${department.toString()}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ChartData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load chart data');
    }
  }

}
class ChartData {
  final List<String> days;
  final List<double> values;

  ChartData({required this.days, required this.values});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      days: List<String>.from(json['days']),
      values: List<double>.from(json['values'].map((value) => value.toDouble())),
    );
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

  print('UserId: $userId');
  print('Token: $token');
  print('URL: $ipaddress/staff_chart/${userId.toString()}');

  if (response.statusCode == 200) {
    return StatusCounts.fromJson(json.decode(response.body));
  } else {
    print('Failed to load data: ${response.statusCode} ${response.body}');
    throw Exception('Failed to load status counts');
  }
}


