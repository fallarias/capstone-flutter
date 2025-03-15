import 'package:flutter/material.dart';
import 'package:isu_canner/screens/office_staff/notification_Transaction.dart';
import '../screens/client/track_document.dart';
import '../screens/office_staff/transaction_history.dart';
import '../screens/client/trackDocumentHistory.dart';
import '../services/logout.dart';
import 'task_list_widget.dart';


class ClientCustomDrawer extends StatefulWidget {
  @override
  _ClientCustomDrawerState createState() => _ClientCustomDrawerState();
}

class _ClientCustomDrawerState extends State<ClientCustomDrawer> {
  // Boolean to manage the expansion state of the 'Template' section
  bool isTemplateExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF052B1D), // Original background color
              Color(0xFF052B1D),
              Color(0xFF00795E),// Additional color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 160,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF052B1D),
                    Color(0xFF052B1D),
                    Color(0xFF052B1D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Transform.translate(
                  offset: const Offset(0, 5),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/isu.png'),
                        radius: 35,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ISU-CANNER',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -7),
                            child: const Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ACTIONS section
          Container(
              margin: const EdgeInsets.only(top: 19, left: 8, right: 8, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ListTile(
              title: Text(
                'ACTIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF052B1D),
                ),
              ),
            ),
          ),
          // TEMPLATE section with a container
          Container(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.document_scanner, color: Color(0xFF052B1D)),
              title: Text(
                'AVAILABLE DOCUMENT',
                style: TextStyle(color: Color(0xFF00795E)),
              ),
              onTap: () {
                // Toggle the expansion state when the template is clicked
                setState(() {
                  isTemplateExpanded = !isTemplateExpanded;
                });
              },
            ),
          ),
          // Conditionally show the ExpansionTile for Template
          if (isTemplateExpanded)
            Container(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                leading: Icon(Icons.content_copy, color: Color(0xFF052B1D)),
                title: Text(
                  'TEMPLATE',
                  style: TextStyle(color: Color(0xFF00795E)),
                ),
                children: <Widget>[
                  TaskListWidget(),  // The content of your expansion
                ],
              ),
            ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ExpansionTile(
              leading: Icon(Icons.track_changes, color: Color(0xFF052B1D)),
              title: Text(
                'TRACK DOCUMENT',
                style: TextStyle(color: Color(0xFF00795E)),
              ),
              children: <Widget>[
                TrackDocument(),
              ],
            ),
          ),
          // TRANSACTION HISTORY ListTile with a container
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.history, color: Color(0xFF052B1D)),
              title: Text(
                'TRANSACTION HISTORY',
                style: TextStyle(color: Color(0xFF00795E)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryScreen(),
                  ),
                );
              },
            ),
          ),
          // Other sections such as Track Document, Notification, etc.
        ],
      ),
    ),
    );
  }
}








class StaffCustomDrawer extends StatelessWidget {
  const StaffCustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF052B1D), // Original background color
              Color(0xFF052B1D),
              Color(0xFF00795E),// Additional color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 160,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF052B1D),
                    Color(0xFF052B1D),
                    Color(0xFF052B1D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Transform.translate(
                  offset: const Offset(0, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/isu.png'),
                        radius: 35,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ISU-CANNER',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -7),
                            child: const Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Notification section with a container
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.notifications_active_sharp, color: Color(0xFF052B1D)),
              title: const Text(
                'NOTIFICATION',
                style: TextStyle(color: Color(0xFF00795E), fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationTransaction(),
                  ),
                );
              },
            ),
          ),
          // Transaction history section with a container
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.history, color: Color(0xFF052B1D)),
              title: const Text(
                'TRANSACTION HISTORY',
                style: TextStyle(color: Color(0xFF00795E)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionHistory(),
                  ),
                );
              },
            ),
          ),
          // Template section with dropdown
          // Logout section
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF052B1D)),
              title: const Text(
                'LOG OUT',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                await logout(context);
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
