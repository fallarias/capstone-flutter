
///////filepdf.dart
import 'package:flutter/material.dart';
import 'package:isu_canner/services/filepdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/api_response.dart';
import 'FileContentScreen.dart';
//import 'dart:convert';
//import 'AddNewRoom.dart';

class File extends StatefulWidget {
  const File({super.key});

  @override
  State<File> createState() => _UserState();
}

class _UserState extends State<File> {
  bool isHovered = false;
  int currentPageIndex = 0;
  String token = '';

  void getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
  }

  @override
  void initState() {
    getToken();
    getUsers();
    super.initState();
  }

  List<dynamic> file = [];

  Future<void> getUsers() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = await prefs.getString('token');

    ApiResponse response = await getFiles(token);

    if(response.error == null){
      setState(() {
        file = response.data as List<dynamic>;
      });
    } else {
      print('${response.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          'PDF List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: (() {
        switch (currentPageIndex) {
          case 0:
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Add your other widgets here

                      // Table headers
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filepath', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(), // Divider for table headers

                      // Table body
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: file.length,
                        itemBuilder: (context, index) {
                          Map files = file[index] as Map;

                          return Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.insert_drive_file),
                                title:  Text('${files['filename_extension']}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FileContentScreen(
                                        filePath: files['pdfUrl'],
                                        fileType: files['type'], qrData: '',
                                      ),
                                    ),
                                  );
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('${files['size']}'),
                                      ],
                                    ),
                                    SizedBox(width: 10), // Adds spacing between the elements
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('${files['type']}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(), // Divider for table rows
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                )
            );



        // Add other cases here...


          case 1:
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 1'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 2'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),
                ],
              ),
            );
          case 2:
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                reverse: true,
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Hello',
                          style: theme.textTheme.bodyLarge!
                              .copyWith(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    );
                  }
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Hi!',
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  );
                },
              ),
            );
          default:
            return Container();
        }
      })(),
    );
  }
}






