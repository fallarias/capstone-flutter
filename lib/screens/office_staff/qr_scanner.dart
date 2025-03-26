  import 'dart:convert';
  import 'dart:developer';
  import 'package:flutter/material.dart';
  import 'package:qr_code_scanner/qr_code_scanner.dart';
  import '../../services/qrcode.dart';
  import '../office_staff/refresh_notifier.dart';

  class QRScannerPage extends StatefulWidget {
    const QRScannerPage({super.key});

    @override
    State<StatefulWidget> createState() => _QRScannerPageState();
  }

  class _QRScannerPageState extends State<QRScannerPage> {
    Barcode? result;
    QRViewController? controller;
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    bool isFlashOn = false;
    bool isCameraFront = true;
    final QRService qrService = QRService();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan QR Code')),
        body: Stack(
          children: <Widget>[
            _buildQrView(context),
            _buildControlButtons(),
            if (result != null) _buildResultDisplay(),
          ],
        ),
      );
    }

    Widget _buildQrView(BuildContext context) {
      var scanArea = (MediaQuery.of(context).size.width < 400 ||
              MediaQuery.of(context).size.height < 400)
          ? 275.0
          : 300.0;

      return QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 55,
          borderWidth: 10,
          cutOutSize: scanArea,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      );
    }

  Widget _buildControlButtons() {
    return Positioned(
      top: 10,
      right: 16,
      child: Row(
        children: <Widget>[
          _buildButton(
            icon: isFlashOn ? Icons.flash_off : Icons.flash_on,
            onPressed: () async {
              isFlashOn = !isFlashOn;
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
          const SizedBox(width: 8), // Reduced spacing
          _buildButton(
            icon: isCameraFront ? Icons.camera_rear : Icons.camera_front,
            onPressed: () async {
              isCameraFront = !isCameraFront;
              await controller?.flipCamera();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

    Widget _buildButton({
      required IconData icon,
      required VoidCallback onPressed,
    }) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent, // Make the button background transparent
          shadowColor: Colors.transparent, // Remove shadow
        ),
        child: Icon(icon, size: 25, color: Colors.white), // Change color if needed
      );
    }

    Widget _buildResultDisplay() {
      return Positioned(
        bottom: 40,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'Barcode Type: ${result!.format}   Data: ${result!.code}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    void _onQRViewCreated(QRViewController controller) {
      setState(() {
        this.controller = controller;
      });

      controller.scannedDataStream.listen((scanData) async {
        if (result == null) { // Only process the first scan
          setState(() {
            result = scanData;
          });

          // Pause the scanner to avoid multiple scans
          await controller.pauseCamera();

          // Try to parse the data as JSON
          var data;
          try {
            data = jsonDecode(result!.code!);
          } catch (e) {
            data = result!.code; // If not JSON, just send it as plain text
          }

          // Send the data to Laravel backend using the service
          await qrService.sendQRDataToBackend(data);

          // Optionally: Show a message to the user and provide a way to restart the scan
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('QR Code Scanned'),
                content: const Text('Data successfully sent to the server.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      refreshNotifier.value = true;
                      Navigator.of(context).pop();
                      controller.resumeCamera(); // Resume scanning after closing the dialog
                      setState(() {
                        result = null; // Reset result to allow for new scans
                      });
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      });
    }


    void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
      log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
      if (!p) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Permission')),
        );
      }
    }

    @override
    void dispose() {
      controller?.dispose();
      super.dispose();
    }
  }
