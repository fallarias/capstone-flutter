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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // GlobalKey for Scaffold

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
    _chartData = fetchChartData();
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
            body: SingleChildScrollView( // Add SingleChildScrollView here
              child: Column(
                children: [
                  // Add the text at the top of the dashboard
                  Transform.translate(
                    offset: Offset(0, 22.0), // Move 12.0 pixels down along the Y-axis
                    child: Padding(
                      padding: const EdgeInsets.all(6.0), // Add some padding around the text
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

                  SizedBox(
                    height: 200,
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true, // Set shrinkWrap to true
                      physics: NeverScrollableScrollPhysics(), // Prevent scrolling inside GridView
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
                      shrinkWrap: true, // Set shrinkWrap to true
                      physics: NeverScrollableScrollPhysics(), // Prevent scrolling inside GridView
                      children: [
                        _Row2StatusContainer(statusCounts.pendingDocuments, "Pending"),
                        _Row2StatusContainer(statusCounts.completeDocuments, "Complete"),
                      ],
                    ),
                  ),
                  _buildBarChart(),
                ],
              ),
            ),
          );
        }
      },
    );
  }



  void _openDrawerAndShowTemplate() {
    // Open the drawer programmatically
    _scaffoldKey.currentState?.openDrawer();
    // Trigger dropdown for the template
    _showTemplateDropdown();
  }

  void _showTemplateDropdown() {
    setState(() {
      // Example flag to open dropdown if applicable
    });
  }

  Widget _Row1StatusContainer(String title, String count, {double verticalOffset = 10.0}) {
    return Flexible(
      child: InkWell(
        onTap: () {
          // Handle the click here
          if (title == "Available Document") {
            // Open the drawer first
            Scaffold.of(context).openDrawer();
          } else if (title == "Message") {
            // Handle other actions for "Message"
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
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
                  fontSize: 40,
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
    );
  }

  Widget _Row2StatusContainer(String title, String count, {double verticalOffset = -40.0}) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          // Handle the click here
          if (title == "Pending") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrackDocument(), // Navigate to TrackDocument page
              ),
            );
          } else if (title == "Complete") {
            // Handle other actions for "Complete"
          }
        },
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
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
                    fontSize: 40,
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
      key: _scaffoldKey, // Set the GlobalKey here
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
      ),
    );
  }
  late Future<ChartData> _chartData;

  Future<ChartData> fetchChartData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String userId = prefs.getInt('userId')?.toString() ?? '';

    final response = await http.get(
      Uri.parse('$ipaddress/bar_chart/${userId.toString()}'),
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