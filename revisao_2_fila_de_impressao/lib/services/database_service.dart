// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)". Linhas sem marca são do professor (só ganharam comentário).
// Nesta versão só os comentários foram acrescentados; o código deste arquivo é o original.
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Service: abre o SQLite no Chrome, cria a tabela e insere as amostras.
// Não contém regras de formulário nem widgets.
class DatabaseService {
  // Banco já aberto (guardado para ser reaproveitado).
  Database? _banco;
  // Abertura em andamento: evita abrir o banco duas vezes ao mesmo tempo.
  Future<Database>? _abertura;

  // Os 3 documentos de exemplo. Usados na criação do banco e no botão
  // "Restaurar amostras". Cada um tem nome, páginas por cópia, cópias e
  // impresso (0 = não, 1 = sim).
  static const amostras = <Map<String, Object?>>[
    {'nome': 'Roteiro do evento', 'paginas': 4, 'copias': 3, 'impresso': 0},
    {'nome': 'Cartaz da oficina', 'paginas': 2, 'copias': 5, 'impresso': 0},
    {'nome': 'Lista de presença', 'paginas': 1, 'copias': 2, 'impresso': 1},
  ];

  // Quem precisar do banco usa este getter: se já está aberto devolve na hora,
  // senão abre (uma única vez).
  Future<Database> get banco {
    if (_banco != null) return Future.value(_banco!);
    return _abertura ??= _abrir();
  }

  // Abre (ou cria) o banco guardado no navegador.
  Future<Database> _abrir() async {
    try {
      final db = await databaseFactoryFfiWeb.openDatabase(
        // Nome do banco no navegador.
        'fila_impressao_modular_alunos_v1.db',
        // onCreate roda só na primeira vez, quando o banco ainda não existe.
        options: OpenDatabaseOptions(version: 1, onCreate: (db, versao) async {
          // Cria a tabela. "impresso" começa em 0 (não impresso) por padrão.
          await db.execute('CREATE TABLE documentos ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'nome TEXT NOT NULL, paginas INTEGER NOT NULL, '
            'copias INTEGER NOT NULL, impresso INTEGER NOT NULL DEFAULT 0)');
          // Grava as 3 amostras iniciais.
          for (final documento in amostras) {
            await db.insert('documentos', documento);
          }
        }),
      );
      _banco = db;
      return db;
    } catch (_) {
      // Se falhar, limpa a abertura para a próxima tentativa começar do zero.
      _abertura = null;
      rethrow;
    }
  }
}
