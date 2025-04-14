import 'package:flutter/material.dart';
import 'package:flutter_application_teste/repositories/ingrediente_repository.dart';
import 'package:flutter_application_teste/repositories/passo_repository.dart';
import '/models/receita.dart';
import '/models/ingrediente.dart';
import '/models/passo.dart';

class ReceitaDetalheScreen extends StatefulWidget {
  const ReceitaDetalheScreen({super.key, required this.receita});

  final Receita receita;

  @override
  _ReceitaDetalheScreenState createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  List<Ingrediente> _ingredientes = List.empty();
  List<Passo> _passos = List.empty();
  IngredienteRepository ingredienteRepository = IngredienteRepository();
  PassoRepository passoRepository = PassoRepository();

  @override
  void initState() {
    super.initState();
    carregarPassos();
    carregarIngredientes();
  }

  void carregarPassos() async {
    var passosBanco = await passoRepository.todosDaReceita(widget.receita.id);

    setState(() {
      _passos = passosBanco;
    });
  }

  void carregarIngredientes() async {
    var ingredientesBanco = await ingredienteRepository.todosDaReceita(
      widget.receita.id,
    );

    setState(() {
      _ingredientes = ingredientesBanco;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receita.nome)),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.receita.nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tempo de Preparo: ${widget.receita.tempoPreparo} min'),
                Text('Nota: ${widget.receita.nota}'),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Ingredientes",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Flexible(
              flex: 4,
              child: ListView.builder(
                itemCount: _ingredientes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_ingredientes[index].nome),
                    trailing: Text('Qtd: ${_ingredientes[index].quantidade}'),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Passos",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Flexible(
              flex: 4,
              child: ListView.builder(
                itemCount: _passos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${index + 1}. ${_passos[index].instrucao}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
