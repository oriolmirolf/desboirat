import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

class DigitSpanTest extends StatefulWidget {
  final bool isReverse; // True = Working Memory, False = Attention
  DigitSpanTest({required this.isReverse});

  @override
  _DigitSpanTestState createState() => _DigitSpanTestState();
}

class _DigitSpanTestState extends State<DigitSpanTest> {
  List<int> _sequence = [];
  int _digits = 3; // Start with 3 digits
  int _lives = 2;  // Fail 2 times at same level = Game Over (Slide 46)
  
  String _displayNumber = "";
  bool _showInput = false;
  TextEditingController _controller = TextEditingController();
  String _message = "Prem 'Iniciar' per començar";

  void _startGame() {
    setState(() {
      _generateSequence();
      _showInput = false;
      _controller.clear();
      _message = widget.isReverse 
          ? "Memoritza (s'haurà de dir AL REVÉS)" 
          : "Memoritza (s'haurà de dir IGUAL)";
    });
    _playSequence();
  }

  void _generateSequence() {
    var rng = Random();
    _sequence = List.generate(_digits, (_) => rng.nextInt(9) + 1); // 1-9
  }

  void _playSequence() async {
    for (int num in _sequence) {
      setState(() => _displayNumber = num.toString());
      await Future.delayed(Duration(milliseconds: 1000));
      setState(() => _displayNumber = ""); 
      await Future.delayed(Duration(milliseconds: 200));
    }
    setState(() {
      _displayNumber = "?";
      _showInput = true;
      _message = widget.isReverse ? "Escriu AL REVÉS" : "Escriu en el MATEIX ORDRE";
    });
  }

  void _checkAnswer() {
    String input = _controller.text;
    // Normalize input (remove spaces/dashes)
    String cleanInput = input.replaceAll(RegExp(r'[^0-9]'), '');
    
    String correctStr = widget.isReverse 
        ? _sequence.reversed.join() 
        : _sequence.join();

    if (cleanInput == correctStr) {
      // Correct! Reset lives and increase difficulty
      setState(() {
        _digits++;
        _lives = 2; 
        _message = "Correcte! Nivell següent: $_digits dígits";
        _showInput = false;
      });
      Future.delayed(Duration(seconds: 1), _startGame);
    } else {
      // Incorrect
      setState(() {
        _lives--;
      });
      
      if (_lives == 0) {
         _showGameOver();
      } else {
        setState(() {
          _message = "Incorrecte. Et queda 1 intent amb $_digits dígits.";
          _generateSequence(); // Try different numbers same length
          _showInput = false;
        });
        Future.delayed(Duration(seconds: 2), _playSequence);
      }
    }
    _controller.clear();
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Test Finalitzat"),
        content: Text("Has arribat a recordar $_digits dígits."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to menu
            },
            child: Text("Sortir"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isReverse ? "Memòria de Treball" : "Atenció")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vides: $_lives", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(_message, style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            Text(
              _displayNumber,
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 40),
            if (_showInput)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onSubmitted: (_) => _checkAnswer(),
                ),
              ),
            SizedBox(height: 20),
            if (!_showInput && _displayNumber == "")
              ElevatedButton(onPressed: _startGame, child: Text("INICIAR")),
            if (_showInput)
              ElevatedButton(onPressed: _checkAnswer, child: Text("COMPROVAR")),
          ],
        ),
      ),
    );
  }
}