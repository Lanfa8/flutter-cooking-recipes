import '/database/database_helper.dart';
import '/models/pessoa.dart';

class PessoaRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(Pessoa pessoa) async {
    return _db.inserir("PESSOAS", pessoa.toMap());
  }

  Future<List<Pessoa>> todosAbaixoDe(int idade) async {
    var pessoasNoBanco = await _db
        .obterTodos("PESSOAS", condicao: 'IDADE <= ?', condicaoArgs: [idade]);
    List<Pessoa> listaDePessoa = [];

    for (var i = 0; i < pessoasNoBanco.length; i++) {
      listaDePessoa.add(Pessoa.fromMap(pessoasNoBanco[i]));
    }

    return listaDePessoa;
  }

  Future<List<Pessoa>> todos() async {
    var pessoasNoBanco = await _db.obterTodos("PESSOAS");
    List<Pessoa> listaDePessoa = [];

    for (var i = 0; i < pessoasNoBanco.length; i++) {
      listaDePessoa.add(Pessoa.fromMap(pessoasNoBanco[i]));
    }

    return listaDePessoa;
  }
}
