import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ScoreWidget()));
}

class ScoreWidget extends StatefulWidget {
  const ScoreWidget({super.key});

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

Widget addLetter(String letter) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(20),
    ),
    margin: EdgeInsets.all(20),
    padding: EdgeInsets.all(15),
    child: Text(letter, style: TextStyle(fontSize: 20)),
  );
}

class _ScoreWidgetState extends State<ScoreWidget> {
  final int fieldCount = 5;
  late List<FocusNode> focusNodes;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(fieldCount, (_) => FocusNode());
    controllers = List.generate(fieldCount, (_) => TextEditingController());
  }

  @override
  void dispose() {
    // ignore: curly_braces_in_flow_control_structures
    for (var node in focusNodes) node.dispose();
    // ignore: curly_braces_in_flow_control_structures
    for (var controller in controllers) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int score = 0;
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 40, 20, 0),
            alignment: Alignment.centerRight,
            child: Text('Puntaje: $score'),
          ),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(15),
            child: Text("Palabra Anagrama", style: TextStyle(fontSize: 20)),
          ),
          Text("1:00", style: TextStyle(fontSize: 20)),
          Expanded(
            child: Text(""),
          ), //! ESTO HACE EL ESPACIO EN BLANCO ENTRE EL TIMER Y LOS CUADROS DE TEXTO
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(fieldCount, (index) {
                    return Container(
                      width: 50,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        focusNode: focusNodes[index],
                        controller: controllers[index],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          if (value.isNotEmpty && index < fieldCount - 1) {
                            FocusScope.of(
                              context,
                            ).requestFocus(focusNodes[index + 1]);
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "", // Oculta el contador de caracteres
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
