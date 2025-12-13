import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/database_service.dart';

class QRLinkScreen extends StatefulWidget {
  final VoidCallback onLinked; // Callback to tell main.dart we are done
  QRLinkScreen({required this.onLinked});

  @override
  _QRLinkScreenState createState() => _QRLinkScreenState();
}

class _QRLinkScreenState extends State<QRLinkScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        String doctorCode = barcode.rawValue!;
        
        // Save link to Firestore
        await DatabaseService().linkDoctor(doctorCode);
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vinculat al Doctor: $doctorCode")));
        widget.onLinked(); // Navigate to Home
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vincular amb Doctor")),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(onDetect: _onDetect),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Escaneja el codi QR del teu metge", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  if (_isProcessing) CircularProgressIndicator(),
                  TextButton(
                    onPressed: () {
                      // Bypass for Hackathon Demo if camera fails
                      DatabaseService().linkDoctor("DEMO-DOCTOR-1");
                      widget.onLinked();
                    }, 
                    child: Text("Salta (Mode Demo)")
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}