import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class HelpRecommendationsScreen extends StatefulWidget {
  @override
  _HelpRecommendationsScreenState createState() => _HelpRecommendationsScreenState();
}

class _HelpRecommendationsScreenState extends State<HelpRecommendationsScreen> {
  List<String> _strugglingDomains = [];
  bool _isLoading = true;

  // Track independent indices for tips and videos
  Map<String, int> _currentTipIndices = {};
  Map<String, int> _currentVideoIndices = {};

  // --- CONTENT DATA ---
  final Map<String, Map<String, List<String>>> _guideContent = {
    "Atenció": {
      "tips": [
        "Avui és un bon dia per fer algo d'esport, potser anar a caminar una estona o alguna altra activitat que et vingui de gust.",
        "Aquesta setmana és ideal per fer alguna manualitat, posa molta atenció en allò que fas, potser un dibuix, un puzle, cosir alguna cosa, etc.",
        "Si tens una estona, llegeix un text curt (una notícia, un paràgraf d'un llibre) i intenta comprendre'l detenidament.",
      ],
      "videoIds": ["B_M8eFq2GCA", "_5HCl5CDA94", "fXDHm8PP6qo"]
    },
    "Memòria": {
      "tips": [
        "L'ús d'una agenda és clau: no confiïs en el teu cap, apunta-ho tot immediatament.",
        "Aquesta setmana és ideal per tornar a fer aquella recepta que has deixat de fer i et sortia tan bé.",
        "Prova d'aprendre algunes paraules d'un nou idioma, potser un idioma que ja en sàpigues una mica o un completament nou!",
      ],
      "videoIds": ["RExO6edCQYk", "FJIy-R3Gze4", "iGTnb1YeRNw"]
    },
    "Velocitat": {
      "tips": [
        "Avui és el dia de les decisions ràpides: no pots tardar més de 15 segons en escollir la roba que et posaràs.",
        "Dia d'anar al supermercat! Prova a trobar el més ràpid possible on són les galetes Maria.",
        "Cronometra't fent una tasca rutinària (com parar taula) i intenta fer-ho una mica més ràpid demà.",
      ],
      "videoIds": ["RExO6edCQYk", "FJIy-R3Gze4"]
    },
    "Fluència": {
      "tips": [
        "Avui durant 5 minuts has d'anar dient en veu alta tots els objectes que veus al teu voltant.",
        "Pensa durant uns minuts quantes fruites i verdures hi ha de color vermell.",
        "Llegeix en veu alta durant 10 minuts i fes un petit resum oral del que has llegit.",
      ],
      "videoIds": ["B_M8eFq2GCA", "_5HCl5CDA94", "fXDHm8PP6qo"]
    },
    "Funcions Executives": {
      "tips": [
        "Planifica el dia anteriorment fent una llista tancada de tasques. No improvisis.",
        "Fragmenta les tasques grans en passos petits. En lloc de 'netejar la casa', posa 'netejar el bany'.",
        "Utilitza autoinstruccions: parla amb tu mateix en veu alta per guiar-te ('ara agafo les claus...').",
      ],
      "videoIds": ["B_M8eFq2GCA", "_5HCl5CDA94", "fXDHm8PP6qo"]
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUserNeeds();
  }

  Future<void> _loadUserNeeds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> loadedDomains = prefs.getStringList('affected_domains') ?? [];
    
    // We do NOT add "Prevenció" to the list here anymore.
    // If the list is empty, the build method handles showing _buildEmptyState

    final rng = Random();
    Map<String, int> initTipIndices = {};
    Map<String, int> initVideoIndices = {};
    
    for (var domain in loadedDomains) {
      String key = _findKey(domain);
      
      if (_guideContent.containsKey(key)) {
        // Random Tip Index
        int tipCount = _guideContent[key]?['tips']?.length ?? 0;
        initTipIndices[key] = tipCount > 0 ? rng.nextInt(tipCount) : 0;

        // Random Video Index
        int vidCount = _guideContent[key]?['videoIds']?.length ?? 0;
        initVideoIndices[key] = vidCount > 0 ? rng.nextInt(vidCount) : 0;
      }
    }

    setState(() {
      _strugglingDomains = loadedDomains;
      _currentTipIndices = initTipIndices;
      _currentVideoIndices = initVideoIndices;
      _isLoading = false;
    });
  }

  String _findKey(String rawDomain) {
    if (_guideContent.containsKey(rawDomain)) return rawDomain;
    String firstWord = rawDomain.split(" ").first;
    if (_guideContent.containsKey(firstWord)) return firstWord;
    return "Atenció"; // Fallback
  }

  void _nextTip(String domainKey) {
    setState(() {
      int current = _currentTipIndices[domainKey] ?? 0;
      int total = _guideContent[domainKey]?['tips']?.length ?? 1;
      _currentTipIndices[domainKey] = (current + 1) % total;
    });
  }

  void _nextVideo(String domainKey) {
    setState(() {
      int current = _currentVideoIndices[domainKey] ?? 0;
      int total = _guideContent[domainKey]?['videoIds']?.length ?? 1;
      _currentVideoIndices[domainKey] = (current + 1) % total;
    });
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
                  ? _buildEmptyState() // Shows the "All Good" + Preventive List
                  : ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: _strugglingDomains.length,
                      itemBuilder: (context, index) {
                        String rawDomain = _strugglingDomains[index];
                        String key = _findKey(rawDomain);
                        if (!_guideContent.containsKey(key)) return SizedBox.shrink();

                        int tIdx = _currentTipIndices[key] ?? 0;
                        List<String> tips = _guideContent[key]!['tips']!;
                        String currentTip = tips.isNotEmpty ? tips[tIdx] : "Sense consells disponibles.";

                        int vIdx = _currentVideoIndices[key] ?? 0;
                        List<String> videos = _guideContent[key]!['videoIds']!;
                        String currentVideoId = videos.isNotEmpty ? videos[vIdx] : "";

                        return _buildDomainCard(key, currentTip, currentVideoId);
                      },
                    ),
        ),
      ),
    );
  }

  // --- UPDATED EMPTY STATE ---
  Widget _buildEmptyState() {
    // List of general preventive habits
    final List<String> preventiveHabits = [
      "Fer esport",
      "Cuidar l'alimentació",
      "Aprendre coses noves",
      "Sociabilitzar",
      "Fer Mindfulness",
    ];

    return SingleChildScrollView( // Allow scrolling on small screens
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Icon(Icons.check_circle_outline, size: 80, color: AppColors.deepSlate.withOpacity(0.5)),
            SizedBox(height: 20),
            Text(
              "Tot correcte!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
            ),
            SizedBox(height: 10),
            Text(
              "Segons l'autoavaluació, no hi ha àrees crítiques.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.deepSlate),
            ),
            
            SizedBox(height: 30),

            // --- PREVENTIVE TIPS BOX ---
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.deepSlate.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.health_and_safety, color: Colors.orangeAccent),
                      SizedBox(width: 10),
                      Text(
                        "HÀBITS DE PREVENCIÓ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
                      ),
                    ],
                  ),
                  Divider(height: 20, color: AppColors.deepSlate.withOpacity(0.1)),
                  // List generation
                  ...preventiveHabits.map((habit) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 20, color: Colors.green),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            habit,
                            style: TextStyle(fontSize: 16, color: AppColors.deepSlate),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),

            SizedBox(height: 30),
            Text(
              "(Si encara no has fet el test, ves a 'Autoavaluació' primer)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.deepSlate.withOpacity(0.6), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainCard(String title, String tip, String videoId) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.lightbulb, color: Colors.orangeAccent, size: 24),
              ),
              SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
              ),
            ],
          ),
          Divider(height: 25, color: AppColors.deepSlate.withOpacity(0.1)),
          
          // Tip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CONSELL RÀPID", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepSlate.withOpacity(0.5))),
              InkWell(
                onTap: () => _nextTip(title),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 14, color: AppColors.skyBlue),
                      SizedBox(width: 4),
                      Text("Un altre", style: TextStyle(fontSize: 12, color: AppColors.skyBlue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 90, 
            alignment: Alignment.centerLeft,
            child: Text(
              tip,
              style: TextStyle(fontSize: 16, height: 1.4, color: AppColors.deepSlate),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 20),
          
          // Video
          if (videoId.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("VÍDEO RECOMANAT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepSlate.withOpacity(0.5))),
                InkWell(
                  onTap: () => _nextVideo(title),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(Icons.skip_next, size: 16, color: Colors.red[800]),
                        SizedBox(width: 4),
                        Text("Següent vídeo", style: TextStyle(fontSize: 12, color: Colors.red[800], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            _VideoPlayerItem(videoId: videoId, key: ValueKey(videoId)),
          ]
        ],
      ),
    );
  }
}

// --- PLAYER WIDGET ---
class _VideoPlayerItem extends StatefulWidget {
  final String videoId;
  const _VideoPlayerItem({Key? key, required this.videoId}) : super(key: key);

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final url = "https://www.youtube.com/watch?v=${widget.videoId}";
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.deepSlate,
              progressColors: ProgressBarColors(
                playedColor: AppColors.deepSlate,
                handleColor: AppColors.deepSlate,
              ),
            ),
            builder: (context, player) {
              return player;
            },
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _openExternal,
            icon: Icon(Icons.open_in_new, size: 16, color: Colors.red[800]),
            label: Text("Obrir a YouTube", style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              backgroundColor: Colors.red.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
            ),
          ),
        ),
      ],
    );
  }
}