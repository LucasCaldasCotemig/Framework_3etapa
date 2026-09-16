class Produto {
  final int? id;
  final String nome;
  final String categoria;
  final int quantidade;
  final double preco;

  Produto({
    this.id,
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.preco,
  });

  bool get estoqueBaixo => quantidade <= 3;

  Produto copyWith({int? quantidade}) {
    return Produto(
      id: id,
      nome: nome,
      categoria: categoria,
      quantidade: quantidade ?? this.quantidade,
      preco: preco,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'preco': preco,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      categoria: map['categoria'] as String,
      quantidade: map['quantidade'] as int,
      preco: (map['preco'] as num).toDouble(),
    );
  }
}
