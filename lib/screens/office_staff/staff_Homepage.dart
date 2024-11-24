import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:isu_canner/screens/home_screen.dart';
import 'package:isu_canner/services/logout.dart';
import 'package:isu_canner/model/user.dart';
import '../../style/custom_app_bar.dart';
import '../../style/custom_drawer.dart';
import '../client/welcome_popUp.dart';
import '../office_staff/qr_scanner.dart';

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
                  fontSize: 40,
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
          child: SingleChildScrollView( // Allow scrolling
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 5.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatusContainer("9", "Pending"),
                    _buildStatusContainer("2", "Task completed"),

                    // Add more containers as needed
                  ],
                ),
                _buildAreaChart(), // Change this line

              ],
            ),
          ),
        ),
      ),



      floatingActionButton: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: FloatingActionButton(
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
          shape: const CircleBorder(),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            size: 50.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 35),
              onPressed: () {
                // Handle home press
              },
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.person, size: 35),
              onPressed: () async {
                await logout(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return HomeScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
