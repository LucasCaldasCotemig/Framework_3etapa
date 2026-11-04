// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
// Nesta versão só os comentários foram acrescentados; o código deste arquivo é o original.
// Ponto de entrada do aplicativo: aqui o Flutter começa a executar.
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'pages/materiais_page.dart';
import 'repositories/material_repository.dart';
import 'services/database_service.dart';
import 'viewmodels/material_viewmodel.dart';

// Monta a cadeia de camadas do app, de baixo para cima:
// DatabaseService (abre o SQLite) -> MaterialRepository (consultas)
// -> MaterialViewModel (regras e estado). A tela recebe só a ViewModel.
// É criada uma única vez, aqui, para toda a aplicação usar a mesma instância.
final viewModel = MaterialViewModel(MaterialRepository(DatabaseService()));

void main() {
  // Garante que o Flutter está pronto antes de rodar o app.
  WidgetsFlutterBinding.ensureInitialized();
  // DevicePreview envolve o app em uma moldura de celular, para testar
  // diferentes tamanhos de tela no navegador.
  runApp(DevicePreview(builder: (context) => const CentralApp()));
}

// Widget raiz: define título, tema e qual é a tela inicial.
class CentralApp extends StatelessWidget {
  const CentralApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    // Esconde a faixa "DEBUG" no canto da tela.
    debugShowCheckedModeBanner: false,
    title: 'Central de materiais',
    // Estas duas linhas ligam o app ao DevicePreview (idioma e tamanho).
    locale: DevicePreview.locale(context),
    builder: DevicePreview.appBuilder,
    // Material 3 com cores geradas a partir de um verde-base.
    theme: ThemeData(useMaterial3: true,
      colorSchemeSeed: const Color(0xFF215C47)),
    // Tela inicial: a lista e o formulário de materiais.
    home: MateriaisPage(viewModel: viewModel),
  );
}
