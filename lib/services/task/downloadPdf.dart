import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../variables/ip_address.dart';

Future<void> downloadPdf(BuildContext context, String url, String fileName, String id) async {
  // Request external storage permission
  if (!await requestStoragePermission()) {
    return;
  }

  // if (url.endsWith('.pdf')) {
  //   url = url.replaceAll('.pdf', '.docx');
  // }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String userId = prefs.getInt('userId').toString();

  if (token == null) {
    print("No authentication token found");
    return;
  }

  // Check if transaction already exists before proceeding
  await postTransaction(context, token, userId, id);
  // If the transaction already exists, postTransaction will prevent further action

  // If postTransaction didn't return, proceed with the file download

  // Get the external storage directory (e.g., Downloads)
  Directory directory = Directory('/storage/emulated/0/Download');

  // Ensure no duplication of the file extension
  String fileExtension = url.split('.').last; // Get file extension from the URL
  String finalFileName = fileName.endsWith('.$fileExtension') ? fileName : '$fileName.$fileExtension'; // Add extension if missing

  // Define file paths for the QR code image and downloaded PDF
  String qrCodeImagePath = '${directory.path}/$fileName-QRCode.png';  // Save QR code as PNG
  String downloadedPdfPath = '${directory.path}/$finalFileName';  // Correct name for the downloaded file

  try {
    String userDetails = jsonEncode({'userId': userId, 'taskId': id});

    // Generate QR code as image bytes
    final qrCodeImageBytes = await generateQrCodeImage(userDetails);

    // Save the QR code image as a PNG file
    final qrCodeImageFile = File(qrCodeImagePath);
    await qrCodeImageFile.writeAsBytes(qrCodeImageBytes);
    print("QR code image saved to $qrCodeImagePath");

    // Proceed with downloading the actual PDF
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Save the downloaded PDF to a separate file
      final downloadedOutputFile = File(downloadedPdfPath);
      await downloadedOutputFile.writeAsBytes(response.bodyBytes);
      print("Downloaded File saved to $downloadedPdfPath");
    } else {
      print("Failed to download file: ${response.statusCode}");
    }
  } catch (e) {
    print("Error downloading file: $e");
  }
}

// Generate QR code as image bytes using qr_flutter
Future<Uint8List> generateQrCodeImage(String details) async {
  final qrValidationResult = QrValidator.validate(
    data: details,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );

  if (qrValidationResult.status == QrValidationStatus.valid) {
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: true,
    );

    // Render the QR code to an image
    final uiImage = await painter.toImage(300);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  } else {
    throw Exception("QR Code validation failed");
  }
}



Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    } else if (await Permission.storage.isGranted) {
      return true;
    } else {
      if (await Permission.storage.request().isGranted || await Permission.manageExternalStorage.request().isGranted) {
        return true;
      } else {
        print("Storage permission denied. Please allow storage access.");
        return false;
      }
    }
  }
  return false;
}

Future<void> postTransaction(BuildContext context, String? token, String userId, String id) async {
  try {
    final response = await http.post(
      Uri.parse('$ipaddress/transaction'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'user_id': userId,
        'task_id': id,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('API Response: $data');
    } else if (response.statusCode == 409) {
      // If the transaction already exists (HTTP 409 Conflict), show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction already exists. Download not allowed.'),
          duration: Duration(seconds: 3),
        ),
      );
      return; // Prevent further processing
    } else {
      print('Failed to create transaction. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Something went wrong: $e');
  }
}

