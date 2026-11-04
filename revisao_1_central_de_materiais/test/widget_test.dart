import 'package:flutter_test/flutter_test.dart';
import 'package:revisao/models/material_evento.dart';
import 'package:revisao/utils/validadores.dart';

// Cria um material só com quantidade e mínimo, que são os campos
// usados para calcular a situação.
MaterialEvento material(int quantidade, int minimo) => MaterialEvento(
      nome: 'Teste',
      categoria: 'Teste',
      quantidade: quantidade,
      minimo: minimo,
    );

void main() {
  group('Validadores.textoObrigatorio', () {
    test('recusa null, vazio e somente espaços', () {
      expect(Validadores.textoObrigatorio(null), isNotNull);
      expect(Validadores.textoObrigatorio(''), isNotNull);
      expect(Validadores.textoObrigatorio('     '), isNotNull);
    });

    test('aceita texto com conteúdo', () {
      expect(Validadores.textoObrigatorio('Microfone'), isNull);
    });
  });

  group('Validadores.quantidade', () {
    test('recusa vazio, letras, negativo e decimal', () {
      expect(Validadores.quantidade(''), isNotNull);
      expect(Validadores.quantidade('abc'), isNotNull);
      expect(Validadores.quantidade('-1'), isNotNull);
      expect(Validadores.quantidade('1.5'), isNotNull);
      expect(Validadores.quantidade('1,5'), isNotNull);
    });

    test('aceita inteiros maiores ou iguais a zero', () {
      expect(Validadores.quantidade('0'), isNull);
      expect(Validadores.quantidade('10'), isNull);
      expect(Validadores.quantidade(' 25 '), isNull);
    });
  });

  group('MaterialEvento.situacao', () {
    test('zero e mínimo zero é Sem estoque', () {
      expect(material(0, 0).situacao, 'Sem estoque');
    });

    test('quantidade zero é Sem estoque', () {
      expect(material(0, 2).situacao, 'Sem estoque');
    });

    test('abaixo do mínimo é Estoque baixo', () {
      expect(material(2, 3).situacao, 'Estoque baixo');
    });

    test('igual ao mínimo é Estoque adequado', () {
      expect(material(2, 2).situacao, 'Estoque adequado');
    });

    test('acima do mínimo é Estoque adequado', () {
      expect(material(4, 2).situacao, 'Estoque adequado');
    });
  });
}
