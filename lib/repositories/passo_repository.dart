import '/database/database_helper.dart';
import '/models/passo.dart';

class PassoRepository {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String TABELA = "passos";
  Future<int> adicionar(Passo passo) async {
    if (passo.instrucao.isEmpty ||
        passo.idReceita.isEmpty ||
        passo.ordem <= 0) {
      throw ArgumentError("Dados inválidos para adicionar Passo.");
    }
    return _dbHelper.inserir(TABELA, passo.toMap());
  }

  Future<int> atualizar(Passo passo) async {
    if (passo.id.isEmpty ||
        passo.instrucao.isEmpty ||
        passo.idReceita.isEmpty ||
        passo.ordem <= 0) {
      throw ArgumentError("Dados inválidos para atualizar Passo.");
    }
    return _dbHelper.atualizar(
      TABELA,
      passo.toMap(),
      condicao: 'id = ?',
      condicaoArgs: [passo.id],
    );
  }

  Future<int> remover(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("ID inválido para remover Passo.");
    }
    return _dbHelper.remover(TABELA, condicao: 'id = ?', condicaoArgs: [id]);
  }

  Future<int> removerPorReceita(String idReceita) async {
    if (idReceita.isEmpty) {
      throw ArgumentError("ID da Receita inválido para remover Passos.");
    }
    return _dbHelper.remover(
      TABELA,
      condicao: 'id_receita = ?',
      condicaoArgs: [idReceita],
    );
  }

  Future<Passo?> obterPorId(String id) async {
    if (id.isEmpty) return null;
    final resultadoMap = await _dbHelper.obterPorId(TABELA, 'id', id);
    return resultadoMap != null ? Passo.fromMap(resultadoMap) : null;
  }

  Future<List<Passo>> obterPorReceita(String idReceita) async {
    if (idReceita.isEmpty) return [];
    var passosMap = await _dbHelper.obterTodos(
      TABELA,
      condicao: 'id_receita = ?',
      condicaoArgs: [idReceita],
      orderBy: "ordem ASC",
    );
    List<Passo> listaDePassos = [];
    for (var map in passosMap) {
      try {
        listaDePassos.add(Passo.fromMap(map));
      } catch (e) {
        print("Erro ao converter mapa para Passo: $map. Erro: $e");
      }
    }
    return listaDePassos;
  }

  Future<List<Passo>> todos() async {
    var passosMap = await _dbHelper.obterTodos(TABELA, orderBy: "ordem ASC");
    List<Passo> listaDePassos = [];
    for (var map in passosMap) {
      try {
        listaDePassos.add(Passo.fromMap(map));
      } catch (e) {
        print("Erro ao converter mapa para Passo: $map. Erro: $e");
      }
    }
    return listaDePassos;
  }
}
