import 'package:flutter_application_teste/database/sqls/ingrediente_sql.dart';
import 'package:flutter_application_teste/database/sqls/passo_sql.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/database/sqls/receita_sql.dart';

class DatabaseHelper {
  static final String _nomeBancoDeDados = "receitas_flutter_3.db";
  static final int _versaoBancoDeDados = 1;
  static late Database _bancoDeDados;

  inicializar() async {
    String caminhoBanco = join(await getDatabasesPath(), _nomeBancoDeDados);
    _bancoDeDados = await openDatabase(
      caminhoBanco,
      version: _versaoBancoDeDados,
      onCreate: criarBD,
      onUpgrade: atualizaBD,
    );
  }

  Future criarBD(Database db, int versao) async {
    db.execute(ReceitaSql.criarTabelaReceitas());
    db.execute(IngredienteSql.criarTabelaIngredientes());
    db.execute(PassoSql.criarTabelaPassos());
  }

  Future atualizaBD(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 2) {}
  }

  Future<int> inserir(String tabela, Map<String, Object?> valores) async {
    await inicializar();
    return await _bancoDeDados.insert(tabela, valores);
  }

  Future<List<Map<String, Object?>>> obterTodos(String tabela,
      {String? condicao, List<Object>? condicaoArgs, String? orderBy}) async {
    await inicializar();
    return await _bancoDeDados.query(tabela,
        where: condicao, whereArgs: condicaoArgs, orderBy: orderBy);
  }

}
