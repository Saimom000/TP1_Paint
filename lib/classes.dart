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
