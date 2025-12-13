import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/local_dictionary.dart'; 
import '../services/database_service.dart'; // Keeping your import
import '../theme/app_colors.dart'; // IMPORT THEME
import '../services/daily_tracker.dart';

class FluencyTestScreen extends StatefulWidget {
  @override
  _FluencyTestScreenState createState() => _FluencyTestScreenState();
}

class _FluencyTestScreenState extends State<FluencyTestScreen> {
  // Speech Engine
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _liveText = "Prem 'COMENÇAR' per iniciar"; // Feedback text
  
  // Game State
  int _timeLeft = 60;
  Timer? _gameTimer;
  bool _isGameActive = false;
  
  // Game Logic Data
  List<String> _validSequence = []; // Words we have accepted
  Set<String> _processedBuffer = {}; // To avoid re-processing same words
  
  // Game Configuration
  final List<String> _letters = ['A', 'B', 'C', 'M', 'P', 'R', 'S', 'T'];
  final List<String> _categories = ['Animals', 'Fruites', 'Colors', 'Ciutats', 'Roba']; 
  
  late String _targetLetter;
  late String _targetCategory;
  late bool _startWithLetter; 

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _generateRandomChallenge();
  }

  void _generateRandomChallenge() {
    final rng = Random();
    setState(() {
      _targetLetter = _letters[rng.nextInt(_letters.length)];
      _targetCategory = _categories[rng.nextInt(_categories.length)];
      _startWithLetter = rng.nextBool();
      
      // Reset State
      _timeLeft = 60;
      _validSequence = [];
      _processedBuffer = {};
      _liveText = "Prem 'COMENÇAR' per iniciar";
      _isGameActive = false;
      _isListening = false;
    });
  }

  void _initSpeech() async {
    await _speech.initialize(
      onError: (val) => print('onError: $val'),
      onStatus: (val) {
        // print('onStatus: $val'); // Debugging
        
        // CRITICAL FIX: Update UI state based on real status
        if (mounted) {
          setState(() {
            _isListening = (val == 'listening');
          });
        }

        // AUTO-RESTART LOGIC:
        // If mic stops ('done' or 'notListening') BUT game is still active...
        // Restart it immediately!
        if ((val == 'done' || val == 'notListening') && _isGameActive && _timeLeft > 0) {
          _startListening();
        }
      },
    );
  }

  // --- GAME CONTROL ---

  void _startGame() {
    setState(() => _isGameActive = true);
    _startTimer();
    _startListening();
  }

  void _stopGame() {
    _gameTimer?.cancel();
    _speech.stop();
    setState(() {
      _isGameActive = false;
      _isListening = false;
    });
    _showFinalScore();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _stopGame();
      }
    });
  }

  // --- SPEECH LOGIC (Based on your working snippet) ---

  void _startListening() async {
    // Only start if not already listening to avoid errors
    if (!_isListening) {
      await _speech.listen(
        localeId: "ca-ES", // Catalan
        listenFor: Duration(seconds: 60), // Try to listen for the whole minute
        pauseFor: Duration(seconds: 60),   // Allow 3s silence before it "cuts" (and auto-restarts)
        partialResults: true,             // We need this to validate words instantly
        onResult: (val) {
          if (!mounted) return;
          setState(() {
            _liveText = val.recognizedWords;
          });
          // Send to validation logic
          _processStream(val.recognizedWords);
        },
      );
    }
  }

  // This is the "Brain" that filters the messy sentence into valid game moves
  void _processStream(String rawText) {
    // 1. Clean the text: Lowercase, remove punctuation
    String cleanText = rawText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    
    // 2. Split into words
    List<String> words = cleanText.split(' ').where((w) => w.isNotEmpty).toList();

    // 3. Check each word
    for (String word in words) {
      // If we've already processed this exact word in this session, skip
      if (_processedBuffer.contains(word)) continue;

      _processedBuffer.add(word); // Mark as seen
      _validateCandidate(word);   // Validate
    }
  }

  void _validateCandidate(String word) {
    // Logic: What is the NEXT item we need?
    int count = _validSequence.length;
    // If count is 0 (even), we need 1st type. If 1 (odd), we need 2nd type.
    // BUT we swap types based on _startWithLetter
    bool expectingLetter = _startWithLetter ? (count % 2 == 0) : (count % 2 != 0);

    bool isValid = false;

    if (expectingLetter) {
      if (LocalDictionary.isValidLetter(word, _targetLetter)) isValid = true;
    } else {
      if (LocalDictionary.isValidCategory(word, _targetCategory)) isValid = true;
    }

    if (isValid) {
      // Success! Add to list
      if (!_validSequence.contains(word)) {
        setState(() {
          _validSequence.add(word);
        });
      }
    }
  }

  // --- UI ---

  void _showFinalScore() {
    // --- DATABASE SAVE ---
    DatabaseService().saveResult('fluencia_verbal', {
      'score': _validSequence.length,
      'words_found': _validSequence,
      'target_letter': _targetLetter,
      'target_category': _targetCategory,
    });

    DailyTracker.markAsDone(DailyTracker.KEY_FLUENCY);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream, // THEME
        title: Text(
          "Temps esgotat!", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold) // THEME
        ),
        content: Text(
          "Has aconseguit ${_validSequence.length} paraules vàlides.",
          style: TextStyle(color: AppColors.deepSlate) // THEME
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepSlate, // THEME
              foregroundColor: AppColors.cream,     // THEME
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to Home
            }, 
            child: Text("Tornar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine active card for highlighting
    int count = _validSequence.length;
    bool isNextLetter = _startWithLetter ? (count % 2 == 0) : (count % 2 != 0);

    return Scaffold(
      extendBodyBehindAppBar: true, // THEME: For gradient
      appBar: AppBar(
        title: Text(
          "Fluència Verbal", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold) // THEME
        ),
        backgroundColor: Colors.transparent, // THEME
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepSlate), // THEME
      ),
      body: Container(
        // THEME: Main Gradient Background
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea( // Added SafeArea to ensure content is visible
          child: Column(
            children: [
              // 1. Header with Timer and Start Button
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(16), // Added margin for styling
                decoration: BoxDecoration(
                   // THEME: MintGreen for active, Cream for inactive
                  color: _isGameActive ? AppColors.mintGreen.withOpacity(0.9) : AppColors.cream,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
                  ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Temps", style: TextStyle(color: AppColors.deepSlate.withOpacity(0.6))), // THEME
                        Text(
                          "$_timeLeft s", 
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.deepSlate) // THEME
                        ),
                      ],
                    ),
                    if (!_isGameActive)
                      ElevatedButton.icon(
                        onPressed: _startGame, 
                        icon: Icon(Icons.mic), 
                        label: Text("COMENÇAR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepSlate, // THEME
                          foregroundColor: AppColors.cream,     // THEME
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Styling
                        ),
                      ),
                    if (_isGameActive)
                      Chip(
                        avatar: Icon(Icons.mic, color: Colors.white, size: 18),
                        label: Text("Escoltant..." , style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.orangeAccent, // Keeping logic visible but distinct
                      )
                  ],
                ),
              ),

              // 2. The Target Cards (Dynamic Highlight)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(child: _buildCard("LLETRA", _targetLetter, isNextLetter)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: AppColors.deepSlate.withOpacity(0.4)), // THEME
                    SizedBox(width: 8),
                    Expanded(child: _buildCard("CATEGORIA", _targetCategory, !isNextLetter)),
                  ],
                ),
              ),

              // 3. Live Transcript (Feedback)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  _liveText.isEmpty ? "..." : "... $_liveText",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.deepSlate.withOpacity(0.7), // THEME
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),

              Divider(height: 1, color: AppColors.deepSlate.withOpacity(0.2)), // THEME

              // 4. List of Validated Words
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _validSequence.length,
                  reverse: true, // Show newest items at bottom
                  itemBuilder: (context, index) {
                    int realIndex = _validSequence.length - 1 - index;
                    String word = _validSequence[realIndex];
                    bool wasLetter = _startWithLetter ? (realIndex % 2 == 0) : (realIndex % 2 != 0);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: wasLetter ? MainAxisAlignment.start : MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              // THEME: SkyBlue for Letters, MintGreen for Categories
                              color: wasLetter ? AppColors.skyBlue : AppColors.mintGreen,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  word.toUpperCase(), 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepSlate) // THEME
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.check_circle, size: 16, color: AppColors.deepSlate.withOpacity(0.6)), // THEME
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content, bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cream, // THEME: Always cream
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          // THEME: Border is DeepSlate if active, Transparent if not
          color: isActive ? AppColors.deepSlate : Colors.transparent, 
          width: isActive ? 3 : 1
        ),
        boxShadow: isActive 
            ? [BoxShadow(color: AppColors.deepSlate.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 4))] 
            : [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))], // THEME
      ),
      child: Column(
        children: [
          Text(
            title, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              // THEME: Text is DeepSlate (faded if inactive)
              color: isActive ? AppColors.deepSlate : AppColors.deepSlate.withOpacity(0.4)
            )
          ),
          SizedBox(height: 5),
          Text(
            content, 
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              // THEME: Text is DeepSlate (faded if inactive)
              color: isActive ? AppColors.deepSlate : AppColors.deepSlate.withOpacity(0.4)
            )
          ),
        ],
      ),
    );
  }
}