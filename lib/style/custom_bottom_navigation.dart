import 'package:flutter/material.dart';

class ClientCustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool hasUnreadNotifications; // Add this field

  const ClientCustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.hasUnreadNotifications = false, // Default is false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Has unread notifications: $hasUnreadNotifications'); // Debug line
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 50, // Customize the icon size
            height: 30,
            child: const Icon(Icons.home, size: 30),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              SizedBox(
                width: 30, // Customize the icon size
                height: 30,
                child: const Icon(Icons.notifications, size: 30),
              ),
              if (hasUnreadNotifications) // Show dot only if there are unread notifications
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10, // Adjust the size of the dot
                    height: 10, // Adjust the size of the dot
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 30, // Customize the icon size
            height: 30,
            child: const Icon(Icons.logout, size: 30),
          ),
          label: 'Logout',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green, // Change this to your desired color
      onTap: onItemTapped, // Handle item tap
    );
  }
}
