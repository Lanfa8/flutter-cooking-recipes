class PessoaSql {
  static String criarTabelaPessoa() {
    return "create table pessoas (id text primary key, nome text not null, idade integer not null)";
  }
}
