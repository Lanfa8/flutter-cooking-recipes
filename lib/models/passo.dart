import 'dart:convert';

class Passo {
  String id;
  String instrucao;
  int ordem;
  String idReceita;

  Passo({
    required this.id,
    required this.instrucao,
    required this.ordem,
    required this.idReceita,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'instrucao': instrucao,
      'ordem': ordem,
      'id_receita': idReceita,
    };
  }

  factory Passo.fromMap(Map<String, dynamic> map) {
    return Passo(
      id: map['id'] as String,
      instrucao: map['instrucao'] as String,
      ordem: map['ordem'] as int,
      idReceita: map['id_receita'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Passo.fromJson(String source) =>
      Passo.fromMap(json.decode(source) as Map<String, dynamic>);
}