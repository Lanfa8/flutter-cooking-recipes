import 'package:flutter/material.dart';
import 'package:flutter_application_teste/screens/receita_editar_screen.dart';
import '/models/receita.dart';
import '/repositories/receita_repository.dart';
import '/screens/receita_detalhe_screen.dart';
import 'package:uuid/uuid.dart';

class ReceitaListScreen extends StatefulWidget {
  const ReceitaListScreen({super.key});
  @override
  State<ReceitaListScreen> createState() => _ReceitaListScreenState();
}

class _ReceitaListScreenState extends State<ReceitaListScreen> {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final Uuid _uuid = const Uuid();
  List<Receita> _receitas = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  Future<void> _carregarReceitas() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final receitasDoBanco = await _receitaRepository.todos();
      if (mounted) {
        setState(() {
          _receitas = receitasDoBanco;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar receitas: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatarTempoPreparoCurto(int minutos) {
    if (minutos <= 0) return 'N/D';
    if (minutos < 60) {
      return '$minutos min';
    } else {
      final horas = minutos ~/ 60;
      final minutosRestantes = minutos % 60;
      if (minutosRestantes == 0) {
        return '$horas h';
      } else {
        return '$horas h ${minutosRestantes} min';
      }
    }
  }

  Future<void> _navegarParaDetalhes(String receitaId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReceitaDetalheScreen(receitaId: receitaId),
      ),
    );
    if (result == true && mounted) {
      _carregarReceitas();
    }
  }

  Future<void> _navegarParaNovaReceita() async {
    final novaReceita = Receita(
      id: _uuid.v4(),
      nome: '',
      nota: 3,
      tempoPreparo: 0,
      createdAt: DateTime.now().toIso8601String(),
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReceitaEditarScreen(
              receita: novaReceita,
              ingredientes: [],
              passos: [],
              isNovaReceita: true,
            ),
      ),
    );
    if (result == true && mounted) {
      _carregarReceitas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Receitas')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarParaNovaReceita,
        tooltip: 'Adicionar Nova Receita',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_receitas.isEmpty) {
      return _buildEmptyState();
    }
    return _buildRecipeList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma receita cadastrada',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão + para adicionar sua\nprimeira receita deliciosa!',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    return RefreshIndicator(
      onRefresh: _carregarReceitas,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _receitas.length,
        itemBuilder: (context, index) {
          final receita = _receitas[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  receita.nome.isNotEmpty ? receita.nome[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                receita.nome.isNotEmpty ? receita.nome : "Receita sem nome",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Preparo: ${_formatarTempoPreparoCurto(receita.tempoPreparo)}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_basket_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${receita.totalIngredientes ?? 0} ingred.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.format_list_numbered,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${receita.totalPassos ?? 0} passos',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => _navegarParaDetalhes(receita.id),
            ),
          );
        },
      ),
    );
  }
}
