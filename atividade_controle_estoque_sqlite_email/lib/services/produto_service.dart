import '../models/produto.dart';
import 'database_helper.dart';

class ProdutoService {
  Future<List<Produto>> listar() async {
    final db = await DatabaseHelper.banco;

    final resultado = await db.query('produtos');

    print('SELECT → Produtos encontrados:');
    for (final linha in resultado) {
      print(linha);
    }

    return resultado.map((linha) => Produto.fromMap(linha)).toList();
  }

  Future<Produto> cadastrar(Produto produto) async {
    final db = await DatabaseHelper.banco;

    final id = await db.insert('produtos', produto.toMap());

    print('INSERT → Produto cadastrado: ${produto.nome}');

    return Produto(
      id: id,
      nome: produto.nome,
      categoria: produto.categoria,
      quantidade: produto.quantidade,
      preco: produto.preco,
    );
  }

  Future<void> atualizarQuantidade(int id, int quantidadeAnterior, int novaQuantidade) async {
    final db = await DatabaseHelper.banco;

    await db.update(
      'produtos',
      {'quantidade': novaQuantidade},
      where: 'id = ?',
      whereArgs: [id],
    );

    print('UPDATE → Produto id $id');
    print('Quantidade anterior: $quantidadeAnterior');
    print('Nova quantidade: $novaQuantidade');
  }

  Future<void> excluir(int id, String nome) async {
    final db = await DatabaseHelper.banco;

    await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );

    print('DELETE → Produto excluído: $nome');
  }

  Future<void> mostrarProdutosNoTerminal() async {
    final db = await DatabaseHelper.banco;

    final produtos = await db.query('produtos');

    print('===== PRODUTOS NO BANCO =====');
    for (final produto in produtos) {
      print(produto);
    }
  }
}
