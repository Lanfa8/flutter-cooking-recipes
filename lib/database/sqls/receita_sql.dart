class ReceitaSql {
  static String criarTabelaReceitas() {
    return "create table receitas (" 
        "id text primary key, "
        "nome text not null, "
        "nota integer not null, " 
        "tempo_preparo integer not null, " 
        "created_at text default current_timestamp " 
      ")";
  }
}
