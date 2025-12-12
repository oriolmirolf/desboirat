import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
    // Initialize Gemini with the specific "Desboira't" Persona
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyC7TcP2NErh2r_gXj8ECtN0ue9s_lydfjI',
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
    
    // Scroll to bottom
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assistent Virtual")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (ctx, i) {
                final isUser = _history[i]["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(_history[i]["text"]!),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escriu el teu dubte...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
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
    );
  }
}