import '/database/database_helper.dart';
import '/models/passo.dart';

class PassoRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(Passo passo) async {
    return _db.inserir("PASSOS", passo.toMap());
  }

  Future<List<Passo>> todosDaReceita(String idReceita) async {
    var passosNoBanco = await _db
        .obterTodos("PASSOS", condicao: 'ID_RECEITA = ?', condicaoArgs: [idReceita], orderBy: "ORDEM");
    List<Passo> listaDePasso = [];

    for (var i = 0; i < passosNoBanco.length; i++) {
      listaDePasso.add(Passo.fromMap(passosNoBanco[i]));
    }

    return listaDePasso;
  }

  Future<List<Passo>> todos() async {
    var passosNoBanco = await _db.obterTodos("PASSOS");
    List<Passo> listaDePasso = [];

    for (var i = 0; i < passosNoBanco.length; i++) {
      listaDePasso.add(Passo.fromMap(passosNoBanco[i]));
    }

    return listaDePasso;
  }
}
