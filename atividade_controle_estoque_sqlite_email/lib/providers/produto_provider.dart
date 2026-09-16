import 'package:flutter/foundation.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';

class ProdutoProvider extends ChangeNotifier {
  final ProdutoService _service = ProdutoService();

  List<Produto> _produtos = [];
  bool _carregando = false;

  List<Produto> get produtos => _produtos;
  bool get carregando => _carregando;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _produtos = await _service.listar();

    _carregando = false;
    notifyListeners();
  }

  Future<void> cadastrar(String nome, String categoria, int quantidade, double preco) async {
    final produto = Produto(
      nome: nome,
      categoria: categoria,
      quantidade: quantidade,
      preco: preco,
    );

    await _service.cadastrar(produto);
    await carregar();
  }

  Future<void> incrementarQuantidade(Produto produto) async {
    final novaQuantidade = produto.quantidade + 1;
    await _service.atualizarQuantidade(produto.id!, produto.quantidade, novaQuantidade);
    await carregar();
  }

  Future<void> decrementarQuantidade(Produto produto) async {
    if (produto.quantidade <= 0) return;
    final novaQuantidade = produto.quantidade - 1;
    await _service.atualizarQuantidade(produto.id!, produto.quantidade, novaQuantidade);
    await carregar();
  }

  Future<void> excluir(Produto produto) async {
    await _service.excluir(produto.id!, produto.nome);
    await carregar();
  }

  Future<void> mostrarNoTerminal() async {
    await _service.mostrarProdutosNoTerminal();
  }
}
