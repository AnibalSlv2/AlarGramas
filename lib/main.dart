import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:diacritic/diacritic.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ValidadorPalabras.cargarDiccionario();
  runApp(const MaterialApp(home: AnagramaExpress()));
}

class ValidadorPalabras {
  static Set<String> _diccionario = {};

  static Future<void> cargarDiccionario() async {
    try {
      final contenido = await rootBundle.loadString('assets/es_50k.txt');
      _diccionario = contenido
          .split('\n')
          .map((e) => removeDiacritics(e.trim().toLowerCase()))
          .where((word) => word.isNotEmpty)
          .toSet();
      print("Diccionario cargado con ${_diccionario.length} palabras");
    } catch (e) {
      print("Error cargando diccionario: $e");
    }
  }

  static bool esValida(String palabra) {
    final normalizada = removeDiacritics(palabra.toLowerCase());
    return _diccionario.contains(normalizada);
  }
}

class AnagramaExpress extends StatefulWidget {
  const AnagramaExpress({super.key});

  @override
  State<AnagramaExpress> createState() => _AnagramaExpressState();
}

class _AnagramaExpressState extends State<AnagramaExpress> {
  final List<String> palabrasBase = [
    "camino",
    "panico",
    "salero",
    "rosal",
    "pluma",
    "tierra",
    "limón",
    "amores",
    "ramose",
    "moraes",
    "colina",
    "lacion",
    "nicalo",
    "romano",
    "monora",
    "armono",
    "sarten",
    "trenas",
    "nastre",
    "cresta",
    "careta",
    "recata",
    "pescar",
    "precas",
    "parces",
    "lamina",
    "animal",
    "mailan",
    "melina",
    "enlama",
    "manile",
    "regalo",
    "legora",
    "galero",
    "lagero",
    "alergo",
    "lagore",
  ];

  late String palabraBase;
  late String palabraDesordenada;
  late List<FocusNode> focusNodes;
  late List<TextEditingController> controllers;
  int score = 0;
  int segundosRestantes = 60;
  Timer? temporizador;
  bool diccionarioCargado = false;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(7, (_) => FocusNode());
    controllers = List.generate(7, (_) => TextEditingController());
    generarNuevaPalabra();
    iniciarTemporizador();
    verificarDiccionario();
  }

  void verificarDiccionario() async {
    while (ValidadorPalabras._diccionario.isEmpty) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    setState(() {
      diccionarioCargado = true;
    });
    print("Diccionario verificado y listo");
    print("¿'cero' es válida? ${ValidadorPalabras.esValida("cero")}");
    print("¿'cera' es válida? ${ValidadorPalabras.esValida("cera")}");
  }

  void generarNuevaPalabra() {
    final random = Random();
    palabraBase = palabrasBase[random.nextInt(palabrasBase.length)];
    palabraDesordenada = mezclarLetras(palabraBase);
  }

  String mezclarLetras(String palabra) {
    final letras = palabra.split('');
    letras.shuffle();
    return letras.join();
  }

  bool usaLetrasDisponibles(String palabra) {
    final letrasBase = removeDiacritics(palabraBase.toLowerCase()).split('');
    final letrasUsuario = removeDiacritics(palabra.toLowerCase()).split('');

    for (var letra in letrasUsuario) {
      if (!letrasBase.contains(letra)) return false;
      letrasBase.remove(letra);
    }
    return true;
  }

  void iniciarTemporizador() {
    temporizador?.cancel();
    temporizador = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        segundosRestantes--;
        if (segundosRestantes <= 0) {
          timer.cancel();
          mostrarFinDelJuego();
        }
      });
    });
  }

  void mostrarFinDelJuego() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('⏱ Tiempo agotado'),
        content: Text('Puntaje final: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reiniciarJuego();
            },
            child: Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void reiniciarJuego() {
    setState(() {
      score = 0;
      segundosRestantes = 60;
      generarNuevaPalabra();
      for (var c in controllers) c.clear();
      FocusScope.of(context).requestFocus(focusNodes[0]);
      iniciarTemporizador();
    });
  }

  void validarPalabra() {
    if (!diccionarioCargado) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Diccionario no cargado'),
          content: Text('Espera un momento...'),
        ),
      );
      return;
    }

    final palabra = controllers.map((c) => c.text.trim()).join().toLowerCase();
    if (palabra.isEmpty) return;

    final esValida = ValidadorPalabras.esValida(palabra);
    final esPermitida = usaLetrasDisponibles(palabra);

    print("Palabra ingresada: $palabra");
    print("Palabra base: $palabraBase");
    print("¿Es válida?: $esValida");
    print("¿Usa letras disponibles?: $esPermitida");

    if (esValida && esPermitida) {
      setState(() {
        score += palabra.length;
        generarNuevaPalabra();
        for (var c in controllers) c.clear();
        FocusScope.of(context).requestFocus(focusNodes[0]);
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(esValida ? 'Letras incorrectas' : 'Palabra inválida'),
          content: Text('"$palabra" no es válida o usa letras no permitidas'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    temporizador?.cancel();
    for (var node in focusNodes) node.dispose();
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
            child: Text('⏱ $segundosRestantes s   🧠 Puntaje: $score'),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Anagrama: ${palabraDesordenada.toUpperCase()}",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              return Container(
                width: 50,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  focusNode: focusNodes[index],
                  controller: controllers[index],
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 6) {
                      FocusScope.of(
                        context,
                      ).requestFocus(focusNodes[index + 1]);
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(
                        context,
                      ).requestFocus(focusNodes[index - 1]);
                    }
                  },
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: validarPalabra,
            child: Text('Validar Palabra'),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
