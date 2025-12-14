import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Chat history for the UI
  final List<Map<String, String>> _history = []; 
  
  // Start loading true because we are fetching the initial greeting
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    // 1. Setup the Model & Persona
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system("""
        Actua com a 'Desboira't', l'assistent virtual del programa ICOnnecta't de l'Institut Català d'Oncologia.
        Ets un expert en els effectes mentals de la quimioterapia en pacients i neuropsicologia.
        
        Utilitza aquestes guies clíniques per respondre segons el dèficit de l'usuari:
        1. ATENCIÓ: Recomana Mindfulness, cuidar la postura, fer manualitats, o llegir textos curts.
        2. MEMÒRIA: Recomana l'ús d'agenda (és clau), cuinar receptes antigues, o aprendre paraules noves.
        3. VELOCITAT: Recomana prendre decisions ràpides o jugar a trobar productes al supermercat.
        4. FLUÈNCIA: Recomana llistar objectes o paraules d'una categoria.
        
        Sigues empàtic, encoratjador i molt breu.
      """),
    );
    
    _chat = _model.startChat();

    // 2. Retrieve User Context
    final prefs = await SharedPreferences.getInstance();
    List<String> struggles = prefs.getStringList('affected_domains') ?? [];

    // 3. Generate Personalized Greeting (Hidden Prompt)
    String contextPrompt;
    if (struggles.isEmpty) {
      contextPrompt = "Genera una salutació molt breu i ofereix-te per donar consells de benestar i prevenció. Acaba preguntant com es troba.";
    } else {
      contextPrompt = "L'informe de l'usuari indica que té dificultats en aquestes àrees: ${struggles.join(', ')}. Genera una salutació molt breu i empàtica, reconeixent aquestes dificultats específiques i oferint la teva ajuda. Acaba preguntant com es troba avui.";
    }

    try {
      final response = await _chat.sendMessage(Content.text(contextPrompt));
      
      if (mounted) {
        setState(() {
          _history.add({
            "role": "model", 
            "text": response.text ?? "Hola! Sóc Desboira't. Com et puc ajudar avui?"
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _history.add({
            "role": "model", 
            "text": "Hola! Sóc Desboira't. Sembla que tinc problemes de connexió, però estic aquí per ajudar-te."
          });
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text;
    if (message.isEmpty) return;

    setState(() {
      _history.add({"role": "user", "text": message});
      _isLoading = true;
      _controller.clear();
    });
    
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(message));
      
      setState(() {
        _history.add({"role": "model", "text": response.text ?? "Ho sento, no t'he entès."});
        _isLoading = false;
      });
      _scrollToBottom();
      
    } catch (e) {
      setState(() {
        _history.add({"role": "model", "text": "Error: ${e.toString()}"});
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- WIDGETS ---

  Widget _buildChatBubble(int index) {
    final isUser = _history[index]["role"] == "user";
    final text = _history[index]["text"]!;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Container(
                margin: EdgeInsets.only(right: 8, top: 5),
                child: CircleAvatar(
                  backgroundColor: AppColors.cream,
                  radius: 16,
                  child: Icon(Icons.smart_toy, size: 18, color: AppColors.deepSlate),
                ),
              ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.skyBlue : AppColors.cream,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: isUser ? Radius.circular(20) : Radius.circular(0),
                    bottomRight: isUser ? Radius.circular(0) : Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppColors.deepSlate,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          "Assistent Virtual", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepSlate),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient, 
        ),
        child: SafeArea(
          child: Column(
            children: [
              
              // --- UPDATED LIST VIEW AREA ---
              Expanded(
                child: (_history.isEmpty && _isLoading)
                    // 1. Initial Loading State (Center Screen)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.deepSlate),
                            SizedBox(height: 15),
                            Text(
                              "Desboira't està pensant...",
                              style: TextStyle(
                                color: AppColors.deepSlate.withOpacity(0.7),
                                fontStyle: FontStyle.italic
                              ),
                            )
                          ],
                        ),
                      )
                    // 2. Normal Chat History
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        itemCount: _history.length,
                        itemBuilder: (ctx, i) => _buildChatBubble(i),
                      ),
              ),
              
              // --- BOTTOM LOADER (For subsequent messages) ---
              // Only show this small loader if we already have history (not the first load)
              if (_isLoading && _history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 50, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15, 
                          height: 15, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepSlate)
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Escrivint...", 
                          style: TextStyle(color: AppColors.deepSlate.withOpacity(0.6), fontStyle: FontStyle.italic)
                        ),
                      ],
                    ),
                  ),
                ),

              // --- INPUT AREA ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.cream, 
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: AppColors.deepSlate),
                        decoration: InputDecoration(
                          hintText: "Escriu el teu dubte...",
                          hintStyle: TextStyle(color: AppColors.deepSlate.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.deepSlate, 
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}