import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/receita.dart';
import '/models/ingrediente.dart';
import '/models/passo.dart';
import '/repositories/receita_repository.dart';
import '/repositories/ingrediente_repository.dart';
import '/repositories/passo_repository.dart';
import 'receita_editar_screen.dart';

class ReceitaDetalheScreen extends StatefulWidget {
  final String? receitaId;
  const ReceitaDetalheScreen({super.key, required this.receitaId});
  @override
  State<ReceitaDetalheScreen> createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final IngredienteRepository _ingredienteRepository = IngredienteRepository();
  final PassoRepository _passoRepository = PassoRepository();
  Receita? _receita;
  List<Ingrediente> _ingredientes = [];
  List<Passo> _passos = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    if (widget.receitaId == null || widget.receitaId!.isEmpty) {
      _setErrorState('Erro: ID da receita inválido.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } else {
      _loadReceitaDetails();
    }
  }

  void _setErrorState(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadReceitaDetails() async {
    if (!mounted || widget.receitaId == null || widget.receitaId!.isEmpty)
      return;
    if (!_isLoading || _hasError) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
        _receita = null;
        _ingredientes = [];
        _passos = [];
      });
    }
    try {
      final receita = await _receitaRepository.obterPorId(widget.receitaId!);
      if (!mounted) return;
      if (receita == null) {
        _setErrorState('Receita não encontrada.');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
        return;
      }
      final results = await Future.wait([
        _ingredienteRepository.obterPorReceita(widget.receitaId!),
        _passoRepository.obterPorReceita(widget.receitaId!),
      ]);
      if (!mounted) return;
      final ingredientes = results[0] as List<Ingrediente>;
      final passos = results[1] as List<Passo>;
      setState(() {
        _receita = receita;
        _ingredientes = ingredientes;
        _passos = passos;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print("Erro detalhado ao carregar receita: ${e.toString()}");
      _setErrorState('Erro ao carregar detalhes da receita.');
    }
  }

  String _formatarTempoPreparo(int minutos) {
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

  String _formatDataAdicionada(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(data);
    } catch (e) {
      print("Erro ao formatar data: $dataIso - $e");
      return 'Data inválida';
    }
  }

  Widget _buildEstrelas(int nota) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < nota ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }

  Future<void> _navegarParaEditar() async {
    if (_receita == null || _isLoading || _hasError) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReceitaEditarScreen(
              receita: _receita!,
              ingredientes: _ingredientes,
              passos: _passos,
              isNovaReceita: false,
            ),
      ),
    );
    if (result == true && mounted) {
      _loadReceitaDetails();
    }
  }

  Future<void> _confirmarExclusao() async {
    if (_receita == null || _isLoading || _hasError) return;
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Tem certeza que deseja excluir a receita "${_receita!.nome}"? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('EXCLUIR'),
              ),
            ],
          ),
    );
    if (confirmar == true) {
      _excluirReceita();
    }
  }

  Future<void> _excluirReceita() async {
    if (_receita == null || !mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _receitaRepository.remover(_receita!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Erro ao excluir receita: ${e.toString()}");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir receita: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_hasError) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: Colors.red.shade800),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                onPressed: _loadReceitaDetails,
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_receita == null) {
      bodyContent = const Center(child: Text('Receita não disponível.'));
    } else {
      bodyContent = RefreshIndicator(
        onRefresh: _loadReceitaDetails,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _receita!.nome,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildEstrelas(_receita!.nota),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Preparo: ${_formatarTempoPreparo(_receita!.tempoPreparo)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Adicionada em: ${_formatDataAdicionada(_receita!.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ingredientes (${_ingredientes.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      _ingredientes.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                'Nenhum ingrediente adicionado.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _ingredientes.length,
                            itemBuilder: (context, index) {
                              final ingrediente = _ingredientes[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Icon(
                                        Icons.fiber_manual_record,
                                        size: 8,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${ingrediente.quantidade} ${ingrediente.nome}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.integration_instructions_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Modo de Preparo (${_passos.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      _passos.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                'Nenhum passo adicionado.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _passos.length,
                            itemBuilder: (context, index) {
                              final passo = _passos[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        '${passo.ordem}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        passo.instrucao,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading
              ? 'Carregando Receita...'
              : (_hasError
                  ? 'Erro ao Carregar'
                  : (_receita?.nome ?? 'Detalhes')),
        ),
        actions:
            (_isLoading || _hasError || _receita == null)
                ? []
                : [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: _navegarParaEditar,
                    tooltip: 'Editar Receita',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _confirmarExclusao,
                    tooltip: 'Excluir Receita',
                  ),
                ],
      ),
      body: bodyContent,
    );
  }
}
