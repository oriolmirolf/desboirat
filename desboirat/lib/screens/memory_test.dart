import 'dart:async';
import 'package:flutter/material.dart';

class MemoryTestScreen extends StatefulWidget {
  @override
  _MemoryTestScreenState createState() => _MemoryTestScreenState();
}

class _MemoryTestScreenState extends State<MemoryTestScreen> {
  List<int> _sequence = [];
  int _level = 3; // Start with 3 digits
  String _displayNumber = "";
  bool _showInput = false;
  TextEditingController _controller = TextEditingController();
  String _message = "Prem 'Iniciar' per començar";

  void _startGame() {
    setState(() {
      _sequence = List.generate(_level, (index) => (index + 1) * 2 % 9 + 1); // Simple random-ish gen
      _sequence.shuffle();
      _showInput = false;
      _controller.clear();
      _message = "Memoritza la seqüència...";
    });
    _playSequence();
  }

  void _playSequence() async {
    for (int num in _sequence) {
      setState(() => _displayNumber = num.toString());
      await Future.delayed(Duration(milliseconds: 1000));
      setState(() => _displayNumber = ""); // clear for blinking effect
      await Future.delayed(Duration(milliseconds: 200));
    }
    setState(() {
      _displayNumber = "?";
      _showInput = true;
      _message = "Escriu els números AL REVÉS";
    });
  }

  void _checkAnswer() {
    // Reverse the input string and parse
    String input = _controller.text;
    List<int> userNumbers = input.split('').map((e) => int.tryParse(e) ?? -1).toList();
    
    // Create the correct reverse sequence
    List<int> correctReverse = List.from(_sequence.reversed);

    bool correct = userNumbers.join() == correctReverse.join();

    if (correct) {
      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: Text("Correcte!"),
          content: Text("Molt bé! Passem al següent nivell."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _level++); // Increase difficulty
                _startGame();
              }, 
              child: Text("Següent")
            )
          ],
        )
      );
    } else {
      setState(() => _message = "Incorrecte. Era: ${correctReverse.join('-')}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Memòria de Treball")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 40),
            Text(
              _displayNumber,
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 40),
            if (_showInput)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, letterSpacing: 5),
                  decoration: InputDecoration(hintText: "Escriu aquí"),
                ),
              ),
            SizedBox(height: 20),
            if (!_showInput)
              ElevatedButton(onPressed: _startGame, child: Text("INICIAR")),
            if (_showInput)
              ElevatedButton(onPressed: _checkAnswer, child: Text("COMPROVAR")),
          ],
        ),
      ),
    );
  }
}