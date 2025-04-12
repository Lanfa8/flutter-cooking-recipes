import 'package:flutter/material.dart';
import '/models/pessoa.dart';

class PessoaDetalheScreen extends StatefulWidget {
  const PessoaDetalheScreen({super.key, required this.pessoa});

  final Pessoa pessoa;

  @override
  _PessoaDetalheScreenState createState() => _PessoaDetalheScreenState();
}

class _PessoaDetalheScreenState extends State<PessoaDetalheScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhe'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              Text('ID ${widget.pessoa.id}'),
              Text('Nome ${widget.pessoa.nome}'),
              Text('Idade ${widget.pessoa.idade}'),
            ],
          )),
        ),
      ),
    );
  }
}
