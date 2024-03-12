import 'package:flutter/material.dart';

class Janela extends Objeto {
  var abilitar = false;
  Janela(super.fechar, super.paint);
}

class Circulo extends Objeto {
  Circulo(super.fechar, super.paint);
}

class Objeto {
  final List<Offset> points = [];
  var fechar = false;
  Paint paint;
  Objeto(this.fechar, this.paint);

  (Offset, Offset) retornaExtremos() {
    if (points.isNotEmpty) {
      var xmim = points.first.dx;
      var ymim = points.first.dy;
      var xmax = points.first.dx;
      var ymax = points.first.dy;
      for (var point in points) {
        if (xmim > point.dx) {
          xmim = point.dx;
        }
        if (xmax < point.dx) {
          xmax = point.dx;
        }
        if (ymim > point.dy) {
          ymim = point.dy;
        }
        if (ymax < point.dy) {
          ymax = point.dy;
        }
      }
      return (Offset(xmim, ymim), Offset(xmax, ymax));
    }
    return (const Offset(0, 0), const Offset(0, 0));
  }
}

// Classe para colocar os Botoes com Icone no Canvas
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
    return Tooltip(
      message: descricao,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: corBotao),
        onPressed: funcao,
        child: Icon(
          iconItem,
          color: cor,
        ),
      ),
    );
  }
}
