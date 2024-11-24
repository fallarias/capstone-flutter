import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../../variables/ip_address.dart';

class DownloadAndViewPdfPage extends StatefulWidget {
  final String filename;
  const DownloadAndViewPdfPage({super.key, required this.filename});

  @override
  _DownloadAndViewPdfPageState createState() => _DownloadAndViewPdfPageState();
}

class _DownloadAndViewPdfPageState extends State<DownloadAndViewPdfPage> {
  String? localFilePath;
  bool isDownloading = true;

  @override
  void initState() {
    super.initState();
    _downloadAndViewPdf();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  Future<void> _downloadAndViewPdf() async {
    await _requestPermissions();

    String url = '$ipaddress/pdf/${widget.filename}';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        var bytes = response.bodyBytes;
        Directory dir = await _getStorageDirectory();
        String filePath = '${dir.path}/${widget.filename}';
        File file = File(filePath);

        await file.writeAsBytes(bytes, flush: true);

        setState(() {
          localFilePath = filePath;
          isDownloading = false;
        });

        OpenFile.open(localFilePath!);
      } catch (e) {
        _handleError(e);
      }
    } else {
      _handleError('Failed to download PDF: ${response.statusCode}');
    }
  }

  Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid && await Permission.storage.isGranted) {
      return await getExternalStorageDirectory() ?? getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  void _handleError(dynamic error) {
    setState(() {
      isDownloading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download and View PDF'),
      ),
      body: Center(
        child: isDownloading
            ? const CircularProgressIndicator()
            : localFilePath != null
                ? Text('PDF downloaded to $localFilePath')
                : const Text('Failed to download PDF'),
      ),
    );
  }
}
