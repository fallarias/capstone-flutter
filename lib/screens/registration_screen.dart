import 'package:flutter/material.dart';
import 'package:isu_canner/screens/home_screen.dart';
import '../model/api_response.dart';
import '../services/registration.dart';
import '../style/textbox_style.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middlenameController = TextEditingController();
  String _selectedaccountType = 'client';
  String? _selectedDepartment;

  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  Future<void> registerUser() async {
    try {
      ApiResponse response = await register(
        _lastnameController.text,
        _firstnameController.text,
        _middlenameController.text,
        _selectedaccountType,
        _departmentController.text,
        _emailController.text,
        _passwordController.text,
        _confirmpasswordController.text,
      );

      if (!mounted) return;

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully')),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${response.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    }
  }

  @override
  void dispose() {
    _lastnameController.dispose();
    _firstnameController.dispose();
    _middlenameController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left, color: Color(0xFF00A87E)),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            Image.asset(
              'assets/images/isu.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'ISU-CANNER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF052B1D),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Column(
                  children: [
                    Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A87E),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _lastnameController,
                  decoration: greenInputDecoration("LastName", "Your Lastname"),
                  validator: (value) => value!.isEmpty ? 'LASTNAME IS REQUIRED!' : null,
                ),
                const Divider(),
                TextFormField(
                  controller: _firstnameController,
                  decoration: greenInputDecoration("FirstName", "Your Firstname"),
                  validator: (value) => value!.isEmpty ? 'FIRSTNAME IS REQUIRED!' : null,
                ),
                const Divider(),
                TextFormField(
                  controller: _middlenameController,
                  decoration: greenInputDecoration("MiddleName", "Your Middlename"),
                  validator: (value) => value!.isEmpty ? 'MIDDLENAME IS REQUIRED!' : null,
                ),
                const Divider(),
            DropdownButtonFormField<String>(
              value: _selectedaccountType,
              decoration: InputDecoration(
                labelText: "Select User Type",
                labelStyle: const TextStyle(color: Color(0xFF00A87E)), // Label color
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00A87E), width: 2.0), // Border color
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00A87E), width: 2.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00A87E), width: 2.5),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'client',
                  child: Text('Client', style: TextStyle(color: Color(0xFF00A87E))),
                ),
                DropdownMenuItem(
                  value: 'office staff',
                  child: Text('Office Staff', style: TextStyle(color: Color(0xFF00A87E))),
                ),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedaccountType = newValue!;
                });
              },
              style: const TextStyle(color: Color(0xFF00A87E)), // Text color
              dropdownColor: Colors.white.withOpacity(0.9), // Background color
              iconEnabledColor: const Color(0xFF00A87E), // Dropdown icon color
            ),

                const Divider(),
                DropdownButtonFormField<String>(
                  decoration: greenInputDecoration("Department", "Select your Department"),
                  value: _selectedDepartment, // Store the selected value
                  items: ["Administrative and Finance Services Office", "Budget Office", "Accounting Office",
                    "University Vice President Office", "University President Office","Executive Office",
                    "ICT Infrastracture Office","Procurement Office","Bids and Awards Committee Office",
                    "Supply Office"]
                      .map((dept) => DropdownMenuItem(
                    value: dept,
                    child: Text(
                      dept,
                      style: TextStyle(color: Color(0xFF00A87E)), // Change dropdown item text color
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value!;
                    });
                  },
                  style: TextStyle(color: Color(0xFF00A87E)), // Change selected text color
                  dropdownColor: Colors.white, // Change dropdown background color
                  validator: (value) => value == null ? 'PLEASE SELECT YOUR DEPARTMENT!' : null,
                ),


                 const Divider(),
                TextFormField(
                  controller: _emailController,
                  decoration: greenInputDecoration("Email", "example@email.com"),
                  validator: (value) => value!.isEmpty ? 'PLEASE ENTER YOUR EMAIL' : null,
                ),
                const Divider(),
                TextFormField(
                  controller: _passwordController,
                  decoration: greenInputDecoration("Password", "Your Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'PLEASE ENTER YOUR PASSWORD!';
                    if (value.length < 8) return 'PASSWORD MUST BE AT LEAST 8 CHARACTERS!';
                    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'PASSWORD MUST CONTAIN AT LEAST 1 UPPERCASE LETTER!';
                    if (!RegExp(r'\d').hasMatch(value)) return 'PASSWORD MUST CONTAIN AT LEAST 1 NUMBER!';
                    return null;
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: _confirmpasswordController,
                  decoration: greenInputDecoration("Password Confirmation", "Confirm your Password"),
                  obscureText: true,
                  validator: (value) => value!.isEmpty
                      ? 'PASSWORD CONFIRMATION IS REQUIRED!'
                      : value != _passwordController.text
                      ? 'PASSWORDS DO NOT MATCH!'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),  // Button height
                    backgroundColor: Color(0xFF052B1D),  // Change background color
                    foregroundColor: const Color(0xFF00A87E),  // Change text color
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      registerUser();
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 20,  // Change font size
                      fontWeight: FontWeight.bold,  // Make text bold
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
