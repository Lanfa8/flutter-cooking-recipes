import '/database/database_helper.dart';
import '/models/ingrediente.dart';

class IngredienteRepository {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String TABELA = "ingredientes";
  Future<int> adicionar(Ingrediente ingrediente) async {
    if (ingrediente.nome.trim().isEmpty ||
        ingrediente.quantidade.trim().isEmpty ||
        ingrediente.idReceita.isEmpty) {
      throw ArgumentError(
        "Dados inválidos para adicionar Ingrediente (nome, quantidade e idReceita são obrigatórios).",
      );
    }
    if (ingrediente.id.isEmpty) {
      throw ArgumentError("ID do Ingrediente não pode ser vazio ao adicionar.");
    }
    return _dbHelper.inserir(TABELA, ingrediente.toMap());
  }

  Future<int> atualizar(Ingrediente ingrediente) async {
    if (ingrediente.id.isEmpty ||
        ingrediente.nome.trim().isEmpty ||
        ingrediente.quantidade.trim().isEmpty ||
        ingrediente.idReceita.isEmpty) {
      throw ArgumentError(
        "Dados inválidos para atualizar Ingrediente (ID, nome, quantidade e idReceita são obrigatórios).",
      );
    }
    return _dbHelper.atualizar(
      TABELA,
      ingrediente.toMap(),
      condicao: 'id = ?',
      condicaoArgs: [ingrediente.id],
    );
  }

  Future<int> remover(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("ID inválido para remover Ingrediente.");
    }
    return _dbHelper.remover(TABELA, condicao: 'id = ?', condicaoArgs: [id]);
  }

  Future<int> removerPorReceita(String idReceita) async {
    if (idReceita.isEmpty) {
      throw ArgumentError("ID da Receita inválido para remover Ingredientes.");
    }
    return _dbHelper.remover(
      TABELA,
      condicao: 'id_receita = ?',
      condicaoArgs: [idReceita],
    );
  }

  Future<Ingrediente?> obterPorId(String id) async {
    if (id.isEmpty) return null;
    final resultadoMap = await _dbHelper.obterPorId(TABELA, 'id', id);
    if (resultadoMap != null) {
      try {
        return Ingrediente.fromMap(resultadoMap);
      } catch (e) {
        print(
          "Erro ao converter mapa para Ingrediente (ID: $id): $resultadoMap. Erro: $e",
        );
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<Ingrediente>> obterPorReceita(String idReceita) async {
    if (idReceita.isEmpty) return [];
    var ingredientesMap = await _dbHelper.obterTodos(
      TABELA,
      condicao: 'id_receita = ?',
      condicaoArgs: [idReceita],
      orderBy: "nome ASC",
    );
    List<Ingrediente> listaDeIngredientes = [];
    for (var map in ingredientesMap) {
      try {
        listaDeIngredientes.add(Ingrediente.fromMap(map));
      } catch (e) {
        print(
          "Erro ao converter mapa para Ingrediente (Receita ID: $idReceita): $map. Erro: $e",
        );
      }
    }
    return listaDeIngredientes;
  }

  Future<List<Ingrediente>> todos() async {
    var ingredientesMap = await _dbHelper.obterTodos(
      TABELA,
      orderBy: "nome ASC",
    );
    List<Ingrediente> listaDeIngredientes = [];
    for (var map in ingredientesMap) {
      try {
        listaDeIngredientes.add(Ingrediente.fromMap(map));
      } catch (e) {
        print(
          "Erro ao converter mapa para Ingrediente (método todos): $map. Erro: $e",
        );
      }
    }
    return listaDeIngredientes;
  }
}
