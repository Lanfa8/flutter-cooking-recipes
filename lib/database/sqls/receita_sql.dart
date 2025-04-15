class ReceitaSql {
  static String criarTabelaReceitas() {
    return '''CREATE TABLE receitas (
          id TEXT PRIMARY KEY,
          nome TEXT NOT NULL,
          nota INTEGER NOT NULL,
          tempo_preparo INTEGER NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )''';
  }
}
