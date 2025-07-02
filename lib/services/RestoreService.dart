import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_teste/database/database_helper.dart';
import 'package:flutter_application_teste/models/ingrediente.dart';
import 'package:flutter_application_teste/models/passo.dart';
import 'package:flutter_application_teste/models/receita.dart';
import 'package:flutter_application_teste/repositories/ingrediente_repository.dart';
import 'package:flutter_application_teste/repositories/passo_repository.dart';
import 'package:flutter_application_teste/repositories/receita_repository.dart';
import 'package:sqflite/sqflite.dart';

// Função para decodificar JSON em background
Map<String, dynamic> _parseJson(String jsonString) {
  return json.decode(jsonString) as Map<String, dynamic>;
}

class RestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper;
  final ReceitaRepository _receitaRepository;
  final IngredienteRepository _ingredienteRepository;
  final PassoRepository _passoRepository;

  // Construtor para receber as dependências
  RestoreService({
    required DatabaseHelper dbHelper,
    required ReceitaRepository receitaRepository,
    required IngredienteRepository ingredienteRepository,
    required PassoRepository passoRepository,
  })  : _dbHelper = dbHelper,
        _receitaRepository = receitaRepository,
        _ingredienteRepository = ingredienteRepository,
        _passoRepository = passoRepository;

  Future<Map<String, dynamic>?> getDataFromFile() async {
    // ... (este método continua igual)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      return compute(_parseJson, jsonString);
    }
    return null;
  }
  
  Future<Map<String, dynamic>?> getDataFromFirestore() async {
    // ... (este método continua igual)
     final backupQuery = await _firestore
        .collection('backups')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (backupQuery.docs.isNotEmpty) {
      final backupId = backupQuery.docs.first.id;
      final backupDocRef = _firestore.collection('backups').doc(backupId);

      final receitasSnapshot = await backupDocRef.collection('receitas').get();
      final ingredientesSnapshot = await backupDocRef.collection('ingredientes').get();
      final passosSnapshot = await backupDocRef.collection('passos').get();

      return {
        'receitas': receitasSnapshot.docs.map((doc) => doc.data()).toList(),
        'ingredientes': ingredientesSnapshot.docs.map((doc) => doc.data()).toList(),
        'passos': passosSnapshot.docs.map((doc) => doc.data()).toList(),
      };
    }
    return null;
  }


  /// Escreve os dados de backup no banco de dados local.
  /// Esta função deve ser chamada da thread principal.
  Future<bool> writeToDatabase(Map<String, dynamic> data) async {
    try {
      final dbPath = await _dbHelper.getDbPath();
      await _dbHelper.close(); // Fecha a conexão atual se houver
      await deleteDatabase(dbPath); // Apaga o arquivo antigo do banco

      // Recria o banco e as tabelas
      await _dbHelper.database; 

      final receitas = (data['receitas'] as List).map((r) => Receita.fromMap(r)).toList();
      final ingredientes = (data['ingredientes'] as List).map((i) => Ingrediente.fromMap(i)).toList();
      final passos = (data['passos'] as List).map((p) => Passo.fromMap(p)).toList();

      for (final receita in receitas) {
        await _receitaRepository.adicionar(receita);
      }
      for (final ingrediente in ingredientes) {
        await _ingredienteRepository.adicionar(ingrediente);
      }
      for (final passo in passos) {
        await _passoRepository.adicionar(passo);
      }
      return true;
    } catch (e) {
      print("Erro ao escrever no banco de dados: $e");
      return false;
    }
  }
}