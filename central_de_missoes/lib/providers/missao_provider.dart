import 'package:flutter/material.dart';
import '../models/missao.dart';
import '../services/missao_service.dart';

class MissaoProvider extends ChangeNotifier {
  final MissaoService _service = MissaoService();

  List<Missao> _missoes = [];
  List<Missao> get missoes => _missoes;

  int get pontuacaoTotal => _missoes
      .where((m) => m.concluida)
      .fold(0, (soma, m) => soma + m.pontos);

  Future<void> carregarMissoes() async {
    _missoes = await _service.buscarTodas();
    notifyListeners();
  }

  int calcularPontos(String dificuldade) {
    switch (dificuldade) {
      case 'Fácil':
        return 10;
      case 'Médio':
        return 20;
      case 'Difícil':
        return 30;
      default:
        return 0;
    }
  }

  Future<void> adicionarMissao(String titulo, String dificuldade) async {
    final pontos = calcularPontos(dificuldade);
    final agora = DateTime.now();
    final dataAtual =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    final missao = Missao(
      titulo: titulo,
      dificuldade: dificuldade,
      pontos: pontos,
      concluida: false,
      data: dataAtual,
    );
    await _service.adicionar(missao);
    await carregarMissoes();
  }

  Future<void> concluirMissao(Missao missao) async {
    await _service.atualizar(missao.id!, {'concluida': true});
    await carregarMissoes();
  }

  Future<void> excluirMissao(String id) async {
    await _service.excluir(id);
    await carregarMissoes();
  }
}
