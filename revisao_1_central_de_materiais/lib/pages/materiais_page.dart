// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)".
// Nesta versão só os comentários foram acrescentados; o código deste arquivo é o original.
import 'package:flutter/material.dart';
import '../models/material_evento.dart';
import '../utils/validadores.dart';
import '../viewmodels/material_viewmodel.dart';

// Tela única do app: formulário de cadastro/edição no topo e lista de materiais embaixo.
// StatefulWidget porque a tela muda (campos, modo edição, carregando).
class MateriaisPage extends StatefulWidget {
  // ViewModel recebida de fora (criada no main.dart).
  final MaterialViewModel viewModel;
  const MateriaisPage({super.key, required this.viewModel});
  @override
  State<MateriaisPage> createState() => _MateriaisPageState();
}

class _MateriaisPageState extends State<MateriaisPage> {
  // Chave do formulário: permite validar todos os campos de uma vez e resetar.
  final _formulario = GlobalKey<FormState>();
  // Um controller por campo: lê e altera o texto digitado.
  final _nome = TextEditingController();
  final _categoria = TextEditingController();
  final _quantidade = TextEditingController();
  final _minimo = TextEditingController();
  // null = cadastrando um novo; preenchido = editando o material com esse id.
  int? _idEmEdicao;
  // true enquanto algo está em andamento: mostra a barra e bloqueia toques.
  bool _ocupado = true;
  // Texto do erro se o banco não abrir; null quando está tudo bem.
  String? _falhaInicial;
  // Atalho para não escrever widget.viewModel toda vez.
  MaterialViewModel get vm => widget.viewModel;

  // Roda uma vez ao abrir a tela: já dispara a leitura dos materiais.
  @override
  void initState() {
    super.initState();
    _carregarInicial();
  }

  // Carrega a lista do banco. Também é usada pelo botão de recarregar.
  Future<void> _carregarInicial() async {
    setState(() { _ocupado = true; _falhaInicial = null; });
    try {
      await vm.carregar();
    } catch (erro) {
      if (mounted) setState(() => _falhaInicial = erro.toString());
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  // Libera os controllers e a ViewModel quando a tela é fechada.
  @override
  void dispose() {
    _nome.dispose();
    _categoria.dispose();
    _quantidade.dispose();
    _minimo.dispose();
    vm.dispose();
    super.dispose();
  }

  // Volta o formulário ao estado de cadastro: sai do modo edição e esvazia os campos.
  void _limpar() {
    _idEmEdicao = null;
    _nome.clear(); _categoria.clear(); _quantidade.clear(); _minimo.clear();
    _formulario.currentState?.reset();
  }

  // Mostra uma mensagem rápida (SnackBar) na parte de baixo da tela.
  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // Envolve toda operação (salvar/excluir): bloqueia a tela durante a ação e
  // transforma erros em mensagens, em vez de deixar o app quebrar.
  Future<void> _executar(Future<void> Function() acao) async {
    // Ignora cliques repetidos enquanto outra ação está em andamento.
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      await acao();
    // Erro de regra (ex.: nome repetido): mostra a mensagem dele.
    } on FormatException catch (erro) {
      if (mounted) _avisar(erro.message);
    // Método ainda não implementado da atividade.
    } on UnimplementedError {
      if (mounted) _avisar('Esta operação faz parte da atividade. Consulte ATIVIDADE.md.');
    // Qualquer outro erro inesperado.
    } catch (erro) {
      if (mounted) _avisar('Não foi possível concluir a operação: $erro');
    } finally {
      // Sempre desbloqueia a tela no final, deu certo ou errado.
      if (mounted) setState(() => _ocupado = false);
    }
  }

  // Botão Cadastrar/Salvar alterações: valida os campos e manda a ViewModel gravar.
  Future<void> _salvar() async {
    // validate() roda os validators dos campos; se algum falhar, não grava.
    if (!_formulario.currentState!.validate()) return;
    await _executar(() async {
      await vm.salvar(id: _idEmEdicao, nome: _nome.text,
        categoria: _categoria.text, quantidade: _quantidade.text, minimo: _minimo.text);
      if (!mounted) return;
      _limpar();
      _avisar('Material salvo.');
    });
  }

  // Botão Editar: copia os dados do material para o formulário e entra no modo edição.
  void _editar(MaterialEvento material) {
    setState(() {
      _idEmEdicao = material.id;
      _nome.text = material.nome;
      _categoria.text = material.categoria;
      _quantidade.text = material.quantidade.toString();
      _minimo.text = material.minimo.toString();
    });
  }

  // Botão Excluir: pergunta antes (diálogo) e só exclui se o usuário confirmar.
  Future<void> _excluir(MaterialEvento material) async {
    // Abre o diálogo e espera true (Excluir) ou false (Cancelar).
    final confirmou = await showDialog<bool>(context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Excluir material?'),
        content: Text('Excluir ${material.nome}? Os outros materiais serão mantidos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogo, true),
            child: const Text('Excluir')),
        ],
      ));
    // Cancelou (ou a tela fechou): não faz nada.
    if (confirmou != true || !mounted) return;
    await _executar(() async {
      await vm.excluir(material.id!);
      if (!mounted) return;
      // Se o material excluído estava aberto para edição, limpa o formulário.
      if (_idEmEdicao == material.id) _limpar();
      _avisar('Material excluído.');
    });
  }

  // Monta um campo de texto do formulário. numerico = true usa o teclado numérico
  // e a validação de quantidade; senão, valida texto obrigatório.
  Widget _campo(TextEditingController controller, String titulo,
    {bool numerico = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: controller,
      decoration: InputDecoration(labelText: titulo, border: const OutlineInputBorder()),
      keyboardType: numerico ? TextInputType.number : TextInputType.text,
      validator: numerico ? Validadores.quantidade : Validadores.textoObrigatorio),
  );

  // Desenha a tela: barra de título, formulário e lista de materiais.
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Central de materiais'), actions: [
      IconButton(tooltip: 'Recarregar do banco', onPressed: _ocupado ? null : _carregarInicial,
        icon: const Icon(Icons.refresh)),
    ]),
    // Se o banco falhou ao abrir, mostra o erro e um botão para tentar de novo.
    // Senão mostra o conteúdo; AbsorbPointer bloqueia toques enquanto ocupado.
    body: _falhaInicial != null ? Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Não foi possível abrir o banco.'),
        const SizedBox(height: 8), SelectableText(_falhaInicial!),
        const SizedBox(height: 16),
        FilledButton(onPressed: _carregarInicial, child: const Text('Tentar novamente')),
      ]),
    )) : AbsorbPointer(absorbing: _ocupado, child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_ocupado) const LinearProgressIndicator(),
          Text(_idEmEdicao == null ? 'Cadastrar material' : 'Editar material',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          // Formulário com os quatro campos e os botões.
          Form(key: _formulario, child: Column(children: [
            _campo(_nome, 'Nome'),
            _campo(_categoria, 'Categoria'),
            _campo(_quantidade, 'Quantidade disponível', numerico: true),
            _campo(_minimo, 'Quantidade mínima', numerico: true),
            Row(children: [
              FilledButton(onPressed: _salvar,
                child: Text(_idEmEdicao == null ? 'Cadastrar' : 'Salvar alterações')),
              if (_idEmEdicao != null) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: () => setState(_limpar), child: const Text('Cancelar')),
              ],
            ]),
          ])),
          const SizedBox(height: 28),
          const Divider(),
          // Redesenha a lista sempre que a ViewModel avisa que ela mudou.
          AnimatedBuilder(animation: vm, builder: (context, _) {
            final materiais = vm.materiais;
            // Lista vazia: aviso. Senão, um Card por material com nome, categoria,
            // quantidades, situação e os botões Editar/Excluir.
            if (materiais.isEmpty) return const Padding(padding: EdgeInsets.all(24),
              child: Text('Nenhum material cadastrado.'));
            return Column(children: materiais.map((material) => Card(
              child: Padding(padding: const EdgeInsets.all(14), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(material.nome, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Categoria: ${material.categoria}'),
                  Text('Disponível: ${material.quantidade} | Mínimo: ${material.minimo}'),
                  const SizedBox(height: 8),
                  Text(material.situacao, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton.icon(onPressed: () => _editar(material),
                      icon: const Icon(Icons.edit), label: const Text('Editar')),
                    TextButton.icon(onPressed: () => _excluir(material),
                      icon: const Icon(Icons.delete_outline), label: const Text('Excluir')),
                  ]),
                ],
              )),
            )).toList());
          }),
        ]),
      )),
    )),
  );
}
