
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/task/tasks.dart';
import '../variables/ip_address.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:isu_canner/services/task/downloadPdf.dart';




class TaskListWidget extends StatefulWidget {
  const TaskListWidget({super.key});

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  List<dynamic> tasks = [];
  bool isLoading = true;
  String token = '';
  final TaskService taskService = TaskService(ipaddress);

  @override
  void initState() {
    super.initState();
    fetchTasks();
    getToken();
  }

  void getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
  }

  Future<void> fetchTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final fetchedTasks = await taskService.fetchTasks(token);
      setState(() {
        tasks = fetchedTasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : tasks.isEmpty
        ? const Center(child: Text('No tasks available'))
        : Column(
      children: tasks.map((task) {
        return ListTile(
          title: Text(task['name']),
          onTap: () async {
            final taskId = task['task_id'].toString();
            final filePath = task['pdfUrl'] ?? ''; // Use pdfUrl if available
            final fileType = filePath.endsWith('.pdf') ? 'application/pdf' : task['type'];

            if (filePath.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File is not available')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(
                  filePath: filePath,
                  fileName: task['filename'],
                  fileType: fileType,
                  id: taskId,
                  qrData: '',
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// Example TaskDetailScreen to handle task details
class TaskDetailScreen extends StatelessWidget {
  final String filePath;
  final String fileType;
  final String fileName;
  final String id;
  final String qrData;

  const TaskDetailScreen({
    Key? key,
    required this.filePath,
    required this.fileType,
    required this.fileName,
    required this.id,
    required this.qrData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget fileContent;

    if (fileType == 'application/pdf') {
      fileContent = Stack(
        children: [
          PDF().fromUrl(
            filePath,
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) => Center(child: Text('Failed to load PDF: $error')),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 100.0,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      );
    } else if (fileType == 'image') {
      fileContent = Image.network(filePath);
    } else {
      fileContent = Center(child: Text('Unsupported file type'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Template Details'),
      ),
      body: fileContent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          downloadPdf(context, filePath, fileName, id); // Use filePath for downloading
        },
        child: Icon(Icons.download), // Use a download icon
        tooltip: 'Download PDF', // Tooltip for the button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position the button at the bottom right
    );
  }
}