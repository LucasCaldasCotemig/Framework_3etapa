import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/produto_provider.dart';

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  bool _salvando = false;

  Future<void> _cadastrar() async {
    final quantidade = int.tryParse(_quantidadeController.text.trim());
    final preco = double.tryParse(_precoController.text.trim().replaceAll(',', '.'));

    if (_nomeController.text.trim().isEmpty ||
        _categoriaController.text.trim().isEmpty ||
        quantidade == null ||
        preco == null) {
      return;
    }

    setState(() => _salvando = true);

    await context.read<ProdutoProvider>().cadastrar(
      _nomeController.text.trim(),
      _categoriaController.text.trim(),
      quantidade,
      preco,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produto')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _categoriaController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _precoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _salvando ? null : _cadastrar,
                  child: const Text('CADASTRAR PRODUTO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
