class PassoSql {
  static String criarTabelaPassos() {
    return "create table passos (" 
        "id text primary key, "
        "id_receita text not null, " 
        "instrucao text not null, "
        "ordem integer not null " 
      ")";
  }
}