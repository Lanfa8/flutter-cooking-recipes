import '/database/database_helper.dart';
import '/models/receita.dart';

class ReceitaRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(Receita receita) async {
    return _db.inserir("RECEITAS", receita.toMap());
  }

  Future<List<Receita>> todosComNotaAcimaDe(int nota) async {
    var receitasNoBanco = await _db
        .obterTodos("RECEITAS", condicao: 'NOTA >= ?', condicaoArgs: [nota]);
    List<Receita> listaDeReceita = [];

    for (var i = 0; i < receitasNoBanco.length; i++) {
      listaDeReceita.add(Receita.fromMap(receitasNoBanco[i]));
    }

    return listaDeReceita;
  }

  Future<List<Receita>> todos() async {
    var receitasNoBanco = await _db.obterTodos("RECEITAS");
    List<Receita> listaDeReceita = [];

    for (var i = 0; i < receitasNoBanco.length; i++) {
      listaDeReceita.add(Receita.fromMap(receitasNoBanco[i]));
    }

    return listaDeReceita;
  }
}