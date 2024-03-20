import 'dart:math' as math;

// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'objetos.dart';
import 'enum.dart';
import 'painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  final todosObjetos = <Objeto>[];
  static const movimentoTela = 5.0;
  static const tamanhoPixel = 1.0;

  final _controller1 = TextEditingController()..text = "0";
  final _controller2 = TextEditingController()..text = "1";

  // Serve para interligar o ultimo pixel do objeto ao primeiro, ou seja, fechar o objeto
  var fechar = false;

  var _rasterizacao = Rasterizacao.dda;
  var _recorte = Recorte.sohenSutherland;
  final _formKey = GlobalKey<FormState>();

  _MyHomePageState() {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 121, 137, 255)
      ..strokeWidth = tamanhoPixel;
    _objetoAtual = Objeto(fechar, _corObjetos(null));
    todosObjetos.add(_objetoAtual!);
    _janela = Janela(true, paint);
  }

  final viewTransformationController = TransformationController();

  // Definir ponto inicial de zoom
  @override
  void initState() {
    const zoomFactor = 50.0;
    const xTranslate = 300.0;
    const yTranslate = 300.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
    super.initState();
  }

  // A cor padão dos objetos é preta
  Paint _corObjetos(Color? cor) {
    final paint = Paint();
    if (cor == null) {
      paint
        ..color = Colors.black
        ..strokeWidth = tamanhoPixel;
    } else {
      paint
        ..color = cor
        ..strokeWidth = tamanhoPixel;
    }

    return paint;
  }

  void _criarObjeto() {
    if (_objetoAtual!.points.isEmpty) {
      todosObjetos.remove(_objetoAtual);
    }
    // O fechar indica se o objeto deve ligar o ultimo ponto ao primeiro ponto
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
    // Para criar a janela so é necessario 2 pontos,
    // os outros 2 pontos para fechar o retangulo são criados automaticamente.
    if (_janela!.points.length == 2) {
      _janela!.points
          .insert(1, Offset(_janela!.points.last.dx, _janela!.points.first.dy));
      _janela!.points
          .add(Offset(_janela!.points.first.dx, _janela!.points.last.dy));
    }
  }

  // A cade clique na tela um ponto é criado, que passa por esse metodo para adicionar os pontos.
  void _adicionarPontoObjeto(TapUpDetails details) {
    setState(() {
      // Adicionar os pontos clicados a Janela de Recorte
      if (_janela!.abilitar && _janela!.points.length < 2) {
        _adicionarPontoJanela(details);
      } else {
        if (_objetoAtual is! Circulo) {
          // Um Objeto normal pode ter varios pontos.
          _objetoAtual?.points.add(details.localPosition);
        } else if (_objetoAtual!.points.length < 2) {
          // o Circulo pode ter no maximo 2 pontos.
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
      _objetoAtual!.points.clear();
      todosObjetos.add(_objetoAtual!);
    });
  }

  // Botão para criar objeto so com linhas.
  void _botaoObjetoLinha() {
    setState(() {
      fechar = false;
      _criarObjeto();
    });
  }

  // Botão para criar objeto que liga o ultimo ponto ao primeiro ponto.
  void _botaoObjetoAtualFechar() {
    setState(() {
      fechar = true;
      _criarObjeto();
    });
  }

  // Botão para criar objeto do tipo circulo.
  void _botaoCirculo() {
    setState(() {
      fechar = false;
      _criarCirculo();
    });
  }

  // Volta o ultimo ponto clicado do objeto atual.
  // Caso o objetoAtual fiquei sem pontos, o ultimo
  // objeto inserido em todosObjetos vira o novo objetoAtual.
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

  void _criarJanela() {
    setState(() {
      if (_janela!.abilitar) {
        // Desabilita a janela para ser mostrada e limpa os seus ponto.
        _janela!.points.clear();
        _janela!.abilitar = false;
      } else {
        // Habilita a janela para selecionar os 2 pontos.
        _janela!.abilitar = true;
      }
    });
  }

  // Move todos os objetos da tela.
  void _mover(double x, double y) {
    setState(() {
      for (var objeto in todosObjetos) {
        for (var p = 0; p < objeto.points.length; p++) {
          objeto.points[p] = objeto.points[p].translate(x, y);
        }
      }
    });
  }

  // Espelha um Objeto no eixo Y.
  void _botaoEspelharObjetoY() {
    _espelharObjeto(true);
  }

  // Espelha um Objeto no eixo X.
  void _botaoEspelharObjetoX() {
    _espelharObjeto(false);
  }

  // Espelhar o objetoAtual no eixo y ou x.
  void _espelharObjeto(bool eixoY) {
    if (_objetoAtual!.points.length > 1) {
      setState(() {
        if (_objetoAtual is! Circulo) {
          final offsets = <Offset>[];

          var (mim, max) = _objetoAtual!.retornaExtremos();

          if (eixoY) {
            var xmedia = (mim.dx + max.dx) / 2;

            for (var point in _objetoAtual!.points) {
              offsets.add(Offset(-(point.dx - xmedia) + xmedia, point.dy));
            }
          } else {
            var ymedia = (mim.dy + max.dy) / 2;

            for (var point in _objetoAtual!.points) {
              offsets.add(Offset(point.dx, -(point.dy - ymedia) + ymedia));
            }
          }

          _objetoAtual!.points.clear();
          _objetoAtual!.points.addAll(offsets);
        }
      });
    }
  }

  // Muda a escala somente do objeto atual
  void _mudarEscalaObjeto(double escala) {
    if (_objetoAtual!.points.length > 1 && escala != 1) {
      setState(() {
        if (_objetoAtual is! Circulo) {
          final offsets = <Offset>[];

          var (mim, max) = _objetoAtual!.retornaExtremos();

          // Representa um ponto central no objeto
          var xmedia = (mim.dx + max.dx) / 2;
          var ymedia = (mim.dy + max.dy) / 2;

          for (var point in _objetoAtual!.points) {
            offsets.add(Offset((point.dx - xmedia) * escala + xmedia,
                (point.dy - ymedia) * escala + ymedia));
          }

          _objetoAtual!.points.clear();
          _objetoAtual!.points.addAll(offsets);
        } else {
          _objetoAtual!.points.add(Offset(_objetoAtual!.points.last.dx * escala,
              _objetoAtual!.points.last.dy * escala));
          _objetoAtual!.points.removeAt(1);
        }
      });
    }
  }

  // Girar somente o objeto atual
  void _mudarGrauObjeto(int graus) {
    if (_objetoAtual!.points.length > 1 && graus > 0) {
      if (_objetoAtual is! Circulo) {
        setState(() {
          final offsets = <Offset>[];

          var (mim, max) = _objetoAtual!.retornaExtremos();

          // Representa um ponto central no objeto
          var xmedia = (mim.dx + max.dx) / 2;
          var ymedia = (mim.dy + max.dy) / 2;
          var grausDouble = graus * (math.pi / 180);

          for (var point in _objetoAtual!.points) {
            final p1 = (point.dx - xmedia);
            final p2 = (point.dy - ymedia);
            final sin = math.sin(grausDouble);
            final cos = math.cos(grausDouble);

            offsets.add(
              Offset(
                p1 * cos - p2 * sin + xmedia,
                p1 * sin + p2 * cos + ymedia,
              ),
            );
          }

          _objetoAtual!.points.clear();
          _objetoAtual!.points.addAll(offsets);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('É o desenhas'),
      ),
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          // Utilizar as setinhas do teclado para mover todos os objetos da tela
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
            _mover(-movimentoTela, 0);
          },
          const SingleActivator(LogicalKeyboardKey.arrowRight): () {
            _mover(movimentoTela, 0);
          },
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            _mover(0, -movimentoTela);
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            _mover(0, movimentoTela);
          },
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          // onPointerSignal: (pointerSignal) {
          //   // if (pointerSignal is PointerScrollEvent) {
          //   //   if (pointerSignal.scrollDelta.dy > 0) {
          //   //     _mudarZoom(-2);
          //   //   } else if (pointerSignal.scrollDelta.dy < 0) {
          //   //     _mudarZoom(2);
          //   //   }
          //   // }
          // },
          child: Focus(
            autofocus: true,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        IconItem(Icons.remove, 'Linhas', Colors.white,
                            Colors.blue, _botaoObjetoLinha),
                        IconItem(
                            Icons.check_box_outline_blank,
                            'Objeto fechado',
                            Colors.white,
                            Colors.blue,
                            _botaoObjetoAtualFechar),
                        IconItem(Icons.circle_outlined, 'Circulo', Colors.white,
                            Colors.blue, _botaoCirculo),
                        IconItem(Icons.auto_mode, 'Desfazer', Colors.white,
                            Colors.red, _voltaPasso),
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
                        IconItem(
                            Icons.branding_watermark_outlined,
                            'Criar Janela de Recorte',
                            Colors.white,
                            Colors.blue,
                            _criarJanela),
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
                        IconItem(Icons.flip, 'Espelhar Y', Colors.white,
                            Colors.blue, _botaoEspelharObjetoY),
                        IconItem(MdiIcons.flipVertical, 'Espelhar X',
                            Colors.white, Colors.blue, _botaoEspelharObjetoX),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                              obscureText: false,
                              controller: _controller1,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Graus',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onFieldSubmitted: (value) {
                                _formKey.currentState?.validate();
                              },
                              validator: (value) {
                                value ??= "0";
                                if (value.isEmpty) {
                                  return 'Main darius.';
                                }

                                final a = int.parse(value);

                                if (a < 0 || a > 360) {
                                  _controller1.text = '0';
                                  return 'Main darius.';
                                }
                                _mudarGrauObjeto(a);
                                _controller1.text = '0';
                                return null;
                              }),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            obscureText: false,
                            controller: _controller2,
                            // onSubmitted: _mudarEscalaObjeto,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Escala Objeto',
                            ),
                            keyboardType: TextInputType.number,

                            onFieldSubmitted: (value) {
                              _formKey.currentState?.validate();
                            },
                            validator: (value) {
                              value ??= "1";
                              if (value.isEmpty) {
                                _controller2.text = '1';
                                return 'Main darius.';
                              }
                              final a = double.tryParse(value);

                              if (a == null || a <= 0) {
                                _controller2.text = '1';
                                return 'Main darius.';
                              }
                              _mudarEscalaObjeto(a);
                              _controller2.text = '1';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.red,
                    child: const Text('darius'),
                  ),
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: InteractiveViewer(
                        transformationController: viewTransformationController,
                        minScale: 0.1,
                        maxScale: 100,
                        // alignment: Alignment.center,
                        // scale: scale,
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
      ),
    );
  }
}
