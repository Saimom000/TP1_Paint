import 'dart:math';
import 'dart:ui' show Canvas, Clip, Offset, Paint, PointMode, Size;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

enum Rasterizacao {
  dda,
  bresenham,
}

enum Recorte {
  sohenSutherland,
  liangBarsky,
}

/////////////////////////

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class IconItem extends StatelessWidget {
  final IconData iconItem;
  final String descricao;
  final Color cor;
  final Color corBotao;
  final Function() funcao;

  const IconItem(
      this.iconItem, this.descricao, this.cor, this.corBotao, this.funcao,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Tooltip(
          message: descricao,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: corBotao),
            onPressed: funcao,
            child: Icon(
              iconItem,
              color: cor,
            ),
          ),
        ));
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Objeto? _objetoAtual;

  // final todosObjetos = <Objeto>[];
  List<Objeto> todosObjetos = [];
  var scale = 60.0;
  static const movimentoTela = 5.0;
  var pixel = 1.0;
  var rastAlg = false;
  var recoAlg = false;
  var fechar = false;

  var _rasterizacao = Rasterizacao.dda;
  var _recorte = Recorte.sohenSutherland;

  _MyHomePageState() {
    _criarObjeto();
  }

  Paint _corObjetos() {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = pixel;
    return paint;
  }

  void _criarObjeto() {
    _objetoAtual = Objeto(fechar, _corObjetos());
    todosObjetos.add(_objetoAtual!);
  }

  void _criarCirculo() {
    _objetoAtual = Circulo(fechar, _corObjetos());
    todosObjetos.add(_objetoAtual!);
  }

  void _adicionarPontoObjeto(TapUpDetails details) {
    setState(() {
      if (_objetoAtual is! Circulo) {
        _objetoAtual?.points.add(details.localPosition);
      } else if (_objetoAtual!.points.length < 2) {
        _objetoAtual?.points.add(details.localPosition);
      } else {
        _criarCirculo();
        _objetoAtual?.points.add(details.localPosition);
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
      } else {
        todosObjetos.removeLast();
        if (todosObjetos.isNotEmpty) {
          _objetoAtual = todosObjetos.last;
          _objetoAtual!.points.removeLast();
        }
      }
    });
  }

  void _mudarEscala(int i) {
    setState(() {
      scale += i;
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
                        Colors.white, Colors.blue, _botaoCirculo),

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
                          painter:
                              MyPainter(todosObjetos, rastAlg, _rasterizacao),
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

class MyPainter extends CustomPainter {
  // final List<Offset> points;
  final List<Objeto> todosObjetos;
  final bool rastAlg;
  final Rasterizacao rasterizacao;

  MyPainter(this.todosObjetos, this.rastAlg, this.rasterizacao);

  @override
  void paint(Canvas canvas, Size size) {
    final b = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    // passa desenhando as reta
    for (var objeto in todosObjetos) {
      if (objeto is! Circulo) {
        if (rasterizacao == Rasterizacao.dda) {
          _objetosDDA(canvas, objeto.paint, objeto);
        } else {
          _objetosBresenham(canvas, objeto.paint, objeto);
        }
      } else {
        _ciculoBresenham(canvas, objeto.paint, objeto);
      }
    }
    // Desenhar os pontos clicados
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

  void _objetosDDA(Canvas canvas, Paint paint, Objeto objeto) {
    for (var i = 1; i < objeto.points.length; i++) {
      var novosPontos =
          _calcularRetaDDA(objeto.points[i - 1], objeto.points[i]);

      for (var element in novosPontos) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
    if (objeto.fechar) {
      var novosPontosFechar =
          _calcularRetaDDA(objeto.points[0], objeto.points.last);

      for (var element in novosPontosFechar) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
  }

  void _objetosBresenham(Canvas canvas, Paint paint, Objeto objeto) {
    for (var i = 1; i < objeto.points.length; i++) {
      var novosPontos =
          _calcularRetaBresenham(objeto.points[i - 1], objeto.points[i]);

      for (var element in novosPontos) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
    if (objeto.fechar) {
      var novosPontosFechar =
          _calcularRetaBresenham(objeto.points[0], objeto.points.last);

      for (var element in novosPontosFechar) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
  }

  void _ciculoBresenham(Canvas canvas, Paint paint, Objeto objeto) {
    if (objeto.points.length == 2) {
      var novosPontos =
          _calcularCiculoBresenham(objeto.points[0], objeto.points[1]);

      for (var element in novosPontos) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
  }

  List<Offset> _plotCirclePoints(
    double xc,
    double yc,
    double x,
    double y,
  ) {
    final offsets = <Offset>[];
    offsets.add(Offset(xc + x, yc + y));
    offsets.add(Offset(xc - x, yc + y));
    offsets.add(Offset(xc + x, yc - y));
    offsets.add(Offset(xc - x, yc - y));

    offsets.add(Offset(xc + y, yc + x));
    offsets.add(Offset(xc - y, yc + x));
    offsets.add(Offset(xc + y, yc - x));
    offsets.add(Offset(xc - y, yc - x));

    return offsets;
  }

  List<Offset> _calcularCiculoBresenham(Offset ponto1, Offset ponto2) {
    final offsets = <Offset>[];

    final xc = ponto1.dx.roundToDouble(), yc = ponto1.dy.roundToDouble();

    final raio = sqrt(pow((ponto2.dx.roundToDouble() - xc), 2) -
        pow((ponto2.dy.roundToDouble() - yc), 2));

    var x = 0.0, y = raio.roundToDouble(), p = 3 - 2 * raio;

    offsets.addAll(_plotCirclePoints(xc, yc, x, y));

    while (x < y) {
      if (p < 0) {
        p += 4 * x + 6;
      } else {
        p += 4 * (x - y) + 10;
        y--;
      }
      x++;
      offsets.addAll(_plotCirclePoints(xc, yc, x, y));
    }

    return offsets;
  }

  List<Offset> _calcularRetaDDA(Offset ponto1, Offset ponto2) {
    final offsets = <Offset>[];

    var x = ponto1.dx.roundToDouble();
    var y = ponto1.dy.roundToDouble();

    final dx = ponto2.dx.roundToDouble() - x;
    final dy = ponto2.dy.roundToDouble() - y;

    final passos = dx.abs() > dy.abs() ? dx.abs() : dy.abs();

    final xIncr = dx / passos;
    final yIncr = dy / passos;

    offsets.add(Offset(x, y));

    for (var k = 0; k < passos.roundToDouble(); k++) {
      x += xIncr;
      y += yIncr;
      offsets.add(Offset(x.roundToDouble(), y.roundToDouble()));
    }

    return offsets;
  }

  List<Offset> _calcularRetaBresenham(Offset ponto1, Offset ponto2) {
    final offsets = <Offset>[];

    var x = ponto1.dx.roundToDouble();
    var y = ponto1.dy.roundToDouble();

    var dx = ponto2.dx.roundToDouble() - x;
    var dy = ponto2.dy.roundToDouble() - y;

    final xincr = dx > 0 ? 1 : -1;
    final yincr = dy > 0 ? 1 : -1;

    dx *= xincr;
    dy *= yincr;

    offsets.add(Offset(x, y));
    if (dx > dy) {
      var p = 2 * dy - dx, c1 = 2 * dy, c2 = 2 * (dy - dx);

      for (var i = 0; i < dx; i++) {
        x += xincr;
        if (p < 0) {
          p += c1;
        } else {
          p += c2;
          y += yincr;
        }
        offsets.add(Offset(x, y));
      }
    } else {
      var p = 2 * dx - dy, c1 = 2 * dx, c2 = 2 * (dx - dy);

      for (var i = 0; i < dy; i++) {
        y += yincr;
        if (p < 0) {
          p += c1;
        } else {
          p += c2;
          x += xincr;
        }
        offsets.add(Offset(x, y));
      }
    }

    return offsets;
  }
}

class Circulo extends Objeto {
  Circulo(super.fechar, super.paint);
}

class Objeto {
  final List<Offset> points = [];
  var fechar = false;
  Paint paint;
  Objeto(this.fechar, this.paint);
}
