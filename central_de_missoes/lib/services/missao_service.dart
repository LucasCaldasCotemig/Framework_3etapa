import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/missao.dart';

class MissaoService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('missoes');

  Future<void> adicionar(Missao missao) async {
    await _collection.add(missao.toMap());
  }

  Future<List<Missao>> buscarTodas() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) =>
            Missao.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> atualizar(String id, Map<String, dynamic> dados) async {
    await _collection.doc(id).update(dados);
  }

  Future<void> excluir(String id) async {
    await _collection.doc(id).delete();
  }
}
