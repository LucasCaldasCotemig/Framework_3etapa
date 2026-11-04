# Revisão 1

Nome: Lucas Caldas Lima
Turma: 3A2 (Framework)

## Como os testes foram feitos

- `flutter analyze`: nenhum problema encontrado. `flutter test`: os 9 testes do projeto passaram (Flutter 3.27.1, o mesmo do projeto).
- O app foi compilado com `flutter build web --release` e aberto no Chromium. Os testes abaixo foram feitos nele, com o SQLite do navegador, e a página foi recarregada para conferir a persistência.

| Teste | Resultado esperado | Resultado encontrado |
|---|---|---|
| Nome vazio/espaços | O formulário recusa e mostra mensagem | Com o nome só com espaços, o cadastro foi recusado e apareceu "Preencha este campo (só espaços não vale)." sob o campo. |
| Quantidade negativa | Recusa com mensagem | Com `-1`, apareceu "A quantidade não pode ser negativa." e nada foi salvo. |
| Quantidade decimal | Recusa com mensagem | Com `1.5`, apareceu "A quantidade deve ser inteira, sem decimais." Com letras (`abc`) apareceu "Digite apenas números inteiros, como 0, 1 ou 10." Campo vazio: "Informe a quantidade." |
| Nome repetido com maiúsculas/espaços | Cadastro recusado | Ao cadastrar `  microfone ` apareceu "Já existe um material com esse nome." e a lista não mudou. |
| Edição mantendo o próprio nome | Edição permitida | Editar o Projetor com o nome `  PROJETOR ` e quantidade 1 foi aceito ("Material salvo."). |
| Edição para o nome de outro material | Edição recusada | Editar o Projetor com o nome `cabo hdmi` mostrou "Já existe um material com esse nome." e os dados continuaram os mesmos. |
| Cadastro com atualização automática | Material aparece na lista sem recarregar | Projetor (Vídeo, 5, 2) e Tripé (Foto, 0, 0) foram cadastrados, apareceu "Material salvo." e os dois entraram na lista em ordem alfabética. |
| Edição persistida após recarregar | Dados alterados permanecem | Depois da edição, a página foi recarregada (F5) e o Projetor continuou com quantidade 1, agora "Estoque baixo". |
| Cancelamento da exclusão | Registro permanece | Ao clicar em Excluir no Tripé e depois em Cancelar, o Tripé continuou na lista. |
| Exclusão individual | Só o selecionado some | Ao confirmar a exclusão do Tripé apareceu "Material excluído." Depois de recarregar, sobraram Cabo HDMI, Caixa de som, Extensão, Microfone e Projetor. |
| Quantidade zero e mínimo zero | "Sem estoque" | O Tripé (0 e 0) mostrou "Sem estoque". A Extensão (0 e 2) também. |
| Quantidade igual ao mínimo | "Estoque adequado" | Caso testado no código: `situacao` com 2 e 2 devolve "Estoque adequado" (teste automatizado). Na lista, o Cabo HDMI (2 e 3) mostrou "Estoque baixo" e o Microfone (4 e 2) mostrou "Estoque adequado". |

Observação: depois de salvar, os campos do formulário continuaram com o texto digitado, sem limpar. Isso vem da tela `materiais_page.dart`, que veio pronta e não foi alterada.

## Explique uma validação

Qual validação foi escolhida?

A validação da quantidade: aceitar somente números inteiros maiores ou iguais a zero.

Em qual arquivo e método ela foi implementada?

No arquivo `lib/utils/validadores.dart`, no método `Validadores.quantidade`.

Por que esse local é adequado para essa responsabilidade?

A regra só precisa de um texto para decidir se ele serve, então não depende da tela, do banco nem do estado do app. Por isso ela fica em `utils`, separada das outras camadas. Assim o mesmo método é usado pelo formulário (`validator` do `TextFormField` em `materiais_page.dart`) e de novo pela ViewModel em `salvar`, que confere de novo caso a operação seja chamada fora da tela. Se a regra mudar, a alteração é feita em um único lugar. O repositório fica só com o acesso ao SQLite.
