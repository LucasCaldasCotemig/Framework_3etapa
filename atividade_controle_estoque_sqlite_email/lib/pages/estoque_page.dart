import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../providers/produto_provider.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProdutoProvider>().carregar();
      context.read<ProdutoProvider>().mostrarNoTerminal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProdutoProvider>();
    final produtos = provider.produtos;

    return Scaffold(
      appBar: AppBar(title: const Text('ESTOQUE')),
      body: provider.carregando
          ? const Center(child: CircularProgressIndicator())
          : produtos.isEmpty
              ? const Center(child: Text('Nenhum produto cadastrado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return _ProdutoCard(produto: produto);
                  },
                ),
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final Produto produto;

  const _ProdutoCard({required this.produto});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProdutoProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              produto.nome,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(produto.categoria),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => provider.decrementarQuantidade(produto),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('Quantidade: ${produto.quantidade}'),
                IconButton(
                  onPressed: () => provider.incrementarQuantidade(produto),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
            if (produto.estoqueBaixo)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'ESTOQUE BAIXO',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => provider.excluir(produto),
                child: const Text('EXCLUIR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
