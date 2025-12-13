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
  int _lives = 2;  // Fail 2 times at same level = Game Over
  
  String _displayNumber = "";
  bool _showInput = false;
  TextEditingController _controller = TextEditingController();
  FocusNode _inputFocusNode = FocusNode(); // To auto-focus keyboard
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
      setState(() => _displayNumber = " "); 
      await Future.delayed(Duration(milliseconds: 200));
    }
    setState(() {
      _displayNumber = "?";
      _showInput = true;
      _message = widget.isReverse ? "Escriu AL REVÉS" : "Escriu en el MATEIX ORDRE";
    });
    // Auto-focus the input when it appears
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_inputFocusNode);
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
        content: Text("Has arribat a recordar ${_digits-1} dígits."),
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

  // --- NEW WIDGET: Logic to build the visual boxes ---
  Widget _buildInputBoxes() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // LAYER 1: The Visual Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_digits, (index) {
            String char = "";
            if (_controller.text.length > index) {
              char = _controller.text[index];
            }
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: 50,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: char.isNotEmpty ? Colors.blue : Colors.grey,
                  width: 2
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Text(
                char,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
        
        // LAYER 2: The Invisible TextField that captures clicks and typing
        Opacity(
          opacity: 0.0, // Totally invisible
          child: SizedBox(
            width: _digits * 60.0, // Width to cover the boxes
            height: 60,
            child: TextField(
              controller: _controller,
              focusNode: _inputFocusNode,
              keyboardType: TextInputType.number,
              maxLength: _digits, // Limits input to exact number of boxes
              onChanged: (value) {
                setState(() {}); // Rebuild to update visual boxes
              },
              onSubmitted: (_) => _checkAnswer(),
              decoration: InputDecoration(
                counterText: "", // Hides the "0/3" character counter
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50, // Light blue background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                "Com jugar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.isReverse
                ? "1. Memoritza els números que apareixen.\n2. Quan acabin, escriu-los en ordre INVERS (de l'últim al primer)."
                : "1. Memoritza els números que apareixen.\n2. Quan acabin, escriu-los en el MATEIX ordre.",
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
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
            SizedBox(height: 20),
            // CONDITION: Only show the "How to play" box if we are at the start menu
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.blue[50],
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    !_showInput && _displayNumber == "" ? "Preparat?" : "Vides: $_lives",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (_showInput || _displayNumber != "") 
                    Text(_message, style: TextStyle(fontSize: 18)), // Show status message during game
                ],
              ),
            ),
            if (!_showInput && _displayNumber == "") 
              _buildInfoBox(),
            SizedBox(height: 40),
            
            // Display Number Logic
            if (!_showInput)
              Text(
                _displayNumber,
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            
            // Input Boxes Logic
            if (_showInput)
              _buildInputBoxes(),

            SizedBox(height: 40),
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