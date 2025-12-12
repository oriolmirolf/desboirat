import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/local_dictionary.dart'; // Import your new dictionary

class FluencyTestScreen extends StatefulWidget {
  @override
  _FluencyTestScreenState createState() => _FluencyTestScreenState();
}

class _FluencyTestScreenState extends State<FluencyTestScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isGameActive = false;
  int _timeLeft = 60;
  Timer? _timer;
  
  // Real-time feedback
  String _liveHearing = ""; // Shows exactly what is being heard NOW
  List<String> _validSequence = [];
  
  // Logic tracking
  List<String> _processedWords = []; 
  
  // Game Config
  final List<String> _letters = ['A', 'B', 'C', 'M', 'P', 'R', 'S', 'T'];
  // Must match keys in LocalDictionary
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
      
      _timeLeft = 60;
      _liveHearing = "";
      _validSequence = [];
      _processedWords = [];
      _isGameActive = false;
    });
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _startGame() {
    setState(() => _isGameActive = true);
    _startTimer();
    _startListening();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    _speech.stop();
    setState(() => _isGameActive = false);
    _showFinalScore();
  }

  void _startListening() {
    _speech.listen(
      localeId: "ca-ES",
      listenFor: Duration(seconds: 60),
      pauseFor: Duration(seconds: 3),
      partialResults: true, // Crucial: Gives us text WHILE speaking
      onResult: (val) {
        setState(() {
          _liveHearing = val.recognizedWords; // Update UI immediately
        });
        _processStream(val.recognizedWords);
      },
    );
  }

  void _processStream(String transcript) {
    // 1. Clean the text
    List<String> allWords = transcript
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    // 2. Only check NEW words
    if (allWords.length > _processedWords.length) {
      List<String> newWords = allWords.sublist(_processedWords.length);
      _processedWords.addAll(newWords);

      // 3. Fast Validation
      for (String word in newWords) {
        _validateWord(word);
      }
    }
  }

  void _validateWord(String word) {
    // Determine what we need RIGHT NOW
    int count = _validSequence.length;
    bool expectingLetter = _startWithLetter 
        ? (count % 2 == 0)  // If start letter: 0=Letter, 1=Cat, 2=Letter...
        : (count % 2 != 0); // If start cat: 0=Cat, 1=Letter...

    bool isValid = false;

    if (expectingLetter) {
      // Fast String Check
      if (LocalDictionary.isValidLetter(word, _targetLetter)) {
        isValid = true;
      }
    } else {
      // Fast Set Lookup
      if (LocalDictionary.isValidCategory(word, _targetCategory)) {
        isValid = true;
      }
    }

    if (isValid) {
      // Prevent duplicates (optional)
      if (!_validSequence.contains(word)) {
        setState(() {
          _validSequence.add(word);
          // Clear "Live Hearing" visually to show we "consumed" the word
          // Note: The actual STT stream continues, but visual feedback resets
        });
      }
    } else {
      // It was noise or wrong word. Ignore it.
      print("Ignored: $word (Expected Letter: $expectingLetter)");
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Temps esgotat!"),
        content: Text("Resultat: ${_validSequence.length} paraules vàlides."),
        actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); _generateRandomChallenge(); }, child: Text("Sortir"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Highlight logic
    int count = _validSequence.length;
    bool isNextLetter = _startWithLetter ? (count % 2 == 0) : (count % 2 != 0);

    return Scaffold(
      appBar: AppBar(title: Text("Fluència (Ràpida)")),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.blue[50],
            child: Row(
              children: [
                Text("$_timeLeft", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                if (!_isGameActive)
                  Expanded(child: ElevatedButton(onPressed: _startGame, child: Text("COMENÇAR JOC"))),
                if (_isGameActive)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Escoltant ara:", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          // SHOW WHAT IS BEING HEARD
                          Text(
                            _liveHearing.isEmpty ? "..." : "... $_liveHearing", 
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildCard("LLETRA", _targetLetter, isNextLetter)),
                Icon(Icons.swap_horiz, color: Colors.grey),
                Expanded(child: _buildCard("CATEGORIA", _targetCategory, !isNextLetter)),
              ],
            ),
          ),

          Divider(),

          // Valid List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: _validSequence.length,
              reverse: true, // Newest at bottom
              itemBuilder: (ctx, i) {
                // To show in order of appearance
                int index = i; 
                String word = _validSequence[index];
                bool isLetterType = _startWithLetter ? (index % 2 == 0) : (index % 2 != 0);
                
                return Align(
                  alignment: isLetterType ? Alignment.centerLeft : Alignment.centerRight,
                  child: Chip(
                    label: Text(word.toUpperCase()),
                    backgroundColor: isLetterType ? Colors.blue[100] : Colors.orange[100],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String content, bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.white,
        border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)] : [],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey)),
          Text(content, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black)),
        ],
      ),
    );
  }
}