import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:toastification/toastification.dart';
import './audit/audit_detail.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? scannedData;
  final String validUrlPrefix = "http://203.175.11.163/asset/";
  bool isScanning = false; // Flag untuk mencegah spam scan

  void _handleScanResult(String? result) {
    if (isScanning) return; // Jangan scan kalau masih dalam delay

    setState(() {
      isScanning = true; // Set flag agar tidak scan berulang
    });

    if (result == null || !result.startsWith(validUrlPrefix)) {
      _showErrorAlert("QR Code tidak valid. Silakan scan kode yang benar.");
    } else {
      // Ambil ID dari URL (angka setelah validUrlPrefix)
      String id = result.replaceFirst(validUrlPrefix, "");

      // Redirect ke halaman DetailAudit dengan ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailAudit(id: id)),
      );
    }

    // Delay 3 detik sebelum bisa scan lagi
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isScanning = false;
      });
    });
  }

  void _showErrorAlert(String message) {
    toastification.show(
      context: context,
      title: const Text("Error"),
      style: ToastificationStyle.fillColored,
      description: Text(message),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBA851),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;

                if (barcodes.isNotEmpty) {
                  final String code = barcodes.first.rawValue ?? "";
                  setState(() {
                    scannedData = code;
                  });

                  _handleScanResult(code); // Proses hasil scan dengan delay 3 detik
                }
              },
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Container(
          //     width: double.infinity,
          //     color: Colors.black.withOpacity(0.8),
          //     padding: const EdgeInsets.all(16),
          //     child: Center(
          //       child: Text(
          //         scannedData ?? 'Arahkan kamera ke QR Code',
          //         style: const TextStyle(color: Colors.white, fontSize: 18),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
