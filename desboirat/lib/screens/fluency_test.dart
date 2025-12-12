import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FluencyTestScreen extends StatefulWidget {
  @override
  _FluencyTestScreenState createState() => _FluencyTestScreenState();
}

class _FluencyTestScreenState extends State<FluencyTestScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Prem el micròfon i comença a parlar...";
  int _wordCount = 0;
  int _timeLeft = 60; // 1 minute test
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _startListening() {
    if (!_isListening) {
      _startTimer();
      _speech.listen(
        localeId: "ca-ES", // Catalan
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
          // Simple logic: split by spaces to count words
          _wordCount = _text.trim().isEmpty ? 0 : _text.trim().split(' ').length;
        }),
      );
      setState(() => _isListening = true);
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    _timer?.cancel();
    setState(() => _isListening = false);
  }

  void _startTimer() {
    _timeLeft = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _stopListening();
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Temps esgotat!"),
        content: Text("Has dit $_wordCount paraules."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fluència Verbal")),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        backgroundColor: _isListening ? Colors.red : Colors.blue,
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Temps restant: $_timeLeft s", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
              "Instrucció: Digues paraules que comencin per 'P' o Noms de Fruites.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _text,
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Paraules detectades: $_wordCount", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}