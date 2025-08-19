import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:diacritic/diacritic.dart'; // Añade esta librería en pubspec.yaml

void main() {
  runApp(const MaterialApp(home: ScoreWidget()));
}

class ValidadorPalabras {
  static Set<String>? _diccionario;

  static Future<void> cargarDiccionario() async {
    final contenido = await rootBundle.loadString('assets/es_50k.txt');
    _diccionario = contenido
        .split('\n')
        .map((e) => removeDiacritics(e.trim().toLowerCase()))
        .toSet();
  }

  static Future<bool> esValida(String palabra) async {
    if (_diccionario == null) await cargarDiccionario();
    final normalizada = removeDiacritics(palabra.toLowerCase());
    return _diccionario!.contains(normalizada);
  }
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
  int score = 0;
  final int fieldCount = 5;
  late List<FocusNode> focusNodes;
  late List<TextEditingController> controllers;

  void validarPalabra() async {
    final palabra = controllers.map((c) => c.text).join();
    final esValida = await ValidadorPalabras.esValida(palabra);

    if (esValida) {
      setState(() {
        score += palabra.length; // Puntaje según cantidad de letras
      });
    }
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (_) => AlertDialog(
        title: Text(esValida ? '✅ Palabra válida' : '❌ Palabra no reconocida'),
        content: Text('Ingresaste: $palabra'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _runOnStart();
    focusNodes = List.generate(fieldCount, (_) => FocusNode());
    controllers = List.generate(fieldCount, (_) => TextEditingController());
  }

  void _runOnStart() {}

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
          ), //! ESTO HACE EL ESPACIO EN BLANCO ENTRE EL TIMER Y LOS CUADROS DE TEXTO (LO DE ARRIBA)
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
          ElevatedButton(onPressed: validarPalabra, child: Text('Confirmar')),
        ],
      ),
    );
  }
}
