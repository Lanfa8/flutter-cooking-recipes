class PassoSql {
  static String criarTabelaPassos() {
    return '''CREATE TABLE passos (
          id TEXT PRIMARY KEY,
          id_receita TEXT NOT NULL,
          instrucao TEXT NOT NULL,
          ordem INTEGER NOT NULL,
          FOREIGN KEY (id_receita) REFERENCES receitas(id) ON DELETE CASCADE
        )''';
  }
}
