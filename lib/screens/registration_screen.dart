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

      if (!mounted) return; // Check if widget is still mounted

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully')),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(context,
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
    // Dispose controllers when the widget is removed from the tree
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            Image.asset(
              'assets/images/isu.png',  // Image asset in your project
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
        backgroundColor: Colors.green[900],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 100,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Adjust for keyboard
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _lastnameController,
                  decoration: greenInputDecoration("LastName", "Your Lastname"),  // Using textBoxStyle here
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'LASTNAME IS REQUIRED!';
                    }
                    return null;
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: _firstnameController,
                  decoration: greenInputDecoration("FirstName", "Your Firstname"),  // Using textBoxStyle here
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'FIRSTNAME IS REQUIRED!';
                    }
                    return null;
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: _middlenameController,
                  decoration: greenInputDecoration("MiddleName", "Your Middlename"),  // Using textBoxStyle here
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'MIDDLENAME IS REQUIRED!';
                    }
                    return null;
                  },
                ),
                const Divider(),
                DropdownButtonFormField<String>(
                  value: _selectedaccountType,
                  decoration: const InputDecoration(
                    labelText: "Select User Type",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    {'display': 'Client', 'value': 'client'},
                    {'display': 'Office Staff', 'value': 'office staff'},
                    //{'display': 'Supplier', 'value': 'supplier'},
                  ].map((item) {
                    return DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(item['display']!),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedaccountType = newValue!;
                    });
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: _departmentController,
                  decoration: greenInputDecoration("Department", "Your Department Eg. CCSICT"),  // Using textBoxStyle here
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'PLEASE ENTER YOUR DEPARTMENT!';
                    }
                    return null;
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: _emailController,
                  decoration: greenInputDecoration("Email", "example@email.com"),  // Using textBoxStyle here
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'PLEASE ENTER YOUR EMAIL';
                    }
                    return null;
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: _passwordController,
                  decoration: greenInputDecoration("Password", "Your Password"),  // Using textBoxStyle here
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'PLEASE ENTER YOUR PASSWORD!';
                    } else if (value.length < 8) {
                      return 'PASSWORD MUST BE AT LEAST 8 CHARACTERS!';
                    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'PASSWORD MUST CONTAIN AT LEAST 1 UPPERCASE LETTER!';
                    } else if (!RegExp(r'\d').hasMatch(value)) {
                      return 'PASSWORD MUST CONTAIN AT LEAST 1 NUMBER!';
                    }
                    return null;
                  },
                ),
                const Divider(),
                TextFormField(
                  controller: _confirmpasswordController,
                  decoration: greenInputDecoration("Password Confimation", "Confirm your Password"), 
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'PASSWORD CONFIRMATION IS REQUIRED!';
                    } else if (value != _passwordController.text) {
                      return 'PASSWORDS DO NOT MATCH!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      registerUser();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
