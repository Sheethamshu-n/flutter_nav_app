import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class ScannerPage extends StatefulWidget {
  final Function(String) onQrDetected;


  const ScannerPage({Key? key, required this.onQrDetected}) : super(key: key);


  @override
  State<ScannerPage> createState() => _ScannerPageState();
}


class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  DateTime? lastDetectionTime;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  void _handleQrDetection(String scannedData) {
    final now = DateTime.now();
    if (lastDetectionTime != null &&
        now.difference(lastDetectionTime!) < const Duration(seconds: 3)) {
      return; // Debounce to prevent rapid-fire scans
    }


    if (scannedData.isNotEmpty) {
      setState(() {
        lastDetectionTime = now;
      });
      widget.onQrDetected(scannedData);
    }
  }


  @override
  Widget build(BuildContext context) {
    double scanBoxSize = MediaQuery.of(context).size.width * 0.8;


    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SizedBox(
          width: scanBoxSize,
          height: scanBoxSize,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: MobileScanner(
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                final scannedData = barcode.rawValue ?? '';
                _handleQrDetection(scannedData);
              },
            ),
          ),
        ),
      ),
    );
  }
}
