// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Pessoa {
  String id;
  String nome;
  int idade;

  Pessoa({required this.id, required this.nome, required this.idade});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'idade': idade,
    };
  }

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
      id: map['nome'] as String,
      nome: map['nome'] as String,
      idade: map['idade'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Pessoa.fromJson(String source) =>
      Pessoa.fromMap(json.decode(source) as Map<String, dynamic>);
}
