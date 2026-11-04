// Regras de validação dos campos do formulário.
// Fica em utils porque não depende de tela, banco ou estado: só recebe um
// texto e devolve uma mensagem de erro (ou null quando está tudo certo).
// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
class Validadores {
  // Usada nos campos Nome e Categoria.
  static String? textoObrigatorio(String? valor) {
    // valor == null cobre o campo sem texto; trim() tira os espaços das pontas,
    // então "   " vira "" e também é recusado.
    if (valor == null || valor.trim().isEmpty) { // (**)
      return 'Preencha este campo (só espaços não vale).';
    } // (***)
    // null significa "valor válido" para o TextFormField.
    return null;
  }

  // Usada nos campos Quantidade disponível e Quantidade mínima.
  static String? quantidade(String? valor) {
    // Campo vazio ou só com espaços.
    if (valor == null || valor.trim().isEmpty) { // (**)
      return 'Informe a quantidade.';
    }

    // Texto sem os espaços das pontas, usado nas conferências abaixo.
    final texto = valor.trim();

    // ^\d+$ aceita apenas dígitos de 0 a 9, do começo ao fim do texto.
    // Recusa letras, sinal, vírgula e ponto, sem converter nada para zero.
    if (RegExp(r'^\d+$').hasMatch(texto)) {
      // Números grandes demais não cabem em um int com segurança.
      if (int.tryParse(texto) == null || texto.length > 9) {
        return 'A quantidade informada é grande demais.';
      }
      return null;
    }

    // Começa com "-" seguido de número: valor negativo.
    if (RegExp(r'^-\d+([.,]\d+)?$').hasMatch(texto)) {
      return 'A quantidade não pode ser negativa.';
    }

    // Número com ponto ou vírgula: casas decimais.
    if (RegExp(r'^\d*[.,]\d*$').hasMatch(texto) && RegExp(r'\d').hasMatch(texto)) {
      return 'A quantidade deve ser inteira, sem decimais.';
    }

    // Qualquer outra coisa (letras, símbolos, espaços no meio).
    return 'Digite apenas números inteiros, como 0, 1 ou 10.'; // (***)
  }
}
