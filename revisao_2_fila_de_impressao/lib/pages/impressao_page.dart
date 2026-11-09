import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/impressao_provider.dart';

// Legenda: o trecho que eu escrevi/alterei começa numa linha com "// (**)" e termina na linha com "// (***)". Linhas sem marca são do professor (só ganharam comentário).
// Nesta versão só os comentários foram acrescentados; o código deste arquivo é o original.

// Page: mostra o formulário e a lista; encaminha ações para o Provider.
// Ela não tem regra de negócio: só desenha e repassa os cliques ao Provider.
class ImpressaoPage extends StatefulWidget {
  const ImpressaoPage({super.key});
  @override
  State<ImpressaoPage> createState() => _ImpressaoPageState();
}

class _ImpressaoPageState extends State<ImpressaoPage> {
  // Um controller por campo de texto: lê e altera o que foi digitado.
  final nome = TextEditingController();
  final paginas = TextEditingController();
  final copias = TextEditingController();
  // null = cadastrando novo documento; preenchido = editando o documento com esse id.
  int? idEdicao;

  // Libera os controllers quando a tela é fechada.
  @override
  void dispose() {
    nome.dispose(); paginas.dispose(); copias.dispose();
    super.dispose();
  }

  // Esvazia o formulário e sai do modo edição.
  void limpar() {
    nome.clear(); paginas.clear(); copias.clear(); idEdicao = null;
  }

  // Mostra uma mensagem rápida (SnackBar) na parte de baixo da tela.
  void avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // Botão Salvar: manda os textos para o Provider, que valida e grava.
  // Se der certo, limpa o formulário; se for recusado, mostra o motivo.
  Future<void> salvar() async {
    final provider = context.read<ImpressaoProvider>();
    final sucesso = await provider.salvar(id: idEdicao, nome: nome.text,
      paginasTexto: paginas.text, copiasTexto: copias.text);
    if (!mounted) return;
    if (sucesso) {
      setState(limpar);
      avisar('Documento salvo.');
    } else {
      avisar(provider.mensagem ?? 'Não foi possível salvar.');
    }
  }

  // Botão Alternar impressão: pede ao Provider para marcar/desmarcar este documento.
  Future<void> alternar(Map<String, Object?> documento) async {
    final provider = context.read<ImpressaoProvider>();
    final sucesso = await provider.alternar(documento);
    if (!mounted) return;
    if (!sucesso) avisar(provider.mensagem ?? 'Não foi possível alterar.');
  }

  // Abre um diálogo de confirmação e devolve true (Confirmar) ou false (Cancelar).
  Future<bool> confirmar(String titulo, String texto) async =>
    await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(titulo), content: Text(texto), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
      ])) ?? false;

  // Botão Excluir: pergunta antes e só exclui se o usuário confirmar.
  Future<void> excluir(Map<String, Object?> documento) async {
    if (!await confirmar('Excluir documento?', documento['nome'] as String)) return;
    if (!mounted) return;
    final provider = context.read<ImpressaoProvider>();
    final sucesso = await provider.excluir(documento['id'] as int);
    if (!mounted) return;
    if (sucesso && idEdicao == documento['id']) setState(limpar);
    if (!sucesso) avisar(provider.mensagem ?? 'Não foi possível excluir.');
  }

  // Botão Restaurar amostras: pede confirmação e volta aos 3 documentos iniciais.
  Future<void> restaurar() async {
    if (!await confirmar('Restaurar amostras?',
      'Os documentos atuais desta atividade serão substituídos pelas três amostras.')) return;
    if (!mounted) return;
    final provider = context.read<ImpressaoProvider>();
    final sucesso = await provider.restaurar();
    if (!mounted) return;
    if (sucesso) setState(limpar);
    if (!sucesso) avisar(provider.mensagem ?? 'Não foi possível restaurar.');
  }

  // Botão Recarregar: lê de novo os documentos do banco.
  Future<void> recarregar() async {
    final provider = context.read<ImpressaoProvider>();
    final sucesso = await provider.recarregar();
    if (!mounted) return;
    if (!sucesso) avisar(provider.mensagem ?? 'Não foi possível recarregar.');
  }

  // Monta um campo de texto do formulário. numero = true usa o teclado numérico.
  Widget campo(TextEditingController controller, String titulo, {bool numero = false}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
      controller: controller,
      keyboardType: numero ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: titulo, border: const OutlineInputBorder()),
    ));

  @override
  Widget build(BuildContext context) {
    // watch faz a tela acompanhar as notificações do Provider.
    final provider = context.watch<ImpressaoProvider>();
    // Se o banco não abriu, mostra só a tela de erro com botão "Tentar novamente".
    if (provider.falhaBanco != null) {
      return Scaffold(appBar: AppBar(title: const Text('Configuração')),
        body: Padding(padding: const EdgeInsets.all(24), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Não foi possível abrir o banco. Confira a preparação web.'),
            SelectableText(provider.falhaBanco!),
            FilledButton(onPressed: provider.carregando ? null : () { provider.iniciar(); },
              child: const Text('Tentar novamente')),
          ],
        )));
    }
    // Lista já filtrada conforme a opção escolhida no Dropdown.
    final documentos = provider.documentosVisiveis;
    return Scaffold(
      appBar: AppBar(title: const Text('Fila de impressão'), actions: [
        IconButton(tooltip: 'Recarregar do banco', onPressed: provider.carregando ? null : recarregar,
          icon: const Icon(Icons.refresh)),
        IconButton(tooltip: 'Restaurar amostras', onPressed: provider.carregando ? null : restaurar,
          icon: const Icon(Icons.restore)),
      ]),
      // AbsorbPointer bloqueia toques enquanto uma operação está em andamento.
      body: AbsorbPointer(absorbing: provider.carregando, child: SingleChildScrollView(
        padding: const EdgeInsets.all(20), child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (provider.carregando) const LinearProgressIndicator(),
            Text(idEdicao == null ? 'Novo documento' : 'Editar documento',
              style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            campo(nome, 'Documento'),
            campo(paginas, 'Páginas por cópia', numero: true),
            campo(copias, 'Cópias', numero: true),
            Row(children: [
              FilledButton(onPressed: salvar, child: const Text('Salvar')),
              if (idEdicao != null) TextButton(onPressed: () => setState(limpar),
                child: const Text('Cancelar edição')),
            ]),
            const SizedBox(height: 20),
            // Resumo geral: sempre conta TODOS os documentos, mesmo com filtro ativo.
            Text('Documentos: ${provider.totalDocumentos} | Folhas necessárias: ${provider.totalFolhas}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Filtro: Todos / Pendentes / Impressos.
            DropdownButton<String>(value: provider.filtro, isExpanded: true,
              items: ['Todos', 'Pendentes', 'Impressos'].map((opcao) =>
                DropdownMenuItem(value: opcao, child: Text(opcao))).toList(),
              onChanged: (opcao) { if (opcao != null) provider.alterarFiltro(opcao); }),
            // Lista vazia: aviso. Senão, um Card por documento (nome, páginas, cópias,
            // folhas, situação e botões Alternar impressão / Editar / Excluir).
            if (documentos.isEmpty) const Padding(padding: EdgeInsets.all(20),
              child: Text('Nenhum documento para este filtro.')),
            ...documentos.map((documento) => Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(documento['nome'] as String, style: Theme.of(context).textTheme.titleMedium),
                Text('Páginas por cópia: ${documento['paginas']} | Cópias: ${documento['copias']}'),
                Text('Folhas necessárias: ${provider.folhasDoDocumento(documento)}'),
                Text('Impresso: ${documento['impresso'] == 1 ? 'Sim' : 'Não'}'),
                Wrap(spacing: 8, children: [
                  TextButton(onPressed: () => alternar(documento),
                    child: const Text('Alternar impressão')),
                  TextButton(onPressed: () => setState(() {
                    idEdicao = documento['id'] as int;
                    nome.text = documento['nome'] as String;
                    paginas.text = documento['paginas'].toString();
                    copias.text = documento['copias'].toString();
                  }), child: const Text('Editar')),
                  TextButton(onPressed: () => excluir(documento), child: const Text('Excluir')),
                ]),
              ]),
            ))),
          ]),
        )),
      )),
    );
  }
}
