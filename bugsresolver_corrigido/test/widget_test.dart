import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:central_achados/models/ocorrencia.dart';

void main() {
  test('Ocorrencia guarda os dados informados', () {
    const o = Ocorrencia(id: '1', titulo: 'Garrafa', local: 'Cantina',
      descricao: '', autorId: 'uid1', autorNome: 'Aluno', resolvido: false,
      criadoEm: null);
    expect(o.autorId, 'uid1');
    expect(o.resolvido, false);
  });

  testWidgets('MaterialApp exibe um texto', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('Central de Achados')));
    expect(find.text('Central de Achados'), findsOneWidget);
  });
}
