// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)". Linhas sem marca são do professor (só ganharam comentário).
import '../services/database_service.dart';

// Repository: concentra as consultas e alterações dos documentos no SQLite.
// O Provider pede coisas aqui (listar, salvar...) sem precisar saber SQL.
class ImpressaoRepository {
  // Serviço que entrega o banco já aberto.
  final DatabaseService service;
  ImpressaoRepository(this.service);

  // Lê todos os documentos do banco.
  Future<List<Map<String, Object?>>> listar() async {
    final db = await service.banco;
    // CORREÇÃO 2: "ASC" = crescente. O id aumenta a cada cadastro, então o
    // documento mais antigo (menor id) vem primeiro e o novo vai para o final.
    // O erro era "DESC" (decrescente), que mostrava o mais novo primeiro.
    return db.query('documentos', orderBy: 'id ASC'); // (**) (***)
  }

  // Cadastra (id == null) ou edita (id preenchido) um documento.
  Future<void> salvar({int? id, required String nome,
    required int paginas, required int copias}) async {
    final db = await service.banco;
    final dados = <String, Object?>{
      'nome': nome.trim(), 'paginas': paginas, 'copias': copias,
    };
    if (id == null) {
      // Novo documento: sempre começa como não impresso (0).
      await db.insert('documentos', {...dados, 'impresso': 0});
    } else {
      // Edição: where com id altera somente o documento escolhido.
      await db.update('documentos', dados, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Marca como impresso ou desfaz a marcação de UM documento.
  Future<void> alternarImpressao(int id, bool estavaImpresso) async {
    final db = await service.banco;
    // Se estava impresso (1) passa a 0; se não estava, passa a 1.
    final novoValor = estavaImpresso ? 0 : 1;
    // CORREÇÃO 6: o where precisa ser "id = ?" (igual ao id escolhido).
    // O erro era "id <> ?" (diferente), que alterava todos os OUTROS documentos
    // e deixava justamente o escolhido sem mudar.
    await db.update('documentos', {'impresso': novoValor},
      where: 'id = ?', whereArgs: [id]); // (**) (***)
  }

  // Remove um documento pelo id; os outros são mantidos.
  Future<void> excluir(int id) async {
    final db = await service.banco;
    await db.delete('documentos', where: 'id = ?', whereArgs: [id]);
  }

  // Restaura somente os exemplos desta atividade; a tela pede confirmação.
  Future<void> restaurarAmostras() async {
    final db = await service.banco;
    // transaction: ou faz tudo, ou não faz nada.
    await db.transaction((txn) async {
      // Apaga tudo e zera o contador do id para voltar a começar do 1.
      await txn.delete('documentos');
      await txn.delete('sqlite_sequence', where: 'name = ?', whereArgs: ['documentos']);
      // Grava as 3 amostras de novo.
      for (final documento in DatabaseService.amostras) {
        await txn.insert('documentos', documento);
      }
    });
  }
}
