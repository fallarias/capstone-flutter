import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../variables/ip_address.dart';

class RatingPage extends StatefulWidget {
  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  List<Map<String, dynamic>> chocolates = [];
  Map<int, int> updatedScores = {}; // Stores updated scores

  @override
  void initState() {
    super.initState();
    fetchChocolates();
  }

  Future<void> fetchChocolates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? transactionId = prefs.getString('transac_id');

    try {
      final response = await http.get(
        Uri.parse('$ipaddress/rate_staff/${transactionId.toString()}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          chocolates = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print("Failed to load ratings");
      }
    } catch (e) {
      print('Something went wrong: $e');
    }
  }

  void _showRatingDialog(int index) {
    int selectedRating = chocolates[index]["score"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rate ${chocolates[index]['user']["lastname"]}"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = i + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  chocolates[index]["score"] = selectedRating;
                  updatedScores[index] = selectedRating; // Store updated score
                });
                Navigator.pop(context);
              },
              child: Text("SET"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateRatings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    List<Map<String, dynamic>> ratingsToSend = chocolates.map((rating) {
      return {
        "user_id": rating["user_id"], // Ensure user_id exists
        "score": rating["score"], // Ensure score is an int
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('$ipaddress/update_staff_rating'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"ratings": ratingsToSend}),
      );
      print("Response: ${response.body}");
      print("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Ratings updated successfully");
      } else {
        print("Failed to update ratings: ${response.body}");
      }
    } catch (e) {
      print("Error updating ratings: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offices Ratings")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chocolates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.person, color: Colors.brown),
                  title: Text(
                    "${chocolates[index]["user"]["lastname"]}, ${chocolates[index]["user"]["firstname"]}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(chocolates[index]["user"]["email"].toString()),
                  trailing: Text(
                    "${chocolates[index]["score"].toString()} of 5",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () => _showRatingDialog(index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: updateRatings, // Call function to send updates
              child: Text("Submit Ratings"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
