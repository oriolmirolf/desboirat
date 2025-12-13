import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme/app_colors.dart'; // Ensure this path is correct

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    // Initialize Gemini with the specific "Desboira't" Persona
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      // SYSTEM INSTRUCTION: Defines the clinical personality based on the ICO slides
      systemInstruction: Content.system("""
        Actua com a 'Desboira't', l'assistent virtual del programa ICOnnecta't de l'Institut Català d'Oncologia.
        Ets un expert en 'Chemo Brain' i neuropsicologia.
        
        Utilitza aquestes guies clíniques per respondre segons el dèficit de l'usuari:
        
        1. ATENCIÓ: Recomana Mindfulness, cuidar la postura, fer manualitats, o llegir textos curts subratllant mentalment les idees.
        2. MEMÒRIA: Recomana l'ús d'agenda (és clau), cuinar receptes antigues, o aprendre paraules d'un nou idioma.
        3. VELOCITAT DE PROCESSAMENT: Recomana prendre decisions ràpides (en menys de 15 segons) o jugar a trobar productes ràpidament al supermercat.
        4. FLUÈNCIA VERBAL: Recomana exercicis com anomenar tots els objectes que veus al voltant durant 5 minuts o llistar fruites d'un color.
        
        Si l'usuari diu que NO té problemes, felicita'l i recomana: Esport, dieta saludable, socialitzar i aprendre coses noves per prevenció.
        
        Sigues empàtic, breu i encoratjador.
      """),
    );
    
    _chat = _model.startChat();
    
    // Add an initial greeting from the "Desboira't" persona
    setState(() {
      _history.add({
        "role": "model", 
        "text": "Hola! Sóc el teu assistent de Desboira't. Puc donar-te estratègies per millorar l'atenció, la memòria o la velocitat mental. Com et sents avui?"
      });
    });
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
        _history.add({"role": "model", "text": "Error de connexió. Revisa la teva API Key o internet."});
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
            // Model Avatar (Only for model)
            if (!isUser)
              Container(
                margin: EdgeInsets.only(right: 8, top: 5),
                child: CircleAvatar(
                  backgroundColor: AppColors.cream,
                  radius: 16,
                  child: Icon(Icons.smart_toy, size: 18, color: AppColors.deepSlate),
                ),
              ),

            // The Message Bubble
            Flexible(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // THEME: SkyBlue for User, Cream for Model
                  color: isUser ? AppColors.skyBlue : AppColors.cream,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: isUser ? Radius.circular(20) : Radius.circular(0),
                    bottomRight: isUser ? Radius.circular(0) : Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppColors.deepSlate, // THEME: Always slate text
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
      extendBodyBehindAppBar: true, // THEME: Gradient behind AppBar
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
          gradient: AppColors.mainGradient, // THEME: Main Gradient
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) => _buildChatBubble(i),
                ),
              ),
              
              // Loading Indicator (Thinking...)
              if (_isLoading)
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
                          "Desboira't està escrivint...", 
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
                  color: AppColors.cream, // THEME: Cream bottom bar
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
                        color: AppColors.deepSlate, // THEME: Slate Button
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