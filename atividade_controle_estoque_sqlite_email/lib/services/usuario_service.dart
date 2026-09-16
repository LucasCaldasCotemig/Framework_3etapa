import '../models/usuario.dart';
import 'database_helper.dart';

class UsuarioService {
  Future<bool> emailExiste(String email) async {
    final db = await DatabaseHelper.banco;

    print('SELECT → Procurando usuário: $email');

    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (resultado.isNotEmpty) {
      print('SELECT → E-mail já cadastrado');
      return true;
    }

    print('SELECT → E-mail disponível');
    return false;
  }

  Future<bool> cadastrar(Usuario usuario) async {
    final db = await DatabaseHelper.banco;

    final existe = await emailExiste(usuario.email);
    if (existe) {
      return false;
    }

    await db.insert('usuarios', usuario.toMap());
    print('INSERT → Usuário cadastrado: ${usuario.nome}');
    return true;
  }

  Future<Usuario?> login(String email, String senha) async {
    final db = await DatabaseHelper.banco;

    print('SELECT → Procurando usuário: $email');

    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );

    if (resultado.isEmpty) {
      print('SELECT → Usuário não encontrado');
      return null;
    }

    final usuario = Usuario.fromMap(resultado.first);
    print('SELECT → Usuário encontrado: ${usuario.nome}');
    return usuario;
  }
}
