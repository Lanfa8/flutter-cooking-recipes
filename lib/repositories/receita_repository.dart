import '/database/database_helper.dart';
import '/models/receita.dart';

class ReceitaRepository {
  static final DatabaseHelper _db = DatabaseHelper();
  static const String TABELA = "receitas";
  Future<int> adicionar(Receita receita) async {
    return _db.inserir(TABELA, receita.toMap());
  }

  Future<int> atualizar(Receita receita) async {
    return _db.atualizar(
      TABELA,
      receita.toMap(),
      condicao: 'id = ?',
      condicaoArgs: [receita.id],
    );
  }

  Future<int> remover(String id) async {
    return _db.remover(TABELA, condicao: 'id = ?', condicaoArgs: [id]);
  }

  Future<Receita?> obterPorId(String id) async {
    if (id.isEmpty) return null;
    final resultadoMap = await _db.obterPorId(TABELA, 'id', id);
    if (resultadoMap != null) {
      try {
        return Receita.fromMap(resultadoMap);
      } catch (e) {
        print(
          "Erro ao converter mapa para Receita (ID: $id): $resultadoMap. Erro: $e",
        );
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<Receita>> todosComNotaAcimaDe(int nota) async {
    var receitasNoBanco = await _db.obterTodos(
      TABELA,
      condicao: 'nota >= ?',
      condicaoArgs: [nota],
    );
    List<Receita> listaDeReceita = [];
    for (var receita in receitasNoBanco) {
      listaDeReceita.add(Receita.fromMap(receita));
    }
    return listaDeReceita;
  }

  Future<List<Receita>> todos() async {
    var receitasMap = await _db.obterTodos(TABELA, orderBy: "nome ASC");
    List<Receita> listaDeReceita = [];
    const String tabelaIngredientes = "ingredientes";
    const String tabelaPassos = "passos";
    for (var receitaMap in receitasMap) {
      try {
        Receita receitaItem = Receita.fromMap(receitaMap);
        var ingredientes = await _db.obterTodos(
          tabelaIngredientes,
          condicao: 'id_receita = ?',
          condicaoArgs: [receitaItem.id],
        );
        var passos = await _db.obterTodos(
          tabelaPassos,
          condicao: 'id_receita = ?',
          condicaoArgs: [receitaItem.id],
        );
        receitaItem.totalIngredientes = ingredientes.length;
        receitaItem.totalPassos = passos.length;
        listaDeReceita.add(receitaItem);
      } catch (e) {
        print("Erro ao processar receita do mapa: $receitaMap. Erro: $e");
      }
    }
    return listaDeReceita;
  }
}
