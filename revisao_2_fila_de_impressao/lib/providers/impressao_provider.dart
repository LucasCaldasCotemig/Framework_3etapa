// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)". Linhas sem marca são do professor (só ganharam comentário).
import 'package:flutter/foundation.dart';
import '../repositories/impressao_repository.dart';

// Provider: guarda o estado, aplica regras e avisa a tela com notifyListeners.
// A tela (Page) só mostra; quem decide o que mostrar e o que é válido é ele.
class ImpressaoProvider extends ChangeNotifier {
  final ImpressaoRepository repository;
  ImpressaoProvider(this.repository);

  // Lista COMPLETA de documentos, espelho do banco.
  List<Map<String, Object?>> _documentos = [];
  // true enquanto uma operação está em andamento (a tela mostra a barra de progresso).
  bool _carregando = false;
  // true depois que o Provider é fechado, para não notificar uma tela que já saiu.
  bool _descartado = false;
  // Filtro escolhido no Dropdown: 'Todos', 'Pendentes' ou 'Impressos'.
  String _filtro = 'Todos';
  // Mensagem de erro se o banco não abrir.
  String? _falhaBanco;
  // Última mensagem de erro/aviso para a tela exibir.
  String? _mensagem;

  // Getters: a tela só lê esses valores, não altera diretamente.
  bool get carregando => _carregando;
  String get filtro => _filtro;
  String? get falhaBanco => _falhaBanco;
  String? get mensagem => _mensagem;
  int get totalDocumentos => _documentos.length;

  // Retorna uma lista derivada; a lista completa é mantida para o resumo.
  // Por isso o resumo (total de folhas) não muda quando o filtro muda.
  List<Map<String, Object?>> get documentosVisiveis =>
    _documentos.where(_mostrar).toList();

  // Decide se um documento aparece na lista, conforme o filtro escolhido.
  bool _mostrar(Map<String, Object?> documento) {
    final impresso = documento['impresso'] as int;
    // CORREÇÃO 5: "Pendentes" = ainda NÃO impresso (impresso == 0).
    // O erro era "== 1", que mostrava os já impressos.
    if (_filtro == 'Pendentes') return impresso == 0; // (**) (***)
    // "Impressos" = já impresso (impresso == 1).
    if (_filtro == 'Impressos') return impresso == 1;
    // "Todos": mostra tudo.
    return true;
  }

  // Quantas folhas UM documento usa.
  int folhasDoDocumento(Map<String, Object?> documento) {
    final paginas = documento['paginas'] as int;
    final copias = documento['copias'] as int;
    // CORREÇÃO 4: folhas = páginas por cópia × número de cópias.
    // O erro era "+" (soma): 4 páginas e 3 cópias dava 7 em vez de 12.
    return paginas * copias; // (**) (***)
  }

  // Total de folhas de TODOS os documentos (não depende do filtro).
  int get totalFolhas => _documentos.fold<int>(0, (soma, documento) =>
    soma + (documento['paginas'] as int) * (documento['copias'] as int));

  // Chamado pelo Dropdown: guarda o filtro e avisa a tela para se redesenhar.
  void alterarFiltro(String valor) {
    _filtro = valor;
    _notificar();
  }

  // Confere os dados do formulário. Retorna a mensagem de erro ou null se estiver tudo certo.
  // É usada tanto no cadastro quanto na edição (os dois passam por "salvar").
  String? validar(String nome, int? paginas, int? copias) {
    if (nome.trim().isEmpty) return 'Preencha o nome do documento.';
    // int.tryParse devolve null para texto que não é número inteiro (ex.: "abc", "2.5").
    if (paginas == null || copias == null) return 'Informe números inteiros.';
    // CORREÇÃO 3: só vale número MAIOR que zero, então zero também é recusado.
    // O erro era "< 0", que deixava passar o zero (0 não é menor que 0).
    if (paginas <= 0 || copias <= 0) return 'Páginas e cópias devem ser maiores que zero.'; // (**) (***)
    // null = sem erro, pode gravar.
    return null;
  }

  // Lê os documentos do banco e guarda na lista.
  Future<void> _atualizarDados() async {
    _documentos = await repository.listar();
  }

  // Carrega os dados ao abrir o app. Se falhar, guarda a falha para a tela mostrar.
  Future<bool> iniciar() async {
    _falhaBanco = null;
    final sucesso = await _executar(_atualizarDados);
    if (!sucesso) _falhaBanco = _mensagem;
    _notificar();
    return sucesso;
  }

  // Botão "Recarregar do banco".
  Future<bool> recarregar() => _executar(_atualizarDados);

  // Cadastra (id == null) ou edita (id preenchido). Recebe os textos dos campos.
  Future<bool> salvar({int? id, required String nome,
    required String paginasTexto, required String copiasTexto}) async {
    // Converte os textos em números (null se não for inteiro).
    final paginas = int.tryParse(paginasTexto.trim());
    final copias = int.tryParse(copiasTexto.trim());
    // Valida ANTES de gravar: se houver erro, mostra a mensagem e NÃO grava.
    final erro = validar(nome, paginas, copias);
    if (erro != null) {
      _mensagem = erro;
      _notificar();
      return false;
    }
    // Chegou aqui: dados válidos, então grava e recarrega a lista.
    return _executar(() async {
      await repository.salvar(id: id, nome: nome,
        paginas: paginas!, copias: copias!);
      await _atualizarDados();
    });
  }

  // Botão "Alternar impressão": passa o id e o estado atual do documento.
  Future<bool> alternar(Map<String, Object?> documento) => _executar(() async {
    await repository.alternarImpressao(
      documento['id'] as int, documento['impresso'] == 1);
    await _atualizarDados();
  });

  // Exclui pelo id e recarrega a lista.
  Future<bool> excluir(int id) => _executar(() async {
    await repository.excluir(id);
    await _atualizarDados();
  });

  // Botão "Restaurar amostras": volta aos 3 documentos iniciais.
  Future<bool> restaurar() => _executar(() async {
    await repository.restaurarAmostras();
    await _atualizarDados();
  });

  // Envolve toda operação: liga o "carregando", executa e trata erros.
  // Ignora cliques repetidos enquanto outra operação ainda está rodando.
  Future<bool> _executar(Future<void> Function() operacao) async {
    if (_carregando) return false;
    _carregando = true;
    _mensagem = null;
    _notificar();
    try {
      await operacao();
      return true;
    } catch (erro) {
      _mensagem = 'Não foi possível concluir: $erro';
      return false;
    } finally {
      // Sempre desliga o "carregando" no final, deu certo ou errado.
      _carregando = false;
      _notificar();
    }
  }

  // Avisa a tela que algo mudou (só se o Provider ainda não foi descartado).
  void _notificar() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
