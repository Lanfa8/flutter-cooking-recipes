class IngredienteSql {
  static String criarTabelaIngredientes() {
    return "create table ingredientes (" 
        "id text primary key, "
        "id_receita integer not null, " 
        "nome text not null, "
        "quantidade text not null " 
      ")";
  }
}
