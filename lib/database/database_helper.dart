import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/database/sqls/receita_sql.dart';
import '/database/sqls/ingrediente_sql.dart';
import '/database/sqls/passo_sql.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static Database? _database;
  static const String _nomeBancoDeDados = "receitas_flutter_v4.db";
  static const int _versaoBancoDeDados = 1;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String caminhoBanco = join(await getDatabasesPath(), _nomeBancoDeDados);
    return await openDatabase(
      caminhoBanco,
      version: _versaoBancoDeDados,
      onCreate: _criarBD,
      onUpgrade: _atualizaBD,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _criarBD(Database db, int version) async {
    await db.execute(ReceitaSql.criarTabelaReceitas());
    await db.execute(IngredienteSql.criarTabelaIngredientes());
    await db.execute(PassoSql.criarTabelaPassos());
  }

  Future<void> _atualizaBD(Database db, int oldVersion, int newVersion) async {
    print("Atualizando BD da versão $oldVersion para $newVersion");
  }

  Future<int> inserir(String tabela, Map<String, dynamic> valores) async {
    final db = await database;
    return await db.insert(tabela, valores);
  }

  Future<List<Map<String, dynamic>>> obterTodos(
    String tabela, {
    String? condicao,
    List<Object?>? condicaoArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      tabela,
      where: condicao,
      whereArgs: condicaoArgs,
      orderBy: orderBy,
    );
  }

  Future<int> atualizar(
    String tabela,
    Map<String, dynamic> valores, {
    String? condicao,
    List<Object?>? condicaoArgs,
  }) async {
    final db = await database;
    return await db.update(
      tabela,
      valores,
      where: condicao,
      whereArgs: condicaoArgs,
    );
  }

  Future<int> remover(
    String tabela, {
    String? condicao,
    List<Object?>? condicaoArgs,
  }) async {
    final db = await database;
    return await db.delete(tabela, where: condicao, whereArgs: condicaoArgs);
  }

  Future<Map<String, dynamic>?> obterPorId(
    String tabela,
    String idColuna,
    String id,
  ) async {
    final db = await database;
    List<Map<String, dynamic>> resultado = await db.query(
      tabela,
      columns: null,
      where: '$idColuna = ?',
      whereArgs: [id],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
