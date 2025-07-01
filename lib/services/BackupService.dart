import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_teste/repositories/ingrediente_repository.dart';
import 'package:flutter_application_teste/repositories/passo_repository.dart';
import 'package:flutter_application_teste/repositories/receita_repository.dart';
import 'package:intl/intl.dart';

class BackupService {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final IngredienteRepository _ingredienteRepository = IngredienteRepository();
  final PassoRepository _passoRepository = PassoRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<Map<String, dynamic>> _getAllData() async {
    final receitas = await _receitaRepository.todos();
    final ingredientes = await _ingredienteRepository.todos();
    final passos = await _passoRepository.todos();

    return {
      'receitas': receitas.map((r) => r.toMap()).toList(),
      'ingredientes': ingredientes.map((i) => i.toMap()).toList(),
      'passos': passos.map((p) => p.toMap()).toList(),
    };
  }

  Future<bool> backupToFile() async {
    try {
      final allData = await _getAllData();
      final jsonString = json.encode(allData);

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'receitas_backup_$timestamp.json';

      String? resultPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Selecione o local para salvar o backup',
      );

      if (resultPath != null) {
        final filePath = '$resultPath/$fileName';
        final file = File(filePath);
        await file.writeAsString(jsonString);
        return true;
      }
      return false;
    } catch (e) {
      print("Erro ao fazer backup para arquivo: $e");
      return false;
    }
  }
    Future<bool> backupToFirestore() async {
    try {
      final allData = await _getAllData();
      final batch = _firestore.batch();

      final timestamp = DateTime.now();
      final backupId = 'backup_${timestamp.toIso8601String()}';
      final backupDocRef = _firestore.collection('backups').doc(backupId);


      batch.set(backupDocRef, {
        'createdAt': timestamp,
        'recipeCount': (allData['receitas'] as List).length,
        'ingredientCount': (allData['ingredientes'] as List).length,
        'stepCount': (allData['passos'] as List).length,
      });


      for (var receita in (allData['receitas'] as List<Map<String, dynamic>>)) {
        final receitaRef = backupDocRef.collection('receitas').doc(receita['id']);
        batch.set(receitaRef, receita);
      }

      for (var ingrediente in (allData['ingredientes'] as List<Map<String, dynamic>>)) {
        final ingredienteRef = backupDocRef.collection('ingredientes').doc(ingrediente['id']);
        batch.set(ingredienteRef, ingrediente);
      }

      for (var passo in (allData['passos'] as List<Map<String, dynamic>>)) {
        final passoRef = backupDocRef.collection('passos').doc(passo['id']);
        batch.set(passoRef, passo);
      }

      await batch.commit();
      return true;

    } catch (e) {
      print("Erro ao fazer backup para o Firestore: $e");
      return false;
    }
  }

}
