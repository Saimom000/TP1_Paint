import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'classes.dart';
import 'enum.dart';
import 'painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'É o desenhas',
      // theme: ThemeData(
      //     colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Objeto? _objetoAtual;
  Janela? _janela;
  List<Objeto> todosObjetos = [];

  // final todosObjetos = <Objeto>[];
  static const movimentoTela = 5.0;
  var scale = 60.0;
  var pixel = 1.0;

  var fechar = false;

  var _rasterizacao = Rasterizacao.dda;
  var _recorte = Recorte.sohenSutherland;
  var _xyEspelhar = EspelharXY.x;

  _MyHomePageState() {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 121, 137, 255)
      ..strokeWidth = pixel;
    _objetoAtual = Objeto(fechar, _corObjetos(null));
    todosObjetos.add(_objetoAtual!);
    _janela = Janela(true, paint);
  }

  Paint _corObjetos(Color? cor) {
    final paint = Paint();
    if (cor == null) {
      paint
        ..color = Colors.black
        ..strokeWidth = pixel;
    } else {
      paint
        ..color = cor
        ..strokeWidth = pixel;
    }

    return paint;
  }

  void _criarObjeto() {
    if (_objetoAtual!.points.isEmpty) {
      todosObjetos.remove(_objetoAtual);
    }

    _objetoAtual = Objeto(fechar, _corObjetos(null));
    todosObjetos.add(_objetoAtual!);
  }

  void _criarCirculo() {
    if (_objetoAtual!.points.isEmpty) {
      todosObjetos.remove(_objetoAtual);
    }
    _objetoAtual = Circulo(fechar, _corObjetos(null));
    todosObjetos.add(_objetoAtual!);
  }

  void _adicionarPontoJanela(TapUpDetails details) {
    _janela!.points.add(details.localPosition);
    if (_janela!.points.length == 2) {
      _janela!.points
          .insert(1, Offset(_janela!.points.last.dx, _janela!.points.first.dy));
      _janela!.points
          .add(Offset(_janela!.points.first.dx, _janela!.points.last.dy));
    }
  }

  void _adicionarPontoObjeto(TapUpDetails details) {
    setState(() {
      if (_janela!.abilitar && _janela!.points.length < 2) {
        _adicionarPontoJanela(details);
      } else {
        if (_objetoAtual is! Circulo) {
          _objetoAtual?.points.add(details.localPosition);
        } else if (_objetoAtual!.points.length < 2) {
          _objetoAtual?.points.add(details.localPosition);
        } else {
          _criarCirculo();
          _objetoAtual?.points.add(details.localPosition);
        }
      }
    });
  }

  void _limparTodosObjetos() {
    setState(() {
      todosObjetos.clear();
    });
  }

  void _botaoObjetoAtual() {
    setState(() {
      fechar = false;
      _criarObjeto();
    });
  }

  void _botaoObjetoAtualFechar() {
    setState(() {
      fechar = true;
      _criarObjeto();
    });
  }

  void _botaoCirculo() {
    setState(() {
      fechar = false;
      _criarCirculo();
    });
  }

  void _voltaPasso() {
    setState(() {
      if (_objetoAtual!.points.isNotEmpty) {
        _objetoAtual!.points.removeLast();
      }
      if (_objetoAtual!.points.isEmpty) {
        if (todosObjetos.length != 1) {
          todosObjetos.removeLast();
          _objetoAtual = todosObjetos.last;
        }
      }
    });
  }

  void _mudarEscala(int i) {
    setState(() {
      scale += i;
    });
  }

  void _criarJanela() {
    setState(() {
      if (_janela!.abilitar) {
        _janela!.points.clear();
        _janela!.abilitar = false;
      } else {
        _janela!.abilitar = true;
      }
    });
  }

  void _mover(double x, double y) {
    setState(() {
      for (var objeto in todosObjetos) {
        for (var p = 0; p < objeto.points.length; p++) {
          objeto.points[p] = objeto.points[p].translate(x, y);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('É o desenhas'),
        // titleSpacing: ,
      ),
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
            _mover(movimentoTela * -1, 0);
          },
          const SingleActivator(LogicalKeyboardKey.arrowRight): () {
            _mover(movimentoTela, 0);
          },
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            _mover(0, movimentoTela * -1);
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            _mover(0, movimentoTela);
          },
        },
        child: Listener(
          behavior: HitTestBehavior.translucent, //talvez
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              if (pointerSignal.scrollDelta.dy > 0) {
                _mudarEscala(-2);
              } else if (pointerSignal.scrollDelta.dy < 0) {
                _mudarEscala(2);
              }
            }
          },
          child: Focus(
            autofocus: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  children: [
                    IconItem(Icons.remove, 'Linhas', Colors.white, Colors.blue,
                        _botaoObjetoAtual),

                    IconItem(Icons.check_box_outline_blank, 'Objeto fechado',
                        Colors.white, Colors.blue, _botaoObjetoAtualFechar),

                    IconItem(Icons.circle_outlined, 'Circulo', Colors.white,
                        Colors.blue, _botaoCirculo),

                    IconItem(Icons.arrow_circle_up, 'Aumentar escala',
                        Colors.white, Colors.blue, _botaoCirculo),

                    IconItem(Icons.arrow_circle_down, 'Diminuir escala',
                        Colors.white, Colors.blue, _botaoCirculo),

                    IconItem(Icons.auto_mode, 'Desfazer', Colors.white,
                        Colors.red, _voltaPasso),
                    // Padding(
                    //   padding: const EdgeInsets.all(16),
                    //   child: ElevatedButton(
                    //     onPressed: _botaoCirculo,
                    //     child: const Icon(Icons.border_all),
                    //     // label: Text('asdasd'),
                    //   ),
                    // ),
                    IconItem(Icons.branding_watermark_outlined, 'Criar Janela',
                        Colors.white, Colors.blue, _criarJanela),

                    IconItem(Icons.delete, 'Limpar tudo', Colors.white,
                        Colors.red, _limparTodosObjetos),

                    IntrinsicWidth(
                      child: RadioListTile(
                        title: const Text('DDA'),
                        value: Rasterizacao.dda,
                        groupValue: _rasterizacao,
                        onChanged: (value) {
                          setState(() {
                            _rasterizacao = value!;
                          });
                        },
                      ),
                    ),
                    IntrinsicWidth(
                      child: RadioListTile(
                        title: const Text('Bresenham'),
                        value: Rasterizacao.bresenham,
                        groupValue: _rasterizacao,
                        onChanged: (value) {
                          setState(() {
                            _rasterizacao = value!;
                          });
                        },
                      ),
                    ),
                    IntrinsicWidth(
                      child: RadioListTile(
                        title: const Text('Cohen-Sutherland'),
                        value: Recorte.sohenSutherland,
                        groupValue: _recorte,
                        onChanged: (value) {
                          setState(() {
                            _recorte = value!;
                          });
                        },
                      ),
                    ),
                    IntrinsicWidth(
                      child: RadioListTile(
                        title: const Text('Liang-Barsky'),
                        value: Recorte.liangBarsky,
                        groupValue: _recorte,
                        onChanged: (value) {
                          setState(() {
                            _recorte = value!;
                          });
                        },
                      ),
                    ),
                    IntrinsicWidth(
                      child: RadioListTile(
                        title: const Text('Espelhar X'),
                        value: EspelharXY.x,
                        groupValue: _xyEspelhar,
                        onChanged: (value) {
                          setState(() {
                            _xyEspelhar = value!;
                          });
                        },
                      ),
                    ),
                    IntrinsicWidth(
                      child: RadioListTile(
                        title: const Text('Espelhar Y'),
                        value: EspelharXY.y,
                        groupValue: _xyEspelhar,
                        onChanged: (value) {
                          setState(() {
                            _xyEspelhar = value!;
                          });
                        },
                      ),
                    ),
                    IntrinsicWidth(
                      child: RadioListTile(
                        title: const Text('Espelhar XY'),
                        value: EspelharXY.y,
                        groupValue: _xyEspelhar,
                        onChanged: (value) {
                          setState(() {
                            _xyEspelhar = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  color: Colors.red,
                  child: const Text('darius'),
                ),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: Transform.scale(
                      alignment: Alignment.topLeft,
                      origin: const Offset(-.5, -.5),
                      scale: scale,
                      child: GestureDetector(
                        onTapUp: _adicionarPontoObjeto,
                        child: CustomPaint(
                          painter: MyPainter(
                              todosObjetos, _recorte, _rasterizacao, _janela),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
