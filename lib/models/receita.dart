import 'dart:convert';

class Receita {
  String id;
  String nome;
  int nota;
  int tempoPreparo;
  int? totalIngredientes;
  int? totalPassos;
  String createdAt;
  Receita({
    required this.id,
    required this.nome,
    required this.nota,
    required this.tempoPreparo,
    this.totalIngredientes,
    this.totalPassos,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'nota': nota,
      'tempo_preparo': tempoPreparo,
      'created_at': createdAt,
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'] as String,
      nome: map['nome'] as String,
      nota: map['nota'] as int,
      tempoPreparo: map['tempo_preparo'] as int,
      createdAt:
          map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
  String toJson() => json.encode(toMap());
  factory Receita.fromJson(String source) =>
      Receita.fromMap(json.decode(source) as Map<String, dynamic>);
}
