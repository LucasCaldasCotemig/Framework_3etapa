// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)". Linhas sem marca são do professor (só ganharam comentário).
// Ponto de entrada do aplicativo: é aqui que o Flutter começa a executar.
import 'package:device_preview/device_preview.dart'; // (**) (***)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/impressao_page.dart';
import 'providers/impressao_provider.dart';
import 'repositories/impressao_repository.dart';
import 'services/database_service.dart';

void main() {
  // Garante que o Flutter está pronto antes de rodar o app.
  WidgetsFlutterBinding.ensureInitialized();
  // O DevicePreview fica por fora de tudo: ele desenha uma moldura de celular
  // ao redor do app, para testar vários tamanhos de tela no Chrome.
  runApp(DevicePreview( // (**)
    builder: (context) => ChangeNotifierProvider( // (***)
      // ChangeNotifierProvider cria o Provider UMA vez e o deixa disponível
      // para todas as telas. O "..iniciar()" já manda carregar os dados do banco.
      // Monta as dependências: DatabaseService -> Repository -> Provider.
      create: (_) => ImpressaoProvider(
        ImpressaoRepository(DatabaseService()))..iniciar(),
      child: const ImpressaoApp(),
    ),
  )); // (**) (***)
}

// Widget raiz: define título, tema e qual é a tela inicial.
class ImpressaoApp extends StatelessWidget {
  const ImpressaoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    // Esconde a faixa "DEBUG" no canto da tela.
    debugShowCheckedModeBanner: false,
    // Estas duas linhas ligam o app ao DevicePreview (idioma e tamanho da tela).
    locale: DevicePreview.locale(context), // (**)
    builder: DevicePreview.appBuilder, // (***)
    title: 'Fila de impressão',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    // Tela inicial: formulário, resumo, filtro e lista de documentos.
    home: const ImpressaoPage(),
  );
}
