import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/missao_provider.dart';
import '../models/missao.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tituloController = TextEditingController();
  String _dificuldadeSelecionada = 'Fácil';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MissaoProvider>().carregarMissoes());
  }

  String estrelas(String dificuldade) {
    switch (dificuldade) {
      case 'Fácil':
        return '⭐';
      case 'Médio':
        return '⭐⭐';
      case 'Difícil':
        return '⭐⭐⭐';
      default:
        return '';
    }
  }

  void _cadastrarMissao() async {
    if (_tituloController.text.trim().isEmpty) return;
    await context.read<MissaoProvider>().adicionarMissao(
          _tituloController.text.trim(),
          _dificuldadeSelecionada,
        );
    _tituloController.clear();
  }

  void _concluirMissao(Missao missao) async {
    await context.read<MissaoProvider>().concluirMissao(missao);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Missão concluída! Você conquistou ${missao.pontos} pontos.'),
        ),
      );
    }
  }

  void _excluirMissao(String id) async {
    await context.read<MissaoProvider>().excluirMissao(id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissaoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Central de Missões')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration:
                  const InputDecoration(labelText: 'Título da missão'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _dificuldadeSelecionada,
              items: const [
                DropdownMenuItem(value: 'Fácil', child: Text('Fácil')),
                DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                DropdownMenuItem(value: 'Difícil', child: Text('Difícil')),
              ],
              onChanged: (valor) {
                setState(() => _dificuldadeSelecionada = valor!);
              },
              decoration: const InputDecoration(labelText: 'Dificuldade'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _cadastrarMissao,
              child: const Text('CADASTRAR MISSÃO'),
            ),
            const Divider(height: 32),
            Text(
              'Pontuação total: ${provider.pontuacaoTotal}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: provider.missoes.length,
                itemBuilder: (context, index) {
                  final missao = provider.missoes[index];
                  return Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsPage(missao: missao),
                        ),
                      ),
                      title: Text(missao.titulo),
                      subtitle: Text(
                        '${estrelas(missao.dificuldade)} ${missao.dificuldade} - ${missao.pontos} pontos - ${missao.data}\nStatus: ${missao.concluida ? 'Concluída' : 'Pendente'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!missao.concluida)
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _concluirMissao(missao),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _excluirMissao(missao.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
