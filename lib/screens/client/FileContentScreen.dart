import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> downloadPdf(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/downloaded_file.pdf');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } else {
    throw Exception('Failed to download PDF');
  }
}

class FileContentScreen extends StatelessWidget {
  final String filePath;
  final String fileType;

  const FileContentScreen({Key? key, required this.filePath, required this.fileType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget fileContent;

    if (fileType == 'application/pdf') {
      fileContent = PDF().fromUrl(
        filePath,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text('Failed to load PDF: $error')),
      );
    } else if (fileType == 'image') {
      fileContent = Image.network(filePath);
    } else {
      fileContent = Center(child: Text('Unsupported file type'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('File Content'),
      ),
      body: fileContent,
    );
  }
}
