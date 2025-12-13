import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_colors.dart'; 
import '../services/database_service.dart'; 
import '../services/daily_tracker.dart';

class DigitSpanTest extends StatefulWidget {
  final bool isReverse; // True = Working Memory, False = Attention
  DigitSpanTest({required this.isReverse});

  @override
  _DigitSpanTestState createState() => _DigitSpanTestState();
}

class _DigitSpanTestState extends State<DigitSpanTest> {
  List<int> _sequence = [];
  
  // CHANGED: Removed initial value assignment here. 
  // It is now set in initState based on the game mode.
  late int _digits; 
  
  int _lives = 2;  
  
  String _displayNumber = "";
  bool _showInput = false;
  TextEditingController _controller = TextEditingController();
  FocusNode _inputFocusNode = FocusNode(); 
  String _message = "Prem 'Iniciar' per començar";

  // CHANGED: Added initState to configure starting difficulty
  @override
  void initState() {
    super.initState();
    // Logic: 
    // If Reverse (Working Memory) -> Start at 3
    // If Forward (Attention)      -> Start at 4
    _digits = widget.isReverse ? 3 : 4;
  }

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
      _displayNumber = " ";
      _showInput = true;
      _message = widget.isReverse ? "Escriu AL REVÉS" : "Escriu en el MATEIX ORDRE";
    });
    
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_inputFocusNode);
    });
  }

  void _checkAnswer() {
    String input = _controller.text;
    String cleanInput = input.replaceAll(RegExp(r'[^0-9]'), '');
    
    String correctStr = widget.isReverse 
        ? _sequence.reversed.join() 
        : _sequence.join();

    if (cleanInput == correctStr) {
      // --- CHANGED: Max Level Logic ---
      // Define max based on mode (8 for reverse, 9 for forward)
      int maxDigits = widget.isReverse ? 8 : 9;

      if (_digits >= maxDigits) {
        // User completed the maximum level!
        setState(() {
          _digits++; // Increment one last time so the score calculation (_digits - 1) is correct
          _message = "Felicitats! Has completat el test.";
          _showInput = false;
        });
        // End the game immediately as a victory
        _showGameOver(isVictory: true);
      } else {
        // Standard progression: Reset lives and increase difficulty
        setState(() {
          _digits++;
          _lives = 2; 
          _message = "Correcte! Nivell següent: $_digits dígits";
          _showInput = false;
        });
        Future.delayed(Duration(seconds: 1), _startGame);
      }
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
          _generateSequence(); 
          _showInput = false;
        });
        Future.delayed(Duration(seconds: 2), _playSequence);
      }
    }
    _controller.clear();
  }

  void _showGameOver({bool isVictory = false}) {
    // --- DATABASE SAVE ---
    DatabaseService().saveResult(widget.isReverse ? 'memoria_treball' : 'atencio', {
      'score': _digits - 1, 
      'test_type': widget.isReverse ? 'reverse' : 'forward',
    });

    if (widget.isReverse) {
      DailyTracker.markAsDone(DailyTracker.KEY_MEMORY);
    } else {
      DailyTracker.markAsDone(DailyTracker.KEY_ATTENTION);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream, 
        title: Text(
          isVictory ? "Enhorabona!" : "Test Finalitzat", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold)
        ),
        content: Text(
          isVictory 
            ? "Has completat el màxim nivell! (${_digits-1} dígits)."
            : "Has arribat a recordar ${_digits-1} dígits.", 
          style: TextStyle(color: AppColors.deepSlate)
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepSlate, // THEME
              foregroundColor: AppColors.cream,     // THEME
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Home
            }, 
            child: Text("Tornar"),
          )
        ],
      ),
    );
  }

  // --- WIDGETS ---
  
  Widget _buildInputBoxes() {
    return Stack(
      alignment: Alignment.center,
      children: [
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
                  color: char.isNotEmpty ? AppColors.deepSlate : Colors.grey,
                  width: 2
                ),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.cream, 
              ),
              child: Text(
                char,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
              ),
            );
          }),
        ),
        
        Opacity(
          opacity: 0.0, 
          child: SizedBox(
            width: _digits * 60.0, 
            height: 60,
            child: TextField(
              controller: _controller,
              focusNode: _inputFocusNode,
              keyboardType: TextInputType.number,
              maxLength: _digits, 
              onChanged: (value) {
                setState(() {}); 
                if (value.length == _digits) {
                   Future.delayed(Duration(milliseconds: 300), _checkAnswer);
                }
              },
              decoration: InputDecoration(
                counterText: "", 
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
        color: AppColors.cream, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.deepSlate.withOpacity(0.3)), 
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
              Icon(Icons.info_outline, color: AppColors.deepSlate), 
              SizedBox(width: 10),
              Text(
                "Com jugar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepSlate), 
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.isReverse
                ? "1. Memoritza els números que apareixen.\n2. Quan acabin, escriu-los en ordre INVERS (de l'últim al primer)."
                : "1. Memoritza els números que apareixen.\n2. Quan acabin, escriu-los en el MATEIX ordre.",
            style: TextStyle(fontSize: 16, color: AppColors.deepSlate), 
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          widget.isReverse ? "Memòria de Treball" : "Atenció",
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepSlate), 
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 100), 
              
              Container(
                padding: EdgeInsets.all(20),
                color: AppColors.cream.withOpacity(0.5), 
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      !_showInput && _displayNumber == "" ? "Preparat?" : "Vides: $_lives",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
                    ),
                    if (_showInput || _displayNumber != "") 
                      Text(_message, style: TextStyle(fontSize: 18, color: AppColors.deepSlate)), 
                  ],
                ),
              ),
              if (!_showInput && _displayNumber == "") 
                _buildInfoBox(),
              
              SizedBox(height: 40),
              
              if (!_showInput)
                Text(
                  _displayNumber,
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.deepSlate), 
                ),
              
              if (_showInput)
                _buildInputBoxes(),

              SizedBox(height: 40),
              
              if (!_showInput && _displayNumber == "")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cream, 
                    foregroundColor: AppColors.deepSlate, 
                  ),
                  onPressed: _startGame, 
                  child: Text("INICIAR")
                ),
                
              if (_showInput)
                 SizedBox.shrink(), 
            ],
          ),
        ),
      ),
    );
  }
}