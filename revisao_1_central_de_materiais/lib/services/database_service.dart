// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
// Nesta versão só os comentários foram acrescentados; o código deste arquivo é o original.
// Serviço de banco de dados: abre o SQLite, cria a tabela e os dados iniciais.
// Só se preocupa em entregar o banco aberto; as consultas ficam no repositório.
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Infraestrutura pronta para a atividade. Não usa dart:io nem path_provider.
// No Chrome, o banco é persistido no armazenamento da origem (IndexedDB).
class DatabaseService {
  // Banco já aberto (guardado para reaproveitar).
  Database? _database;
  // Abertura em andamento: evita abrir o banco duas vezes ao mesmo tempo.
  Future<Database>? _abertura;

  // Quem precisar do banco usa este getter. Se já está aberto, devolve na hora;
  // se não, abre (uma única vez).
  Future<Database> get database {
    if (_database != null) return Future.value(_database!);
    return _abertura ??= _abrir();
  }

  // Abre (ou cria) o arquivo do banco no navegador.
  Future<Database> _abrir() async {
    try {
      final db = await databaseFactoryFfiWeb.openDatabase(
        // Nome do banco; muda a versão no nome se a estrutura mudar.
        'central_materiais_alunos_v1.db',
        options: OpenDatabaseOptions(
          version: 1,
          // onCreate roda só na primeira vez, quando o banco ainda não existe.
          onCreate: (db, versao) async {
            // Cria a tabela. nome_normalizado é UNIQUE: o próprio banco
            // recusa dois materiais com o mesmo nome normalizado.
            await db.execute(
              'CREATE TABLE materiais ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'nome TEXT NOT NULL, '
              'nome_normalizado TEXT NOT NULL UNIQUE, '
              'categoria TEXT NOT NULL, '
              'quantidade INTEGER NOT NULL, '
              'minimo INTEGER NOT NULL)',
            );
            // Quatro materiais de exemplo para o app já abrir com dados.
            final iniciais = <Map<String, Object?>>[
              {'nome': 'Microfone', 'nome_normalizado': 'microfone',
                'categoria': 'Áudio', 'quantidade': 4, 'minimo': 2},
              {'nome': 'Cabo HDMI', 'nome_normalizado': 'cabo hdmi',
                'categoria': 'Vídeo', 'quantidade': 2, 'minimo': 3},
              {'nome': 'Extensão', 'nome_normalizado': 'extensão',
                'categoria': 'Elétrica', 'quantidade': 0, 'minimo': 2},
              {'nome': 'Caixa de som', 'nome_normalizado': 'caixa de som',
                'categoria': 'Áudio', 'quantidade': 3, 'minimo': 1},
            ];
            for (final material in iniciais) {
              await db.insert('materiais', material);
            }
          },
        ),
      );
      _database = db;
      return db;
    } catch (_) {
      // Se falhar, limpa a abertura para a próxima tentativa começar do zero.
      _abertura = null;
      rethrow;
    }
  }
}
