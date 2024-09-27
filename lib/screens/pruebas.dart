import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sebastian Agudelo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    print("Incrementing counter");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Dale a me gusta y suscribete para elevar tu seniority',
              textAlign: TextAlign.center, // Centrar el texto
              style: TextStyle(
                fontSize: 24, // Tamaño más grande
                fontWeight: FontWeight.bold, // Opcional: Negrita
              ),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20), // Espacio entre el contador y los botones
            // Botón de me gusta
            ElevatedButton.icon(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.thumb_up),
              label: const Text('Me gusta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20), // Espacio entre los dos botones
            // Botón de suscribirse
            ElevatedButton(
              onPressed: () {
                // Acción cuando se presiona el botón de suscribirse
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Suscríbete'),
            ),
          ],
        ),
      ),
    );
  }
}
