// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
// Modelo: representa um material de evento (uma linha da tabela "materiais").
// Guarda os dados e sabe se converter de/para o formato do banco (Map).
class MaterialEvento {
  // id é null enquanto o material ainda não foi salvo; o SQLite gera o número.
  final int? id;
  final String nome;
  final String categoria;
  // Quantas unidades existem disponíveis agora.
  final int quantidade;
  // Quantidade mínima desejada em estoque.
  final int minimo;

  const MaterialEvento({
    this.id,
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.minimo,
  });

  // Nome em minúsculas e sem espaços nas pontas. Serve para comparar nomes
  // ignorando maiúsculas e espaços ("Microfone" = " microfone ").
  // A mesma normalização deve ser usada no cadastro e na consulta de duplicidade.
  String get nomeNormalizado => nome.trim().toLowerCase();

  // Resume em texto como está o estoque deste material.
  String get situacao {
    // A quantidade zero é testada primeiro. Assim, quando quantidade e mínimo
    // são zero, o resultado é "Sem estoque" e não "Estoque adequado".
    if (quantidade == 0) return 'Sem estoque'; // (**)

    // Tem alguma unidade, mas menos que o mínimo desejado.
    if (quantidade < minimo) return 'Estoque baixo';

    // Chegou aqui: quantidade maior que zero e maior ou igual ao mínimo.
    return 'Estoque adequado'; // (***)
  }

  // Converte o objeto em um Map para gravar no SQLite (colunas -> valores).
  Map<String, Object?> toMap() => {
    // O id só entra quando já existe (edição); no cadastro o banco gera.
    if (id != null) 'id': id,
    'nome': nome.trim(),
    // Coluna extra, única no banco, usada para impedir nomes repetidos.
    'nome_normalizado': nomeNormalizado,
    'categoria': categoria.trim(),
    'quantidade': quantidade,
    'minimo': minimo,
  };

  // Faz o caminho contrário: cria o objeto a partir de uma linha lida do banco.
  factory MaterialEvento.fromMap(Map<String, Object?> map) => MaterialEvento(
    id: map['id'] as int,
    nome: map['nome'] as String,
    categoria: map['categoria'] as String,
    // (as num).toInt() evita erro quando o navegador devolve número como double.
    quantidade: (map['quantidade'] as num).toInt(),
    minimo: (map['minimo'] as num).toInt(),
  );
}
