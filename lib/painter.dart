import 'dart:math';
import 'dart:ui' show Canvas, Offset, Paint, PointMode, Size;

import 'package:flutter/material.dart';

import 'objetos.dart';
import 'enum.dart';

// Classe onder os principais algoritimos de colorir os pontos são implementados
class MyPainter extends CustomPainter {
  final List<Objeto> todosObjetos;
  final Recorte recorte;
  final Rasterizacao rasterizacao;
  final Janela? janela;

  // Passando todos os objetos de paramentro
  // O tipo de recorte que vai ser utilizada em todos os objetos sohenSutherland ou liangBarsky,
  // O tipo de rasterizacao que vai ser utilizada em todos os objetos dda ou bresenham
  // A janela de recorte
  MyPainter(this.todosObjetos, this.recorte, this.rasterizacao, this.janela);

  @override
  void paint(Canvas canvas, Size size) {
    final corJanelaPontos = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3;

    final corObjetosPontos = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    // Caso a janela não esteja completa, ou abilitada, todos os objetos são coloridos no Canvas
    if (janela!.abilitar == false || janela!.points.length < 2) {
      desenharTodosObjetos(canvas);
    } else {
      // Desenha a janela de recorte
      desenhaObjeto(canvas, janela!);

      for (var objeto in todosObjetos) {
        recorteJanela(canvas, objeto);
      }
    }

    // Desenhar os pontos clicados
    for (var objeto in todosObjetos) {
      for (var element in objeto.points) {
        canvas.drawCircle(element, 0.2, corObjetosPontos);
      }
    }
    // Desenhar os pontos clicados da janela de recorte
    if (janela!.abilitar) {
      for (var element in janela!.points) {
        canvas.drawCircle(element, 0.2, corJanelaPontos);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void desenhaObjeto(
    Canvas canvas,
    Objeto objeto,
  ) {
    // É necessario que o Objeto tenha pelo menos 2 pontos para ser desenhado
    if (objeto.points.length > 1) {
      if (objeto is! Circulo) {
        // Todos os objetos utilizam o mesmo algoritimo de rasterizacao
        if (rasterizacao == Rasterizacao.dda) {
          _objetoDDA(canvas, objeto.paint, objeto);
        } else {
          _objetoBresenham(canvas, objeto.paint, objeto);
        }
      } else {
        _circuloBresenham(canvas, objeto.paint, objeto);
      }
    }
  }

  void desenharTodosObjetos(
    Canvas canvas,
  ) {
    for (var objeto in todosObjetos) {
      desenhaObjeto(canvas, objeto);
    }
  }

  void _objetoDDA(
    Canvas canvas,
    Paint paint,
    Objeto objeto,
  ) {
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

  void _objetoBresenham(
    Canvas canvas,
    Paint paint,
    Objeto objeto,
  ) {
    for (var i = 1; i < objeto.points.length; i++) {
      var novosPontos = _calcularRetaBresenham(
        objeto.points[i - 1],
        objeto.points[i],
      );

      for (var element in novosPontos) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
    if (objeto.fechar) {
      var novosPontosFechar = _calcularRetaBresenham(
        objeto.points[0],
        objeto.points.last,
      );

      for (var element in novosPontosFechar) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
  }

  void _circuloBresenham(
    Canvas canvas,
    Paint paint,
    Objeto objeto,
  ) {
    if (objeto.points.length == 2) {
      var novosPontos = _calcularCirculoBresenham(
        objeto.points[0],
        objeto.points[1],
      );

      for (var element in novosPontos) {
        canvas.drawPoints(PointMode.points, [element], paint);
      }
    }
  }

  List<Offset> _calcularRetaDDA(
    Offset ponto1,
    Offset ponto2,
  ) {
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

  List<Offset> _calcularRetaBresenham(
    Offset ponto1,
    Offset ponto2,
  ) {
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

  List<Offset> _gerarPontosCirculo(
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

  List<Offset> _calcularCirculoBresenham(
    Offset ponto1,
    Offset ponto2,
  ) {
    final offsets = <Offset>[];

    final xc = ponto1.dx.roundToDouble(), yc = ponto1.dy.roundToDouble();

    final raio = sqrt(pow((ponto2.dx.roundToDouble() - xc), 2) +
        pow((ponto2.dy.roundToDouble() - yc), 2));

    var x = 0.0, y = raio.roundToDouble(), p = 3 - 2 * raio;

    offsets.addAll(_gerarPontosCirculo(xc, yc, x, y));

    while (x < y) {
      if (p < 0) {
        p += 4 * x + 6;
      } else {
        p += 4 * (x - y) + 10;
        y--;
      }
      x++;
      offsets.addAll(_gerarPontosCirculo(xc, yc, x, y));
    }

    return offsets;
  }

  int codigoRegiao(
    double x,
    double y,
    double xmin,
    double xmax,
    double ymin,
    double ymax,
  ) {
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

  // Algoritimos de recorte
  void recorteJanela(
    Canvas canvas,
    Objeto objeto,
  ) {
    // Circulos não aparecem no recorte
    if (objeto is! Circulo && objeto.points.length > 1) {
      // Todos os objetos utilizam o mesmo algoritimo de recorte
      if (recorte == Recorte.sohenSutherland) {
        cohenSutherlandObjeto(canvas, objeto);
      } else {
        liangBarskyObjeto(canvas, objeto);
      }
    }
  }

  (bool, double, double) clipSet(
    double p,
    double q,
    double u1,
    double u2,
  ) {
    var result = true;
    final r = q / p;

    if (p < 0) {
      //fora para dentro
      if (r > u2) {
        result = false;
      } else if (r > u1) {
        u1 = r;
      }
    } else if (p > 0) {
      // dentro para fora
      // var r = q / p;

      if (r < u1) {
        result = false;
      } else if (r < u2) {
        u2 = r;
      }
    } else if (q < 0) {
      result = false;
    }

    return (result, u1, u2);
  }

  void liangBarskyObjeto(
    Canvas canvas,
    Objeto objeto,
  ) {
    final (xmin, xmax, ymin, ymax) = minMaxJanela();
    for (var i = 1; i < objeto.points.length; i++) {
      final objetoJanela = Objeto(false, objeto.paint)
        ..points.addAll(
          liangBarsky(
            objeto.points.elementAt(i - 1),
            objeto.points.elementAt(i),
            xmin,
            xmax,
            ymin,
            ymax,
          ),
        );
      desenhaObjeto(canvas, objetoJanela);
    }
    if (objeto.fechar) {
      final objetoJanela = Objeto(false, objeto.paint)
        ..points.addAll(
          liangBarsky(
            objeto.points.last,
            objeto.points.first,
            xmin,
            xmax,
            ymin,
            ymax,
          ),
        );
      desenhaObjeto(canvas, objetoJanela);
    }
  }

  List<Offset> liangBarsky(
    Offset ponto1,
    Offset ponto2,
    double xmin,
    double xmax,
    double ymin,
    double ymax,
  ) {
    final offsets = <Offset>[];
    var u1 = 0.0, u2 = 1.0;
    var verificar = false;

    var x1 = ponto1.dx.roundToDouble(), y1 = ponto1.dy.roundToDouble();
    var x2 = ponto2.dx.roundToDouble(), y2 = ponto2.dy.roundToDouble();

    var dx = x2 - x1;
    var dy = y2 - y1;

    (verificar, u1, u2) = clipSet(-1 * dx, x1 - xmin, u1, u2);
    if (verificar) {
      (verificar, u1, u2) = clipSet(dx, xmax - x1, u1, u2);
      if (verificar) {
        (verificar, u1, u2) = clipSet(-1 * dy, y1 - ymin, u1, u2);
        if (verificar) {
          (verificar, u1, u2) = clipSet(dy, ymax - y1, u1, u2);
          if (verificar) {
            if (u2 < 1.0) {
              x2 = x1 + u2 * dx;
              y2 = y1 + u2 * dy;
            }
            if (u1 > 0) {
              x1 = x1 + u1 * dx;
              y1 = y1 + u1 * dy;
            }
            offsets.add(Offset(x1.roundToDouble(), y1.roundToDouble()));
            offsets.add(Offset(x2.roundToDouble(), y2.roundToDouble()));
          }
        }
      }
    }

    return offsets;
  }

  // Saber as dimensoes maximas e minimas da janela de recorte.
  // Somente os pontos clicados são utilizados para descobrir os valores,
  // pois as outras 2 pontas são criados em consequencia deles.
  (double, double, double, double) minMaxJanela() {
    final xmin = min(
      janela!.points.first.dx,
      janela!.points.elementAt(2).dx,
    );
    final xmax = max(
      janela!.points.first.dx,
      janela!.points.elementAt(2).dx,
    );
    final ymin = min(
      janela!.points.first.dy,
      janela!.points.elementAt(2).dy,
    );
    final ymax = max(
      janela!.points.first.dy,
      janela!.points.elementAt(2).dy,
    );

    return (
      xmin.roundToDouble(),
      xmax.roundToDouble(),
      ymin.roundToDouble(),
      ymax.roundToDouble(),
    );
  }

  void cohenSutherlandObjeto(
    Canvas canvas,
    Objeto objeto,
  ) {
    final (xmin, xmax, ymin, ymax) = minMaxJanela();

    for (var i = 1; i < objeto.points.length; i++) {
      final objetoJanela = Objeto(false, objeto.paint)
        ..points.addAll(
          cohenSutherland(
            objeto.points.elementAt(i - 1),
            objeto.points.elementAt(i),
            xmin,
            xmax,
            ymin,
            ymax,
          ),
        );
      desenhaObjeto(canvas, objetoJanela);
    }
    if (objeto.fechar) {
      final objetoJanela = Objeto(false, objeto.paint)
        ..points.addAll(
          cohenSutherland(
            objeto.points.last,
            objeto.points.first,
            xmin,
            xmax,
            ymin,
            ymax,
          ),
        );
      desenhaObjeto(canvas, objetoJanela);
    }
  }

  List<Offset> cohenSutherland(
    Offset ponto1,
    Offset ponto2,
    double xmin,
    double xmax,
    double ymin,
    double ymax,
  ) {
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
      var c1 = codigoRegiao(p1.dx, p1.dy, xmin, xmax, ymin, ymax);
      var c2 = codigoRegiao(p2.dx, p2.dy, xmin, xmax, ymin, ymax);
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
          xint = xmin;
          yint = p1.dy + (p2.dy - p1.dy) * (xmin - p1.dx) / (p2.dx - p1.dx);
        } else if (cfora & 2 == 2) {
          // Limite direito
          xint = xmax;
          yint = p1.dy + (p2.dy - p1.dy) * (xmax - p1.dx) / (p2.dx - p1.dx);
        } else if (cfora & 4 == 4) {
          // Limite baixo
          yint = ymin;
          xint = p1.dx + (p2.dx - p1.dx) * (ymin - p1.dy) / (p2.dy - p1.dy);
        } else if (cfora & 8 == 8) {
          // Limite acima
          yint = ymax;
          xint = p1.dx + (p2.dx - p1.dx) * (ymax - p1.dy) / (p2.dy - p1.dy);
        }

        if (c1 == cfora) {
          p1 = Offset(xint, yint);
        } else {
          p2 = Offset(xint, yint);
        }
      }
      if (aceite) {
        offsets.add(Offset(p1.dx.roundToDouble(), p1.dy.roundToDouble()));
        offsets.add(Offset(p2.dx.roundToDouble(), p2.dy.roundToDouble()));
      }
    }

    return offsets;
  }
}
