import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class HelpRecommendationsScreen extends StatefulWidget {
  @override
  _HelpRecommendationsScreenState createState() => _HelpRecommendationsScreenState();
}

class _HelpRecommendationsScreenState extends State<HelpRecommendationsScreen> {
  List<String> _strugglingDomains = [];
  bool _isLoading = true;

  // Static content: Tips and Video Links for each domain
  final Map<String, Map<String, String>> _guideContent = {
    "Atenció": {
      "tip": "Practica el 'Mindfulness' i l'atenció plena. Quan llegeixis, subratlla mentalment les idees clau. Elimina distraccions (mòbil, sorolls) quan facis tasques importants.",
      "url": "https://www.youtube.com/results?search_query=exercicis+atencio+mindfulness"
    },
    "Memòria": {
      "tip": "L'ús d'una agenda és clau: apunta-ho tot. Intenta cuinar receptes antigues de memòria o aprèn 3 paraules noves cada dia.",
      "url": "https://www.youtube.com/results?search_query=millorar+memoria+exercicis"
    },
    "Velocitat": {
      "tip": "Entrena't a prendre decisions ràpides (en menys de 15 segons) per coses trivials (què menjar, què posar-te). Cronometra't fent tasques rutinàries.",
      "url": "https://www.youtube.com/results?search_query=velocitat+processament+cognitiu"
    },
    "Fluència": {
      "tip": "Juga a anomenar objectes que veus pel carrer ràpidament. Llegeix en veu alta durant 10 minuts al dia i resumeix el que has llegit.",
      "url": "https://www.youtube.com/results?search_query=fluencia+verbal+exercicis"
    },
    "Funcions Executives": {
      "tip": "Planifica el dia anteriorment fent una llista tancada de tasques. Fragmenta les tasques grans en passos petits i manejables.",
      "url": "https://www.youtube.com/results?search_query=funcions+executives+planificacio"
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUserNeeds();
  }

  Future<void> _loadUserNeeds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load the list we saved in the Subjective Test
      _strugglingDomains = prefs.getStringList('affected_domains') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No s'ha pogut obrir el video")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Els Teus Consells", style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepSlate),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.deepSlate))
              : _strugglingDomains.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: _strugglingDomains.length,
                      itemBuilder: (context, index) {
                        String domain = _strugglingDomains[index];
                        // Fallback in case domain name doesn't match keys exactly
                        var content = _guideContent[domain] ?? _guideContent[domain.split(" ").first] ?? {
                          "tip": "Consulta amb el teu especialista per exercicis específics.",
                          "url": "https://www.youtube.com"
                        };

                        return _buildTipCard(domain, content["tip"]!, content["url"]!);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: AppColors.deepSlate.withOpacity(0.5)),
          SizedBox(height: 20),
          Text(
            "Tot correcte!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
          ),
          SizedBox(height: 10),
          Text(
            "Segons la teva autoavaluació, no hi ha cap àrea crítica (>2). Continua mantenint un estil de vida actiu i saludable!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.deepSlate),
          ),
          SizedBox(height: 30),
          Text(
            "(Si encara no has fet el test, ves a 'Autoavaluació' primer)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.deepSlate.withOpacity(0.6), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String tip, String url) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.deepSlate.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orangeAccent, size: 28),
              SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
              ),
            ],
          ),
          Divider(height: 20, color: AppColors.deepSlate.withOpacity(0.1)),
          
          // Tip Text
          Text(
            tip,
            style: TextStyle(fontSize: 16, height: 1.4, color: AppColors.deepSlate),
          ),
          
          SizedBox(height: 20),
          
          // Video Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50], // YouTube-ish light red
                foregroundColor: Colors.red[800],
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () => _launchVideo(url),
              icon: Icon(Icons.play_circle_fill),
              label: Text("Veure exercicis en vídeo"),
            ),
          )
        ],
      ),
    );
  }
}