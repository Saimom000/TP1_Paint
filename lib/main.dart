import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retinhas',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          // useMaterial3: true,
          ),
      home: const MyHomePage(title: 'Desenhos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Objeto? _objetoAtual;

  final todosObjetos = <Objeto>[];

  void _handleTap(TapUpDetails details) {
    setState(() {
      if (_objetoAtual == null) {
        _objetoAtual = Objeto();
        todosObjetos.add(_objetoAtual!);
      }
      _objetoAtual?.points.add(details.localPosition);
    });
  }

  void _limparTodosObjetos() {
    setState(() {
      todosObjetos.clear();
    });
  }

  void _limparObjetoAtual() {
    setState(() {
      _objetoAtual = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // IconButton(onPressed: () {}, icon: Icon(Icons.abc)),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _limparTodosObjetos,
                  child: Icon(Icons.delete),
                  // label: Text('asdasd'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _limparObjetoAtual,
                  child: Icon(Icons.remove),
                  // label: Text('asdasd'),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.all(16),
              //   child: TextButton(
              //     onPressed: () {},
              //     child: Text('asdasd'),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.all(16),
              //   child: OutlinedButton(
              //     onPressed: () {},
              //     child: Text('asdasd'),
              //   ),
              // ),
            ],
          ),
          Container(
            // botao
            child: Text('darius'),
            color: Colors.red,
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Transform.scale(
                alignment: Alignment.topLeft,
                origin: Offset(-.5, -.5),
                scale: 80,
                child: GestureDetector(
                  onTapUp: _handleTap,
                  child: CustomPaint(
                    painter: MyPainter(todosObjetos),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  // final List<Offset> points;
  final List<Objeto> todosObjetos;

  MyPainter(this.todosObjetos);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final b = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    // passa desenhando as reta

    for (var objeto in todosObjetos) {
      for (var i = 1; i < objeto.points.length; i++) {
        var novosPontos =
            _calcularRetaDDA(objeto.points[i - 1], objeto.points[i]);

        for (var element in novosPontos) {
          // canvas.drawCircle(element, 3.0, paint);

          canvas.drawPoints(PointMode.points, [element], paint);
        }
      }
    }

    // dda || bresenham

    // desenha uma bolota pra cada vértice

    for (var point in todosObjetos) {
      for (var element in point.points) {
        canvas.drawCircle(element, 0.2, b);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  List<Offset> _calcularRetaDDA(Offset ponto1, Offset ponto2) {
    final offsets = <Offset>[];

    final dx = ponto1.dx - ponto2.dx;
    final dy = ponto1.dy - ponto2.dy;

    final passos = dx.abs() > dy.abs() ? dx.abs() : dy.abs();

    final xIncr = dx / passos;
    final yIncr = dy / passos;

    var x = ponto2.dx;
    var y = ponto2.dy;

    offsets.add(Offset(x.roundToDouble(), y.roundToDouble()));

    for (var k = 0; k < passos; k++) {
      x += xIncr;
      y += yIncr;
      offsets.add(Offset(x.roundToDouble(), y.roundToDouble()));
    }

    return offsets;
  }
}

class Objeto {
  final List<Offset> points = [];
}
