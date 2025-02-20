import 'package:flutter/material.dart';
import 'package:isu_canner/screens/client/ratingPage.dart';
import 'package:isu_canner/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/client/client_Homepage.dart';
import '../screens/office_staff/staff_Homepage.dart';
import '../model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  Widget? initialPage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String accountType = prefs.getString('account_type') ?? '';

    if (loggedIn) {
      // Fetch user data and determine which page to show based on account type
      final user = await getUserFromPreferences();
      setState(() {
        isLoggedIn = true;
        switch (accountType) {
          case 'office staff':
            initialPage = StaffHomepage(user: user);
            break;
          case 'client':
            initialPage = ClientHomepage(user: user);
            break;
          default:
            initialPage = const HomeScreen(); 
        }
      });
    } else {
      setState(() {
        isLoggedIn = false;
        initialPage = HomeScreen();
      });
    }
  }

  Future<User> getUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId') ?? 0;
    final email = prefs.getString('email') ?? '';
    final firstname = prefs.getString('firstname') ?? '';
    final lastname = prefs.getString('lastname') ?? '';
    final token = prefs.getString('token') ?? '';
    final accountType = prefs.getString('account_type') ?? '';

    return User(
      id: id,
      email: email,
      firstname: firstname,
      lastname: lastname,
      token: token,
      account_type: accountType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.green,
          selectionColor: Colors.greenAccent,
          selectionHandleColor: Colors.green,
        ),
      ),
      home: initialPage ?? const Center(child: CircularProgressIndicator()),
    );
  }
}
