
import 'package:flutter/material.dart';

class ClientCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final ValueChanged<bool> onSearchToggle;

  const ClientCustomAppBar({
    super.key,
    required this.isSearching,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon:const Icon(Icons.menu, size: 27,color: Colors.white,),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer directly
            },
          );
        },
      ),
      title: isSearching
          ? const TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8.0),
        ),
      )
          : const Row(
        children: [
          Icon(
            Icons.person,
            size:20.0,
            color: Color(0xFF00A87E),
          ),
          SizedBox(width: 8.0),
          Text(
            'CLIENT PORTAL',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF00A87E),), // Adjusted the font size for better alignment
          ),

        ],
      ),
      backgroundColor: Color(0xFF052B1D),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search,size: 30,color: Colors.yellow,),
          onPressed: () {
            onSearchToggle(!isSearching);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}



class SupplierCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final ValueChanged<bool> onSearchToggle;

  const SupplierCustomAppBar({
    super.key,
    required this.isSearching,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon:const Icon(Icons.menu, size: 40),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer directly
            },
          );
        },
      ),
      title: isSearching
          ?const TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8.0),
        ),
      )
          :const Row(
        children: [
          Icon(
            Icons.group,
            size:34.0,
          ),
          SizedBox(width: 8.0),
          Text('Supplier Portal'),
        ],
      ),
      backgroundColor: Colors.green,
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            onSearchToggle(!isSearching);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>const Size.fromHeight(kToolbarHeight);
}









class StaffCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StaffCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF052B1D), // First color
            Color(0xFF052B1D),  // Second color
            Color(0xFF00A87E), // Third color
          ],
          begin: Alignment.topLeft, // Start of the gradient
          end: Alignment.bottomRight, // End of the gradient
        ),
      ),
      child: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, size: 30,color: Colors.white,), // Adjusted the size to be more reasonable
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
        title: const Row(
          children: [
            Icon(
              Icons.manage_accounts,
              size: 25.0,
              color: Colors.yellow,// Adjusted size for the icon
            ),
            SizedBox(width: 8.0),
            Text(
              'Staff Portal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.yellow,), // Adjusted the font size for better alignment
            ),
          ],
        ),
        backgroundColor: Colors.transparent, // Make the AppBar background transparent
        actions: const [
          // You can add more action icons here if needed
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

