import 'package:flutter/material.dart';
// import 'home_screen.dart'; // To navigate back

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
                  // FIX: Access the 'text' property of the map
                  Text(
                    _questions[index]['text'], 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
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