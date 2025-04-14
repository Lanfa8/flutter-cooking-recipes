import 'package:flutter/material.dart';
import 'package:flutter_application_teste/models/ingrediente.dart';
import 'package:flutter_application_teste/repositories/ingrediente_repository.dart';
import 'package:flutter_application_teste/repositories/receita_repository.dart';
import 'package:flutter_application_teste/screens/receita_detalhe_screen.dart';
import '/models/receita.dart';
import '/repositories/receita_repository.dart';
import 'package:uuid/uuid.dart';


class ReceitaListScreen extends StatefulWidget {
  const ReceitaListScreen({Key? key}) : super(key: key);

  @override
  _ReceitaListScreenState createState() => _ReceitaListScreenState();
}

class _ReceitaListScreenState extends State<ReceitaListScreen> {
  List<Receita> _receitas = [];
  ReceitaRepository receitaRepository = ReceitaRepository();
  IngredienteRepository ingredienteRepository = IngredienteRepository();

  
  @override
  void initState() {
    super.initState();
    carregarReceitas();
  }
  
  void carregarReceitas() async {
    var receitasBanco = await receitaRepository.todosComNotaAcimaDe(3);

    for (var receita in receitasBanco) {
      var totalIngredientes = await ingredienteRepository.totalIngredientesDeUmaReceita(receita.id);
      receita.totalIngredientes = totalIngredientes;
    }

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
              trailing: Text("Ingredientes: ${_receitas[index].totalIngredientes}"),
              subtitle: Text("Tempo de Preparo: ${_receitas[index].tempoPreparo} min"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ReceitaDetalheScreen(receita: _receitas[index])));
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var id = Uuid();

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