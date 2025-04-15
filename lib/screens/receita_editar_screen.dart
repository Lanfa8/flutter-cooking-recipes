import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '/models/receita.dart';
import '/models/ingrediente.dart';
import '/models/passo.dart';
import '/repositories/receita_repository.dart';
import '/repositories/ingrediente_repository.dart';
import '/repositories/passo_repository.dart';

class ReceitaEditarScreen extends StatefulWidget {
  final Receita receita;
  final List<Ingrediente> ingredientes;
  final List<Passo> passos;
  final bool isNovaReceita;
  const ReceitaEditarScreen({
    super.key,
    required this.receita,
    required this.ingredientes,
    required this.passos,
    required this.isNovaReceita,
  });
  @override
  State<ReceitaEditarScreen> createState() => _ReceitaEditarScreenState();
}

class _ReceitaEditarScreenState extends State<ReceitaEditarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tempoPreparoController = TextEditingController();
  late int _nota;
  late List<Ingrediente> _ingredientesEditaveis;
  late List<Passo> _passosEditaveis;
  late String _idReceita;
  late String _createdAt;
  bool _isSaving = false;
  bool _dadosForamAlterados = false;
  bool _saveSuccess = false;
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final IngredienteRepository _ingredienteRepository = IngredienteRepository();
  final PassoRepository _passoRepository = PassoRepository();
  final Uuid _uuid = const Uuid();
  @override
  void initState() {
    super.initState();
    _idReceita = widget.receita.id;
    _nomeController.text = widget.receita.nome;
    _tempoPreparoController.text =
        widget.receita.tempoPreparo > 0
            ? widget.receita.tempoPreparo.toString()
            : '';
    _nota = widget.receita.nota;
    _createdAt =
        widget.isNovaReceita
            ? DateTime.now().toIso8601String()
            : widget.receita.createdAt;
    _ingredientesEditaveis =
        widget.ingredientes
            .map((ing) => Ingrediente.fromMap(ing.toMap()))
            .toList();
    _passosEditaveis =
        widget.passos.map((p) => Passo.fromMap(p.toMap())).toList();
    _passosEditaveis.sort((a, b) => a.ordem.compareTo(b.ordem));
    _nomeController.addListener(_marcarAlterado);
    _tempoPreparoController.addListener(_marcarAlterado);
  }

  void _marcarAlterado() {
    if (!_dadosForamAlterados) {
      setState(() {
        _dadosForamAlterados = true;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.removeListener(_marcarAlterado);
    _tempoPreparoController.removeListener(_marcarAlterado);
    _nomeController.dispose();
    _tempoPreparoController.dispose();
    super.dispose();
  }

  void _adicionarIngrediente() {
    showDialog(
      context: context,
      builder:
          (context) => _IngredienteFormDialog(
            onSave: (nome, quantidade) {
              setState(() {
                _ingredientesEditaveis.add(
                  Ingrediente(
                    id: _uuid.v4(),
                    nome: nome,
                    quantidade: quantidade,
                    idReceita: _idReceita,
                  ),
                );
                _marcarAlterado();
              });
            },
          ),
    );
  }

  void _editarIngrediente(int index) {
    final ingredienteOriginal = _ingredientesEditaveis[index];
    showDialog(
      context: context,
      builder:
          (context) => _IngredienteFormDialog(
            nome: ingredienteOriginal.nome,
            quantidade: ingredienteOriginal.quantidade,
            onSave: (nome, quantidade) {
              setState(() {
                _ingredientesEditaveis[index] = Ingrediente(
                  id: ingredienteOriginal.id,
                  nome: nome,
                  quantidade: quantidade,
                  idReceita: _idReceita,
                );
                _marcarAlterado();
              });
            },
          ),
    );
  }

  void _removerIngrediente(int index) {
    setState(() {
      _ingredientesEditaveis.removeAt(index);
      _marcarAlterado();
    });
  }

  void _adicionarPasso() {
    int proximaOrdem = 1;
    if (_passosEditaveis.isNotEmpty) {
      proximaOrdem =
          _passosEditaveis.map((p) => p.ordem).reduce((a, b) => a > b ? a : b) +
          1;
    }
    showDialog(
      context: context,
      builder:
          (context) => _PassoFormDialog(
            ordemSugerida: proximaOrdem,
            onSave: (instrucao, ordem) {
              setState(() {
                _passosEditaveis.add(
                  Passo(
                    id: _uuid.v4(),
                    instrucao: instrucao,
                    ordem: ordem,
                    idReceita: _idReceita,
                  ),
                );
                _passosEditaveis.sort((a, b) => a.ordem.compareTo(b.ordem));
                _marcarAlterado();
              });
            },
          ),
    );
  }

  void _editarPasso(int index) {
    final passoOriginal = _passosEditaveis[index];
    showDialog(
      context: context,
      builder:
          (context) => _PassoFormDialog(
            instrucao: passoOriginal.instrucao,
            ordemAtual: passoOriginal.ordem,
            onSave: (instrucao, ordem) {
              setState(() {
                _passosEditaveis[index] = Passo(
                  id: passoOriginal.id,
                  instrucao: instrucao,
                  ordem: ordem,
                  idReceita: _idReceita,
                );
                _passosEditaveis.sort((a, b) => a.ordem.compareTo(b.ordem));
                _marcarAlterado();
              });
            },
          ),
    );
  }

  void _removerPasso(int index) {
    setState(() {
      _passosEditaveis.removeAt(index);
      _marcarAlterado();
    });
  }

  Future<void> _salvarReceita() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros no formulário.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_ingredientesEditaveis.isEmpty || _passosEditaveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um ingrediente e um passo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      final receitaParaSalvar = Receita(
        id: _idReceita,
        nome: _nomeController.text.trim(),
        nota: _nota,
        tempoPreparo: int.tryParse(_tempoPreparoController.text) ?? 0,
        createdAt: _createdAt,
      );
      if (widget.isNovaReceita) {
        await _receitaRepository.adicionar(receitaParaSalvar);
      } else {
        await _receitaRepository.atualizar(receitaParaSalvar);
        await _ingredienteRepository.removerPorReceita(receitaParaSalvar.id);
        await _passoRepository.removerPorReceita(receitaParaSalvar.id);
      }
      for (var ingrediente in _ingredientesEditaveis) {
        ingrediente.idReceita = receitaParaSalvar.id;
        await _ingredienteRepository.adicionar(ingrediente);
      }
      for (var passo in _passosEditaveis) {
        passo.idReceita = receitaParaSalvar.id;
        await _passoRepository.adicionar(passo);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _dadosForamAlterados = false;
          _saveSuccess = true;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar receita: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_dadosForamAlterados && !_saveSuccess) {
      final bool? sair = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Descartar Alterações?'),
              content: const Text(
                'Você fez alterações que não foram salvas. Deseja sair mesmo assim?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCELAR'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('DESCARTAR'),
                ),
              ],
            ),
      );
      return sair ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isNovaReceita ? 'Nova Receita' : 'Editar Receita'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context, _saveSuccess);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Salvar Receita',
              onPressed:
                  (_isSaving || !_dadosForamAlterados) ? null : _salvarReceita,
            ),
          ],
        ),
        body:
            _isSaving
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Salvando receita..."),
                    ],
                  ),
                )
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dados Principais',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _nomeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome da Receita *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.fastfood_outlined),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'O nome da receita é obrigatório';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _tempoPreparoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Tempo de Preparo (minutos) *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.timer_outlined),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Informe o tempo de preparo';
                                      }
                                      final tempo = int.tryParse(value);
                                      if (tempo == null || tempo <= 0) {
                                        return 'Informe um número válido maior que zero';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Nota:',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(5, (index) {
                                          return IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              index < _nota
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              if (_nota != index + 1) {
                                                setState(() {
                                                  _nota = index + 1;
                                                  _marcarAlterado();
                                                });
                                              }
                                            },
                                          );
                                        }),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ingredientes',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        onPressed: _adicionarIngrediente,
                                        tooltip: 'Adicionar Ingrediente',
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  _ingredientesEditaveis.isEmpty
                                      ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.0,
                                        ),
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            _ingredientesEditaveis.length,
                                        itemBuilder: (context, index) {
                                          final ingrediente =
                                              _ingredientesEditaveis[index];
                                          return ListTile(
                                            dense: true,
                                            leading: const Icon(
                                              Icons.fiber_manual_record,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                            title: Text(ingrediente.nome),
                                            subtitle: Text(
                                              ingrediente.quantidade,
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 22,
                                                  ),
                                                  onPressed:
                                                      () => _editarIngrediente(
                                                        index,
                                                      ),
                                                  tooltip: 'Editar Ingrediente',
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 22,
                                                    color: Colors.redAccent,
                                                  ),
                                                  onPressed:
                                                      () => _removerIngrediente(
                                                        index,
                                                      ),
                                                  tooltip:
                                                      'Remover Ingrediente',
                                                  visualDensity:
                                                      VisualDensity.compact,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Modo de Preparo',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        onPressed: _adicionarPasso,
                                        tooltip: 'Adicionar Passo',
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  _passosEditaveis.isEmpty
                                      ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.0,
                                        ),
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _passosEditaveis.length,
                                        itemBuilder: (context, index) {
                                          final passo = _passosEditaveis[index];
                                          return ListTile(
                                            dense: true,
                                            leading: CircleAvatar(
                                              radius: 13,
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              child: Text(
                                                '${passo.ordem}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              passo.instrucao,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 22,
                                                  ),
                                                  onPressed:
                                                      () => _editarPasso(index),
                                                  tooltip: 'Editar Passo',
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 22,
                                                    color: Colors.redAccent,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _removerPasso(index),
                                                  tooltip: 'Remover Passo',
                                                  visualDensity:
                                                      VisualDensity.compact,
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
                  ),
                ),
      ),
    );
  }
}

class _IngredienteFormDialog extends StatefulWidget {
  final String? nome;
  final String? quantidade;
  final Function(String nome, String quantidade) onSave;
  const _IngredienteFormDialog({
    this.nome,
    this.quantidade,
    required this.onSave,
  });
  @override
  State<_IngredienteFormDialog> createState() => _IngredienteFormDialogState();
}

class _IngredienteFormDialogState extends State<_IngredienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.nome ?? '';
    _quantidadeController.text = widget.quantidade ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.nome == null ? 'Novo Ingrediente' : 'Editar Ingrediente',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Ingrediente *',
                hintText: 'Ex: Farinha de trigo',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade *',
                hintText: 'Ex: 2 xícaras (chá)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a quantidade';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _nomeController.text.trim(),
                _quantidadeController.text.trim(),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('SALVAR'),
        ),
      ],
    );
  }
}

class _PassoFormDialog extends StatefulWidget {
  final String? instrucao;
  final int? ordemAtual;
  final int? ordemSugerida;
  final Function(String instrucao, int ordem) onSave;
  const _PassoFormDialog({
    this.instrucao,
    this.ordemAtual,
    this.ordemSugerida,
    required this.onSave,
  });
  @override
  State<_PassoFormDialog> createState() => _PassoFormDialogState();
}

class _PassoFormDialogState extends State<_PassoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _instrucaoController = TextEditingController();
  final _ordemController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _instrucaoController.text = widget.instrucao ?? '';
    _ordemController.text =
        (widget.ordemAtual ?? widget.ordemSugerida ?? 1).toString();
  }

  @override
  void dispose() {
    _instrucaoController.dispose();
    _ordemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.instrucao == null ? 'Novo Passo' : 'Editar Passo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ordemController,
              decoration: const InputDecoration(
                labelText: 'Nº do Passo *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o número do passo';
                }
                final ordem = int.tryParse(value);
                if (ordem == null || ordem <= 0) {
                  return 'Número inválido (deve ser > 0)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instrucaoController,
              decoration: const InputDecoration(
                labelText: 'Instrução *',
                hintText: 'Descreva o que fazer neste passo...',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a instrução';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _instrucaoController.text.trim(),
                int.parse(_ordemController.text),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('SALVAR'),
        ),
      ],
    );
  }
}
