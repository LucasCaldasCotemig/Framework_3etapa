// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
// Este arquivo veio vazio; os testes abaixo foram escritos por mim, por isso o arquivo todo é meu.
import 'package:flutter/material.dart'; // (**)
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:revisao/pages/impressao_page.dart';
import 'package:revisao/providers/impressao_provider.dart';
import 'package:revisao/repositories/impressao_repository.dart';
import 'package:revisao/services/database_service.dart';

// Repositório de mentira: guarda os documentos numa lista em memória, para
// testar o Provider e a tela sem precisar abrir o SQLite do navegador.
class RepositorioFalso extends ImpressaoRepository {
  RepositorioFalso() : super(DatabaseService());

  // Copia das amostras do professor (cada documento é um Map).
  final List<Map<String, Object?>> dados =
      DatabaseService.amostras.map((d) => {...d}).toList();

  @override
  Future<List<Map<String, Object?>>> listar() async =>
      dados.map((d) => {...d}).toList();

  @override
  Future<void> alternarImpressao(int id, bool estavaImpresso) async {
    for (final d in dados) {
      if (d['id'] == id) d['impresso'] = estavaImpresso ? 0 : 1;
    }
  }
}

// Cria o repositório falso já com ids 1, 2 e 3 como no banco de verdade.
RepositorioFalso criarRepositorio() {
  final repositorio = RepositorioFalso();
  for (var i = 0; i < repositorio.dados.length; i++) {
    repositorio.dados[i]['id'] = i + 1;
  }
  return repositorio;
}

void main() {
  group('Provider', () {
    test('folhas = páginas x cópias (4 x 3 = 12)', () {
      final provider = ImpressaoProvider(criarRepositorio());
      expect(provider.folhasDoDocumento({'paginas': 4, 'copias': 3}), 12);
      expect(provider.folhasDoDocumento({'paginas': 2, 'copias': 5}), 10);
    });

    test('validar recusa zero e aceita inteiros maiores que zero', () {
      final provider = ImpressaoProvider(criarRepositorio());
      expect(provider.validar('Doc', 0, 2), isNotNull);
      expect(provider.validar('Doc', 2, 0), isNotNull);
      expect(provider.validar('Doc', -1, 2), isNotNull);
      expect(provider.validar('Doc', null, 2), isNotNull);
      expect(provider.validar('Doc', 1, 1), isNull);
    });

    test('resumo: 3 documentos e 24 folhas', () async {
      final provider = ImpressaoProvider(criarRepositorio());
      await provider.iniciar();
      expect(provider.totalDocumentos, 3);
      expect(provider.totalFolhas, 24);
    });

    test('filtro Pendentes mostra só os não impressos e o resumo não muda', () async {
      final provider = ImpressaoProvider(criarRepositorio());
      await provider.iniciar();
      provider.alterarFiltro('Pendentes');
      final nomes = provider.documentosVisiveis.map((d) => d['nome']).toList();
      expect(nomes, ['Roteiro do evento', 'Cartaz da oficina']);
      expect(provider.totalFolhas, 24);
      provider.alterarFiltro('Impressos');
      expect(provider.documentosVisiveis.map((d) => d['nome']).toList(), ['Lista de presença']);
      provider.alterarFiltro('Todos');
      expect(provider.documentosVisiveis.length, 3);
    });

    test('alternar muda só o documento escolhido', () async {
      final provider = ImpressaoProvider(criarRepositorio());
      await provider.iniciar();
      await provider.alternar(provider.documentosVisiveis[0]);
      final situacao = provider.documentosVisiveis.map((d) => d['impresso']).toList();
      expect(situacao, [1, 0, 1]);
      await provider.alternar(provider.documentosVisiveis[0]);
      expect(provider.documentosVisiveis.map((d) => d['impresso']).toList(), [0, 0, 1]);
    });

    test('salvar com zero é recusado e mostra a mensagem', () async {
      final provider = ImpressaoProvider(criarRepositorio());
      await provider.iniciar();
      final ok = await provider.salvar(nome: 'Teste', paginasTexto: '0', copiasTexto: '2');
      expect(ok, isFalse);
      expect(provider.mensagem, isNotNull);
      final ok2 = await provider.salvar(nome: 'Teste', paginasTexto: '2', copiasTexto: '0');
      expect(ok2, isFalse);
    });
  });

  group('Tela em tamanhos de celular', () {
    // Monta a tela dentro de um MaterialApp, com o Provider falso.
    Future<void> abrirTela(WidgetTester tester, Size tamanho) async {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ImpressaoProvider(criarRepositorio())..iniciar(),
        child: const MaterialApp(home: ImpressaoPage()),
      ));
      await tester.pumpAndSettle();
    }

    // Dois tamanhos de celular: pequeno (iPhone SE) e comum (Android 360 x 640).
    for (final tamanho in const [Size(375, 667), Size(360, 640)]) {
      testWidgets('sem elementos cortados em ${tamanho.width.toInt()}x${tamanho.height.toInt()}',
          (tester) async {
        await abrirTela(tester, tamanho);
        expect(find.text('Fila de impressão'), findsOneWidget);
        expect(find.text('Salvar'), findsOneWidget);
        expect(find.text('Documentos: 3 | Folhas necessárias: 24'), findsOneWidget);
        expect(find.text('Folhas necessárias: 12'), findsOneWidget);
        // Se algum widget estourasse a tela, o Flutter lançaria uma exceção de overflow.
        expect(tester.takeException(), isNull);
      });
    }
  }); // (***)
}
