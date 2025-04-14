import '/database/database_helper.dart';
import '/models/ingrediente.dart';

class IngredienteRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(Ingrediente ingrediente) async {
    return _db.inserir("INGREDIENTES", ingrediente.toMap());
  }

  Future<List<Ingrediente>> todosDaReceita(String idReceita) async {
    var ingredientesNoBanco = await _db
        .obterTodos("INGREDIENTES", condicao: 'ID_RECEITA = ?', condicaoArgs: [idReceita]);
    List<Ingrediente> listaDeIngrediente = [];

    for (var i = 0; i < ingredientesNoBanco.length; i++) {
      listaDeIngrediente.add(Ingrediente.fromMap(ingredientesNoBanco[i]));
    }

    return listaDeIngrediente;
  }

  Future<List<Ingrediente>> todos() async {
    var ingredientesNoBanco = await _db.obterTodos("INGREDIENTES");
    List<Ingrediente> listaDeIngrediente = [];

    for (var i = 0; i < ingredientesNoBanco.length; i++) {
      listaDeIngrediente.add(Ingrediente.fromMap(ingredientesNoBanco[i]));
    }

    return listaDeIngrediente;
  }

  Future<int> totalIngredientesDeUmaReceita(String idReceita) async {
    var ingredientesNoBanco = await todosDaReceita(idReceita);
    return ingredientesNoBanco.length;
  }
}
