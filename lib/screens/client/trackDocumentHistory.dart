import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isu_canner/screens/client/ratingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../variables/ip_address.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String errorMessage = '';
  String? selectedFilter = 'All'; // Filter option

  final List<String> filterOptions = ['All', 'finished', 'ongoing', 'failed']; // Example filter options

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    String userId = prefs.getInt('userId')?.toString() ?? '';

    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'User ID not found.';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('$ipaddress/client_history/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          isLoading = false;
          transactions = data.cast<Map<String, dynamic>>();
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error parsing data: $e';
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'API request failed with status code: ${response.statusCode}';
      });
    }
  }

  // Filter the transactions based on selected filter
  List<Map<String, dynamic>> getFilteredTransactions() {
    if (selectedFilter == 'All') {
      return transactions;
    } else {
      return transactions.where((transaction) {
        return transaction['status'] == selectedFilter;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get filtered transactions
    List<Map<String, dynamic>> filteredTransactions = getFilteredTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.white), // Change text color here
        ),
        backgroundColor: const Color(0xFF052B1D), // Background color
        iconTheme: const IconThemeData(color: Colors.white), // Change back button color
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Row with DropdownButton aligned to the right
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to the right
              children: [
                DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                  items: filterOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

              ],
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(child: Text(errorMessage))
            else if (filteredTransactions.isEmpty)
                const Center(child: Text('No transactions found'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];

                      String transactionType = transaction['task']['name'] ?? 'Unknown';
                      String status = transaction['status'] ?? 'Ongoing';
                      String formattedDate = 'Invalid Date';
                      String transacID = transaction['transaction_id'].toString();
                      try {
                        if (transaction['updated_at'] != null) {
                          DateTime date = DateTime.parse(transaction['updated_at']).toLocal();
                          formattedDate = DateFormat('d MMM yyyy, h:mm a').format(date);
                        }
                      } catch (e) {
                        formattedDate = 'Invalid Date';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(transactionType.isNotEmpty ? transactionType[0] : '?'),
                              ),
                              title: Text(transactionType),
                              subtitle: Text(formattedDate),
                              trailing: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: status == 'finished' ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            if (status == 'finished') // Add button only for ongoing transactions
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle the "Rate Us" button press
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Rate Us'),
                                          content: const Text('Would you like to rate us?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                await prefs.setString('transac_id', transacID);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>  RatingPage(), // Navigate to the RatingPage
                                                  ),
                                                );
                                              },
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Rate Us'),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
