import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_teste/repositories/receita_repository.dart';
import '/models/pessoa.dart';
import '/models/receita.dart';
import '/repositories/pessoa_repository.dart';
import '/repositories/receita_repository.dart';
import '/screens/pessoa_detalhe_screen.dart';
import 'package:uuid/uuid.dart';

class PessoaListScreen extends StatefulWidget {
  const PessoaListScreen({Key? key}) : super(key: key);

  @override
  _PessoaListScreenState createState() => _PessoaListScreenState();
}

class _PessoaListScreenState extends State<PessoaListScreen> {
  List<Pessoa> _pessoas = [];
  List<Receita> _receitas = [];
  PessoaRepository pessoaRepository = PessoaRepository();
  ReceitaRepository receitaRepository = ReceitaRepository();

  @override
  void initState() {
    super.initState();
    carregarPessoas();
  }

  void carregarPessoas() async {
    var pessoasBanco = await pessoaRepository.todosAbaixoDe(19);
    setState(() {
      _pessoas = pessoasBanco;
    });
  }

  void carregarReceitas() async {
    var receitasBanco = await receitaRepository.todosComNotaAcimaDe(3);
    setState(() {
      _receitas = receitasBanco;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receitas'),
      ),
      body: ListView.builder(
          itemCount: _receitas.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_receitas[index].nome),
              subtitle: Text(
                  "Nota: ${_receitas[index].nota} - Tempo de Preparo: ${_receitas[index].tempoPreparo} min - Criado em: ${_receitas[index].createdAt}"),
              // onTap: () {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) =>
              //               PessoaDetalheScreen(pessoa: _receitas[index])));
              // },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var id = Uuid();
          await pessoaRepository
              .adicionar(Pessoa(id: id.v1(), nome: id.v8(), idade: 19));
          carregarPessoas();

          await receitaRepository.adicionar(Receita(
              id: id.v1(),
              nome: "${id.v8()}Receita",
              nota: 3,
              tempoPreparo: 20));

          carregarReceitas();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
