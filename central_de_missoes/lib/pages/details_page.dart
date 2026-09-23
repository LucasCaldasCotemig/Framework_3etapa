import 'package:flutter/material.dart';
import '../models/missao.dart';

class DetailsPage extends StatelessWidget {
  final Missao missao;

  const DetailsPage({super.key, required this.missao});

  String get estrelas {
    switch (missao.dificuldade) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Missão')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título:', style: Theme.of(context).textTheme.titleMedium),
            Text(missao.titulo,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Dificuldade:',
                style: Theme.of(context).textTheme.titleMedium),
            Text('$estrelas ${missao.dificuldade}'),
            const SizedBox(height: 16),
            Text('Pontos:', style: Theme.of(context).textTheme.titleMedium),
            Text('${missao.pontos}'),
            const SizedBox(height: 16),
            Text('Status:', style: Theme.of(context).textTheme.titleMedium),
            Text(missao.concluida ? 'Concluída' : 'Pendente'),
            const SizedBox(height: 16),
            Text('Data:', style: Theme.of(context).textTheme.titleMedium),
            Text(missao.data),
          ],
        ),
      ),
    );
  }
}
