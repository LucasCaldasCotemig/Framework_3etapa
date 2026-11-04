// Repositório: única classe que lê ou altera a tabela "materiais".
// A ViewModel pede coisas aqui (listar, inserir...) sem saber SQL.
// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
import '../models/material_evento.dart';
import '../services/database_service.dart';

class MaterialRepository {
  // Serviço que entrega o banco já aberto.
  final DatabaseService service;
  MaterialRepository(this.service);

  // Já vinha pronto: lê todos os materiais, ordenados pelo nome sem diferenciar
  // maiúsculas, e converte cada linha do banco em um MaterialEvento.
  Future<List<MaterialEvento>> listar() async {
    final db = await service.database;
    final linhas = await db.query('materiais', orderBy: 'nome COLLATE NOCASE');
    return linhas.map((linha) => MaterialEvento.fromMap(linha)).toList();
  }

  // Informa se já existe outro material com o mesmo nome.
  Future<bool> existeNome(String nome, {int? ignorarId}) async {
    final db = await service.database; // (**)

    // Mesma normalização do modelo: sem espaços nas pontas e em minúsculas.
    final normalizado = nome.trim().toLowerCase();

    // Na edição, o próprio registro não conta como duplicado: "id != ?" o exclui.
    final linhas = await db.query(
      'materiais',
      columns: ['id'],
      where: ignorarId == null
          ? 'nome_normalizado = ?'
          : 'nome_normalizado = ? AND id != ?',
      whereArgs: ignorarId == null ? [normalizado] : [normalizado, ignorarId],
      limit: 1,
    );

    // Veio alguma linha: o nome já está em uso por outro material.
    return linhas.isNotEmpty; // (***)
  }

  // Cadastra um novo material.
  Future<void> inserir(MaterialEvento material) async {
    final db = await service.database; // (**)
    // toMap() entrega as colunas; sem id, o SQLite gera um novo (AUTOINCREMENT).
    await db.insert('materiais', material.toMap()); // (***)
  }

  // Altera os dados de um material que já existe.
  Future<void> atualizar(MaterialEvento material) async {
    // Sem id não há como saber qual registro alterar.
    if (material.id == null) { // (**)
      throw ArgumentError('O material precisa ter id para ser atualizado.');
    }
    final db = await service.database;
    // O where com id garante que somente a linha selecionada seja alterada.
    await db.update(
      'materiais',
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    ); // (***)
  }

  // Remove um material pelo id.
  Future<void> excluir(int id) async {
    final db = await service.database; // (**)
    // O where com id preserva todos os outros materiais.
    await db.delete('materiais', where: 'id = ?', whereArgs: [id]); // (***)
  }
}
