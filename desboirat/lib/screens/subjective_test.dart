import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Ensure this path is correct
import '../services/database_service.dart'; // ADDED THIS IMPORT

class SubjectiveTestScreen extends StatefulWidget {
  @override
  _SubjectiveTestScreenState createState() => _SubjectiveTestScreenState();
}

class _SubjectiveTestScreenState extends State<SubjectiveTestScreen> {
  // Questions mapped to domains based on Slides 65 & 74
  final List<Map<String, dynamic>> _questions = [
    {
      "text": "He tingut problemes per concentrar-me o he perdut el fil de converses.",
      "domain": "Atenció"
    },
    {
      "text": "He pensat més lentament de l'habitual.",
      "domain": "Velocitat"
    },
    {
      "text": "He tingut la paraula 'a la punta de la llengua' o no m'ha sortit.",
      "domain": "Fluència"
    },
    {
      "text": "He oblidat on he posat coses o informació recent.",
      "domain": "Memòria"
    },
    {
      "text": "He sentit una 'nebulosa mental' (brain fog).",
      "domain": "Funcions Executives"
    },
  ];

  // Map to store answers (0-4)
  Map<int, double> _answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // THEME: Allows gradient behind AppBar
      appBar: AppBar(
        title: Text(
          "Autoavaluació", // Slight text tweak to fit title bar better, or keep "Avaluació Subjectiva"
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepSlate),
      ),
      body: Container(
        // THEME: Main Gradient Background
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: _questions.length + 1, // +1 for the button
            itemBuilder: (context, index) {
              
              // --- SUBMIT BUTTON ---
              if (index == _questions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cream, // THEME: Cream Button
                      foregroundColor: AppColors.deepSlate, // THEME: Slate Text
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      // --- DATABASE SAVE ---
                      // We convert keys to String because Firestore maps require String keys
                      await DatabaseService().saveResult('qüestionari_subjectiu', {
                        'answers_map': _answers.map((k, v) => MapEntry(k.toString(), v)),
                        'domains': _questions.map((q) => q['domain']).toList(),
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Respostes guardades!"),
                            backgroundColor: AppColors.deepSlate,
                          )
                        );
                        Navigator.pop(context);
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
                  color: AppColors.cream, // THEME: Cream Card
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
                    // Domain Tag (Optional visual enhancement)
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
                    
                    // Question Text
                    Text(
                      _questions[index]['text'], 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepSlate, // THEME: Slate Text
                        height: 1.3
                      )
                    ),
                    
                    SizedBox(height: 20),
                    
                    // The Slider
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
                    
                    // Labels 0 - 4
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