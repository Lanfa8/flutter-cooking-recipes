import 'package:flutter/material.dart';
import '/models/receita.dart';

class ReceitaDetalheScreen extends StatefulWidget {
  const ReceitaDetalheScreen({super.key, required this.receita});

  final Receita receita;

  @override
  _ReceitaDetalheScreenState createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text(widget.receita.nome),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nota: ${widget.receita.nota}'),
              Text('Tempo de Preparo: ${widget.receita.tempoPreparo} min'),
            ],
          ),
      ),
    );
  }
}
