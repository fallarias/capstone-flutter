
import 'package:flutter/material.dart';
import 'package:isu_canner/screens/client/task_step.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/api_response.dart';
import '../../services/document_list.dart';




class TrackDocument extends StatefulWidget {
  const TrackDocument({super.key});

  @override
  State<TrackDocument> createState() => _DocumentState();
}

class _DocumentState extends State<TrackDocument> {
  List<dynamic> tasks = [];
  List<dynamic> transaction = [];
  bool isLoading = true;
  String token = '';

  @override
  void initState() {
    super.initState();
    getDocumentData(); // Fetch data on initialization
  }

  Future<void> getDocumentData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    ApiResponse response = await getDocument(token);

    setState(() {
      isLoading = false; // Update loading state here
      if (response.error == null) {
        final data = response.data as Map<String, dynamic>;
        tasks = data['tasks'] as List<dynamic>;
        transaction = data['transactions'] as List<dynamic>;

        // Save all task IDs to SharedPreferences
        //_saveAllTaskIds(tasks);
      } else {
        print('${response.error}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : tasks.isEmpty
        ? const Center(child: Text('No documents available'))
        : Column(
      children: tasks.map((task) {
        return ListTile(
          title: Row(
            children: [
              Text(
                transaction.isNotEmpty
                    ? transaction[0]['transaction_id'].toString()
                    : 'No Transaction', // Transaction ID or fallback text
              ), // Transaction ID on the right
              const SizedBox(width: 15), // Fixed spacing of 15px
              Text(task['name']), // Task name on the left
            ],
          ),
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('taskId', task['task_id'].toString());
            print('Saved task ID: ${task['task_id']}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackOrderScreen(),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
