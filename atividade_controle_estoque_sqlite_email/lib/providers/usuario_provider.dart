import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioService _service = UsuarioService();

  Usuario? _usuarioLogado;
  String? _mensagemErro;
  bool _carregando = false;

  Usuario? get usuarioLogado => _usuarioLogado;
  String? get mensagemErro => _mensagemErro;
  bool get carregando => _carregando;

  Future<bool> cadastrar(String nome, String email, String senha) async {
    _carregando = true;
    _mensagemErro = null;
    notifyListeners();

    final usuario = Usuario(nome: nome, email: email, senha: senha);
    final sucesso = await _service.cadastrar(usuario);

    if (!sucesso) {
      _mensagemErro = 'E-mail já cadastrado.';
    }

    _carregando = false;
    notifyListeners();
    return sucesso;
  }

  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _mensagemErro = null;
    notifyListeners();

    final usuario = await _service.login(email, senha);

    if (usuario == null) {
      _mensagemErro = 'E-mail ou senha incorretos.';
      _carregando = false;
      notifyListeners();
      return false;
    }

    _usuarioLogado = usuario;
    _carregando = false;
    notifyListeners();
    return true;
  }

  void sair() {
    _usuarioLogado = null;
    notifyListeners();
  }
}
