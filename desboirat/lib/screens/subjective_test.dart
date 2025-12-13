import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORT THIS
import '../theme/app_colors.dart';
import '../services/database_service.dart';

class SubjectiveTestScreen extends StatefulWidget {
  @override
  _SubjectiveTestScreenState createState() => _SubjectiveTestScreenState();
}

class _SubjectiveTestScreenState extends State<SubjectiveTestScreen> {
  // Questions mapped to domains based on Slides 65 & 74
  final List<Map<String, dynamic>> _questions = [
    {
      "text": "He anat a un lloc de l'habitació i, quan hi he arribat, no he recordat què hi anava a fer.",
      "domain": "Atenció"
    },
    {
      "text": "He trigat més del normal a fer una activitat que abans feia més ràpid.",
      "domain": "Velocitat" // Shortened for cleaner keys
    },
    {
      "text": "Volia dir una paraula i no m'ha sortit, o n'he dit una altra sense voler.",
      "domain": "Fluència"
    },
    {
      "text": "Quan estava parlant amb algú, he perdut el fil de la conversa.",
      "domain": "Atenció"
    },
    {
      "text": "M'han preguntat per una cosa que m'havien dit fa poc i no me n'he recordat.",
      "domain": "Memòria"
    },
    {
      "text": "He tingut problemes per recordar informació que ja sabia prèviament.",
      "domain": "Memòria"
    },
    {
      "text": "He tingut problemes per prendre una decisió que abans no m'hauria costat.",
      "domain": "Funcions Executives"
    },
    {
      "text": "He tingut dificultats per planificar el meu dia.",
      "domain": "Funcions Executives"
    },
    {
      "text": "He sentit sensació de nebulosa mental.",
      "domain": "Funcions Executives"
    },
    {
      "text": "He sentit que penso més lenta avui.",
      "domain": "Velocitat"
    },
  ];

  // Map to store answers (0-4)
  Map<int, double> _answers = {};

  // --- NEW HELPER FUNCTION: Calculates domains with avg > 2 ---
  List<String> _calculateAffectedDomains() {
    Map<String, List<double>> domainScores = {};

    // 1. Group scores by domain
    for (int i = 0; i < _questions.length; i++) {
      String domain = _questions[i]['domain'];
      double score = _answers[i] ?? 0.0; // Default to 0 if not answered

      if (!domainScores.containsKey(domain)) {
        domainScores[domain] = [];
      }
      domainScores[domain]!.add(score);
    }

    // 2. Calculate Average and Filter
    List<String> highImpactDomains = [];
    domainScores.forEach((domain, scores) {
      if (scores.isNotEmpty) {
        double average = scores.reduce((a, b) => a + b) / scores.length;
        if (average > 2.0) {
          highImpactDomains.add(domain);
        }
      }
    });

    return highImpactDomains;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Autoavaluació",
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
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: _questions.length + 1,
            itemBuilder: (context, index) {
              
              // --- SUBMIT BUTTON ---
              if (index == _questions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cream,
                      foregroundColor: AppColors.deepSlate,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      // 1. Calculate the affected areas
                      List<String> affectedDomains = _calculateAffectedDomains();

                      // 2. Save to SharedPreferences (For fast access in Chatbot/Home)
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setStringList('affected_domains', affectedDomains);

                      // 3. Save to Database (History)
                      await DatabaseService().saveResult('qüestionari_subjectiu', {
                        'answers_map': _answers.map((k, v) => MapEntry(k.toString(), v)),
                        'affected_domains': affectedDomains, // <--- Storing the result here too
                        'timestamp': DateTime.now().toIso8601String(),
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Resultats guardats!"),
                            backgroundColor: AppColors.deepSlate,
                          )
                        );
                        // Optional: Return the data directly to the previous screen
                        Navigator.pop(context, affectedDomains);
                      }
                    },
                    child: Text(
                      "ENVIAR RESULTATS", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ),
                );
              }

              // --- QUESTION CARD ---
              return Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepSlate.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _questions[index]['domain'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold, 
                          color: AppColors.deepSlate
                        ),
                      ),
                    ),
                    Text(
                      _questions[index]['text'], 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepSlate,
                        height: 1.3
                      )
                    ),
                    SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.deepSlate,
                        inactiveTrackColor: AppColors.deepSlate.withOpacity(0.2),
                        thumbColor: AppColors.deepSlate,
                        overlayColor: AppColors.deepSlate.withOpacity(0.1),
                        valueIndicatorColor: AppColors.deepSlate,
                        trackHeight: 4.0,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      ),
                      child: Slider(
                        value: _answers[index] ?? 0,
                        min: 0,
                        max: 4,
                        divisions: 4,
                        label: "${_answers[index]?.toInt() ?? 0}",
                        onChanged: (val) {
                          setState(() {
                            _answers[index] = val;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Mai (0)", style: TextStyle(color: AppColors.deepSlate.withOpacity(0.6))),
                          Text("Sovint (4)", style: TextStyle(color: AppColors.deepSlate.withOpacity(0.6))),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}