import 'package:flutter/material.dart';
import 'package:isu_canner/screens/office_staff/notification_Transaction.dart';
import '../screens/client/track_document.dart';
import '../services/logout.dart';
import 'task_list_widget.dart';

class ClientCustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Set the background color of the drawer to green
      backgroundColor: Colors.green,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 160,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade900, // No const here, as it's not allowed
                    Colors.green,
                    Colors.lightGreen,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: SingleChildScrollView(
                child: Transform.translate(
                  offset: const Offset(0, 15),
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
          // Wrapping ListTile in a Container for styling
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white, // Background color for the ListTile container
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: const Text(
                'ACTIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          // TEMPLATE section with a container
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ExpansionTile(
              leading: Icon(Icons.content_copy, color: Colors.green),
              title: Text(
                'TEMPLATE',
                style: TextStyle(color: Colors.green),
              ),
              children: <Widget>[
                TaskListWidget(),
              ],
            ),
          ),
          // TRACK DOCUMENT section with a container
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ExpansionTile(
              leading: Icon(Icons.track_changes, color: Colors.green),
              title: Text(
                'TRACK DOCUMENT',
                style: TextStyle(color: Colors.green),
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
              leading: Icon(Icons.history, color: Colors.green),
              title: Text(
                'TRANSACTION HISTORY',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () {
                // Handle tap here
              },
            ),
          ),
          // Add more ListTiles for other drawer options as needed
        ],
      ),
    );
  }
}







class StaffCustomDrawer extends StatelessWidget {
  const StaffCustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.green,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 160,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade900,
                    Colors.green,
                    Colors.lightGreen,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Transform.translate(
                  offset: const Offset(0, -20),
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
              leading: Icon(Icons.notifications_active_sharp, color: Colors.green),
              title: const Text(
                'NOTIFICATION',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
              leading: Icon(Icons.history, color: Colors.green),
              title: const Text(
                'TRANSACTION HISTORY',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () {
                // Handle the tap here
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
              leading: Icon(Icons.logout, color: Colors.red),
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
    );
  }
}
