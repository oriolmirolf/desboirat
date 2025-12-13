import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/database_service.dart';

class QRLinkScreen extends StatefulWidget {
  final VoidCallback onLinked; // Action to run after success (go to Home)
  QRLinkScreen({required this.onLinked});

  @override
  _QRLinkScreenState createState() => _QRLinkScreenState();
}

class _QRLinkScreenState extends State<QRLinkScreen> {
  bool _isProcessing = false;
  final TextEditingController _manualController = TextEditingController();

  // 1. Called when QR is found
  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _linkToDoctor(barcode.rawValue!);
        break; // Stop after first valid code
      }
    }
  }

  // 2. The Logic to Save to DB
  Future<void> _linkToDoctor(String doctorCode) async {
    setState(() => _isProcessing = true);
    try {
      await DatabaseService().linkDoctor(doctorCode);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vinculat correctament al Doctor!"))
        );
        widget.onLinked(); // Navigate to Home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vincular amb Doctor")),
      body: Column(
        children: [
          // CAMERA AREA
          Expanded(
            flex: 2,
            child: MobileScanner(
              onDetect: _onDetect,
              // Optional: Fit settings if camera looks stretched
              fit: BoxFit.cover, 
            ),
          ),
          
          // MANUAL ENTRY AREA
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Escaneja el codi del teu metge", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("O introdueix el codi manualment:", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualController,
                          decoration: InputDecoration(
                            hintText: "Ex: z8Hj...", 
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10)
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _linkToDoctor(_manualController.text.trim()),
                        child: Text("OK"),
                      )
                    ],
                  ),
                  if (_isProcessing) 
                    Padding(padding: EdgeInsets.only(top: 20), child: CircularProgressIndicator())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}