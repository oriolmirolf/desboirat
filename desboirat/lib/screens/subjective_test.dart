import 'package:flutter/material.dart';
import 'home_screen.dart'; // To navigate back

class SubjectiveTestScreen extends StatefulWidget {
  @override
  _SubjectiveTestScreenState createState() => _SubjectiveTestScreenState();
}

class _SubjectiveTestScreenState extends State<SubjectiveTestScreen> {
  // Questions from the presentation slides
  final List<String> _questions = [
    "He tingut problemes per concentrar-me",
    "He sentit una 'nebulosa mental'",
    "He oblidat noms d'objectes o persones",
    "He pensat més lentament de l'habitual"
  ];

  // Map to store answers (0-4)
  Map<int, double> _answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Avaluació Subjectiva")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _questions.length + 1, // +1 for the button
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Hackathon Logic: Just go back for now
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Respostes guardades!")));
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("ENVIAR", style: TextStyle(fontSize: 18)),
                ),
              ),
            );
          }
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_questions[index], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Slider(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mai (0)", style: TextStyle(color: Colors.grey)),
                      Text("Molt sovint (4)", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}