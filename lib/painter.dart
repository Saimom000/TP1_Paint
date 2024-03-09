import 'dart:math';
import 'dart:ui' show Canvas, Offset, Paint, PointMode, Size;

import 'package:flutter/material.dart';

import 'classes.dart';
import 'enum.dart';

class MyPainter extends CustomPainter {
  // final List<Offset> points;
  final List<Objeto> todosObjetos;
  final Recorte recorte;
  final Rasterizacao rasterizacao;
  final Janela? janela;

  MyPainter(this.todosObjetos, this.recorte, this.rasterizacao, this.janela);

  @override
  void paint(Canvas canvas, Size size) {
    final j = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3;

    final b = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    // passa desenhando as reta
    if (janela!.abilitar == false || janela!.points.length < 2) {
      printarTodosObjetos(canvas, b);
    } else {
      desenhaObjeto(canvas, janela!);

      for (var objeto in todosObjetos) {
        if (objeto is! Circulo && objeto.points.length > 1) {
          cohenSutherlandObjeto(canvas, objeto);
        }
      }

      // for (var element in janela!.points) {
      //   canvas.drawCircle(element, 0.2, b);
      // }
      for (var point in todosObjetos) {
        for (var element in point.points) {
          canvas.drawCircle(element, 0.2, b);
        }
      }
    }
    if (janela!.abilitar == true) {
      for (var element in janela!.points) {
        canvas.drawCircle(element, 0.2, j);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void desenhaObjeto(Canvas canvas, Objeto objeto) {
    if (objeto.points.length > 1) {
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
  }

  void printarTodosObjetos(Canvas canvas, Paint b) {
    for (var objeto in todosObjetos) {
      desenhaObjeto(canvas, objeto);
    }
    // Desenhar os pontos clicados
    for (var point in todosObjetos) {
      for (var element in point.points) {
        canvas.drawCircle(element, 0.2, b);
      }
    }
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

  List<Offset> _desenharPontosCirculo(
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

    final raio = sqrt(pow((ponto2.dx.roundToDouble() - xc), 2) +
        pow((ponto2.dy.roundToDouble() - yc), 2));

    var x = 0.0, y = raio.roundToDouble(), p = 3 - 2 * raio;

    offsets.addAll(_desenharPontosCirculo(xc, yc, x, y));

    while (x < y) {
      if (p < 0) {
        p += 4 * x + 6;
      } else {
        p += 4 * (x - y) + 10;
        y--;
      }
      x++;
      offsets.addAll(_desenharPontosCirculo(xc, yc, x, y));
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

  int regionCode(
      double x, double y, double xmin, double xmax, double ymin, double ymax) {
    var codigo = 0;

    if (x < xmin) {
      codigo++;
    }

    if (x > xmax) {
      codigo += 2;
    }

    if (y < ymin) {
      codigo += 4;
    }

    if (y > ymax) {
      codigo += 8;
    }

    return codigo;
  }

  void cohenSutherlandObjeto(Canvas canvas, Objeto objeto) {
    final objetoJanela = Objeto(false, objeto.paint);

    final xmim = min(janela!.points.first.dx.roundToDouble(),
        janela!.points.elementAt(2).dx.roundToDouble());
    final xmax = max(janela!.points.first.dx.roundToDouble(),
        janela!.points.elementAt(2).dx.roundToDouble());
    final ymin = min(janela!.points.first.dy.roundToDouble(),
        janela!.points.elementAt(2).dy.roundToDouble());
    final ymax = max(janela!.points.first.dy.roundToDouble(),
        janela!.points.elementAt(2).dy.roundToDouble());

    for (var i = 1; i < objeto.points.length; i++) {
      objetoJanela.points.addAll(cohenSutherland(objeto.points.elementAt(i - 1),
          objeto.points.elementAt(i), xmim, xmax, ymin, ymax));
    }
    if (objeto.fechar) {
      objetoJanela.points.addAll(cohenSutherland(
          objeto.points.last, objeto.points.first, xmim, xmax, ymin, ymax));
    }
    desenhaObjeto(canvas, objetoJanela);
  }

  List<Offset> cohenSutherland(Offset ponto1, Offset ponto2, double xmim,
      double xmax, double ymin, double ymax) {
    final offsets = <Offset>[];
    var aceite = false, feito = false;

    var x1 = ponto1.dx.roundToDouble();
    var y1 = ponto1.dy.roundToDouble();
    var x2 = ponto2.dx.roundToDouble();
    var y2 = ponto2.dy.roundToDouble();

    //Limites da janela
    var p1 = Offset(x1, y1);
    var p2 = Offset(x2, y2);

    while (!feito) {
      var c1 = regionCode(p1.dx, p1.dy, xmim, xmax, ymin, ymax);
      var c2 = regionCode(p2.dx, p2.dy, xmim, xmax, ymin, ymax);
      if (c1 == 0 && c2 == 0) {
        // Segmento completamente dentro
        aceite = true;
        feito = true;
      } else if (c1 & c2 != 0) {
        // Segmento completamente fora
        feito = true;
      } else {
        var cfora = c1 != 0 ? c1 : c2; // Determina um ponto exterior
        double xint = 0.0, yint = 0.0;
        if (cfora & 1 == 1) {
          // Limite esquerdo
          xint = xmim;
          yint = p1.dy + (p2.dy - p1.dy) * (xmim - p1.dx) / (p2.dx - p1.dx);
        } else if (cfora & 2 == 2) {
          // Limite direito
          xint = xmax;
          yint = p1.dy + (p2.dy - p1.dy) * (xmax - p1.dx) / (p2.dx - p1.dx);
        } else if (cfora & 4 == 4) {
          yint = ymin;
          xint = p1.dx + (p2.dx - p1.dx) * (ymin - p1.dy) / (p2.dy - p1.dy);
        } else if (cfora & 8 == 8) {
          yint = ymax;
          xint = p1.dx + (p2.dx - p1.dx) * (ymax - p1.dy) / (p2.dy - p1.dy);
        }

        if (c1 == cfora) {
          p1 = Offset(xint.roundToDouble(), yint.roundToDouble());
        } else {
          p2 = Offset(xint.roundToDouble(), yint.roundToDouble());
        }
      }
      if (aceite) {
        offsets.add(p1);
        offsets.add(p2);
      }
    }

    return offsets;
  }
}
