class IngredienteSql {
  static String criarTabelaIngredientes() {
    return '''CREATE TABLE ingredientes (
          id TEXT PRIMARY KEY,
          id_receita TEXT NOT NULL,
          nome TEXT NOT NULL,
          quantidade TEXT NOT NULL,
          FOREIGN KEY (id_receita) REFERENCES receitas(id) ON DELETE CASCADE
        )''';
  }
}
