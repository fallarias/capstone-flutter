import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:isu_canner/screens/client/track_document.dart';
import 'package:isu_canner/screens/client/welcome_popUp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../style/custom_app_bar.dart';
import '../../style/custom_bottom_navigation.dart';
import '../../style/custom_drawer.dart';
import '../../style/menu_page.dart';
import '../../model/user.dart';
import '../../services/logout.dart';
import '../../variables/ip_address.dart';
import 'notification_DescriptionPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientHomepage extends StatefulWidget {
  final User user;

  const ClientHomepage({super.key, required this.user});

  @override
  State<ClientHomepage> createState() => _ClientHomepageState();
}

class _ClientHomepageState extends State<ClientHomepage> {
  bool _isSearching = false;
  int _selectedIndex = 0;
  int notificationCount = 0; // Variable to store unread notification count
  bool hasUnreadNotifications = true; // Initially true for testing

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _buildHomePage(),
      _buildNotificationPage(),
      _buildMenuPage(),
    ]);

    // Fetch unread notifications when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUnreadNotificationCount();
      _showWelcomePopup(); // Show popup after login
    });
  }



  void _fetchUnreadNotificationCount() async {
    // This is just an example; replace with actual API call or database query
    int fetchedCount = await fetchUnreadNotificationsFromDataSource();
    setState(() {
      notificationCount = fetchedCount; // Update the notification count
    });
  }

  Future<int> fetchUnreadNotificationsFromDataSource() async {
    // Mock function; replace with your actual notification fetch logic
    // Example: fetch count from a database or API
    await Future.delayed(Duration(seconds: 1)); // Simulating network delay
    return 2; // Replace with actual fetched count
  }


  void _showWelcomePopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WelcomePopup(user: widget.user); // Show WelcomePopup widget
      },
    );
  }

  Widget _buildHomePage() {
    return FutureBuilder<StatusCounts>(
      future: fetchStatusCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading data"));
        } else {
          final statusCounts = snapshot.data!;
          return Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: [
                      _Row1StatusContainer(statusCounts.availableDocuments, "Available Document"),
                      _Row1StatusContainer(statusCounts.messages, "Message"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: [
                      _Row2StatusContainer(statusCounts.pendingDocuments, "Pending"),
                      _Row2StatusContainer(statusCounts.completeDocuments, "Complete"),
                    ],
                  ),
                ),
                _buildAreaChart(),
              ],
            ),
          );
        }
      },
    );
  }







  Widget _Row1StatusContainer(String title, String count, {double verticalOffset = -30.0}) {
    return Flexible(
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Container(
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



  Widget _Row2StatusContainer(String title, String count, {double verticalOffset = -110.0}) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          if (title == "Pending") { // Check if the specific container is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrackDocument(), // Navigate to TrackDocument page
              ),
            );
          }
        },
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Container(
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
      ),
    );
  }



  Widget _buildAreaChart({double verticalOffset = -150.0}) {
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
          aspectRatio: 1.7, // Adjusted aspect ratio for a slightly compressed fit
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


  Widget _buildNotificationPage() {
    return Column(
      children: [
        Expanded(
          child: NotificationDescriptionPage(),
        ),
      ],
    );
  }

  Widget _buildMenuPage() {
    return MenuPage(
      onLogoutSelected: () async {
        await logout(context);
      },
    );
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Reset notification count when the Notifications tab is opened
      setState(() {
        notificationCount = 0;
        _selectedIndex = index;
        if (index == 1) {
          hasUnreadNotifications = false; // Mark as read when Notifications is tapped
        }

      });
    } else if (index == 2) { // Check if MenuPage is selected
      await logout(context); // Direct logout
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClientCustomAppBar(
        isSearching: _isSearching,
        onSearchToggle: (isSearching) {
          setState(() {
            _isSearching = isSearching;
          });
        },
      ),
      drawer: ClientCustomDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClientCustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        hasUnreadNotifications: hasUnreadNotifications,
        //notificationCount: notificationCount,
      ),
    );
  }
}
class StatusCounts {
  final String availableDocuments;
  final String messages;
  final String pendingDocuments;
  final String completeDocuments;

  StatusCounts({
    required this.availableDocuments,
    required this.messages,
    required this.pendingDocuments,
    required this.completeDocuments,
  });

  factory StatusCounts.fromJson(Map<String, dynamic> json) {
    return StatusCounts(
      availableDocuments: json['availableDocuments'].toString(),
      messages: json['messages'].toString(),
      pendingDocuments: json['pendingDocuments'].toString(),
      completeDocuments: json['completeDocuments'].toString(),
    );
  }
}

Future<StatusCounts> fetchStatusCounts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getInt('userId').toString();
  String? token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('$ipaddress/client_chart/${userId.toString()}'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return StatusCounts.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load status counts');
  }
}