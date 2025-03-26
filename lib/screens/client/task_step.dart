import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/api_response.dart';
import '../../variables/ip_address.dart';

class TrackOrderScreen extends StatefulWidget {
  @override
  State<TrackOrderScreen> createState() => TrackOrderScreenState();
}

class TrackOrderScreenState extends State<TrackOrderScreen> {
  String token = '';
  List<OrderStatus> statusList = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getToken().then((_) => fetchTasks());
  }

  Future<void> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }

  Future<ApiResponse> fetchTasks() async {
    ApiResponse apiResponse = ApiResponse();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String taskId = prefs.getString('taskId') ?? '';
    String userId = prefs.getInt('userId').toString();

    try {
      final response = await http.get(
        Uri.parse('$ipaddress/template_history/$taskId/${userId.toString()}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          apiResponse.data = data.map<OrderStatus>((item) {
            return OrderStatus(
              officeName: item['Office_name'],
              officeTask: item['Office_task'],
              newAllotedTime: item['New_alloted_time_display'],
              Status: item['task_status'],
            );
          }).toList();
          break;
        case 404:
          apiResponse.error = 'No task found.';
          break;
        case 422:
        case 403:
          apiResponse.error = jsonDecode(response.body)['message'];
          break;
        default:
          apiResponse.error = 'Something went wrong.';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Something went wrongs. $e';
    }

    return apiResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Document',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF052B1D),
      ),
      body: FutureBuilder<ApiResponse>(
        future: fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data?.error != null) {
            return Center(child: Text('Error: ${snapshot.data?.error}'));
          } else {
            statusList = snapshot.data!.data as List<OrderStatus>;

            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: StepIndicator(
                          steps: statusList,
                          scrollController: _scrollController,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: statusList.map((item) => OrderStatusWidget(item: item)).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),

    );
  }
}

// Custom Step Indicator Widget with Scroll Controller
class StepIndicator extends StatelessWidget {
  final List<OrderStatus> steps;
  final ScrollController scrollController;

  const StepIndicator({Key? key, required this.steps, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final isFinished = steps[index].Status == 'Completed';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isFinished ? Colors.green : Colors.grey[300],
              child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
            ),
            if (index < steps.length - 1)
              Container(
                height: 100,
                width: 2,
                color: isFinished ? Colors.green : Colors.grey[300],
              ),
          ],
        );
      },
    );
  }
}

// OrderStatus model
class OrderStatus {
  final String officeName;
  final String officeTask;
  final String newAllotedTime;
  final String Status;

  OrderStatus({
    required this.officeName,
    required this.officeTask,
    required this.newAllotedTime,
    required this.Status,
  });
}

// The widget for displaying each order status remains the same
class OrderStatusWidget extends StatelessWidget {
  final OrderStatus item;

  const OrderStatusWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 18.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${item.Status}'),
              Text('Office: ${item.officeName}'),
              Text('Task: ${item.officeTask}'),
              Text('Allotted Time: ${item.newAllotedTime} '),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
