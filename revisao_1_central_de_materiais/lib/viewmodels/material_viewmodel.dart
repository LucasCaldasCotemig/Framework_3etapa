// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
// Nesta versão só os comentários foram acrescentados; o código deste arquivo é o original.
// ViewModel: fica entre a tela e o repositório. Aplica as regras do negócio
// (validar, impedir nome repetido) e avisa a tela quando a lista mudou.
import 'package:flutter/foundation.dart';
import '../models/material_evento.dart';
import '../repositories/material_repository.dart';
import '../utils/validadores.dart';

// A ViewModel coordena regras, persistência e atualização da interface.
// ChangeNotifier permite que a tela "escute" e se redesenhe ao mudar a lista.
class MaterialViewModel extends ChangeNotifier {
  final MaterialRepository repository;
  // Lista em memória, espelho do que está no banco.
  List<MaterialEvento> _materiais = [];
  // A tela só lê a lista (unmodifiable): para mudar, precisa passar pela ViewModel.
  List<MaterialEvento> get materiais => List.unmodifiable(_materiais);
  MaterialViewModel(this.repository);

  // Lê tudo do banco e avisa a tela para atualizar.
  Future<void> carregar() async {
    _materiais = await repository.listar();
    notifyListeners();
  }

  // Cadastra (id == null) ou edita (id preenchido) um material.
  // Recebe os textos exatamente como foram digitados nos campos.
  Future<void> salvar({int? id, required String nome,
    required String categoria, required String quantidade,
    required String minimo}) async {
    // A regra também é conferida aqui, caso a operação seja chamada fora da tela.
    for (final campo in [nome, categoria]) {
      final erro = Validadores.textoObrigatorio(campo);
      if (erro != null) throw FormatException(erro);
    }
    for (final campo in [quantidade, minimo]) {
      final erro = Validadores.quantidade(campo);
      if (erro != null) throw FormatException(erro);
    }
    // Só chega aqui com textos válidos, então a conversão para int é segura.
    final unidades = int.tryParse(quantidade.trim());
    final limite = int.tryParse(minimo.trim());
    // Proteção para manter o app utilizável enquanto as validações são completadas.
    if (unidades == null || limite == null) {
      throw const FormatException('As quantidades devem ser números inteiros.');
    }
    // Impede nome repetido. Na edição, ignorarId deixa o material manter o
    // próprio nome sem ser tratado como duplicado.
    if (await repository.existeNome(nome, ignorarId: id)) {
      throw const FormatException('Já existe um material com esse nome.');
    }
    final material = MaterialEvento(id: id, nome: nome.trim(),
      categoria: categoria.trim(), quantidade: unidades, minimo: limite);
    // Sem id é cadastro novo; com id é atualização de um existente.
    if (id == null) {
      await repository.inserir(material);
    } else {
      await repository.atualizar(material);
    }
    // Recarrega do banco para a lista na tela refletir a mudança.
    await carregar();
  }

  // Exclui pelo id e atualiza a lista.
  Future<void> excluir(int id) async {
    await repository.excluir(id);
    await carregar();
  }
}
