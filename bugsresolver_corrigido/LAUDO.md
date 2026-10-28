# LAUDO.md — Operação Resgate: Detetives de Bugs

Projeto: Central de Achados e Perdidos (Flutter + Firebase Auth + Firestore).
Nenhuma funcionalidade foi removida, a autenticação foi mantida e as regras de segurança não foram desativadas (o arquivo `firestore.rules` exige login e dono para alterar status).

Observação sobre os testes: a correção foi feita por leitura e rastreamento do código (`main` → `GatePage` → `CentralPage` → `DetalhePage`). O Flutter não pôde ser executado onde o laudo foi escrito; a coluna **Teste** descreve como cada correção deve ser confirmada no app (duas contas Google em janelas anônimas) e o roteiro está no final.

## Missão 1 — Fazer o sistema funcionar

**Bug 01**
**Arquivo:** `lib/firebase_options.dart` (ausente) / `lib/main.dart`
**Sintoma:** o projeto não compila: `main.dart` importa `firebase_options.dart`, que não existe.
**Causa:** o arquivo gerado pelo FlutterFire CLI não veio no projeto.
**Correção:** criado `lib/firebase_options.dart` com a classe `DefaultFirebaseOptions` e valores `SUBSTITUA_...`. Para rodar, trocar pelos dados reais com `flutterfire configure` do projeto Firebase.
**Teste:** o erro "Target of URI doesn't exist" some no analisador; o app só inicia com as chaves reais preenchidas.

**Bug 02**
**Arquivo:** `lib/pages/central_page.dart` (subtítulo do `ListTile`)
**Sintoma:** erro de compilação "String is not terminated".
**Causa:** a string do subtítulo tinha uma quebra de linha real no meio, em vez do escape `\n`.
**Correção:** `'${o.local} • ${...}\nPor ${o.autorNome}'` em uma linha só.
**Teste:** analisador sem erro na linha; na lista cada card mostra local/status e, na linha de baixo, "Por <nome>".

**Bug 03**
**Arquivo:** `lib/pages/central_page.dart` (`onTap`)
**Sintoma:** erro "required named parameter 'ocorrencia' must be provided"; ao tocar numa ocorrência não abriria os detalhes.
**Causa:** `DetalhePage()` era chamado sem o argumento obrigatório.
**Correção:** `DetalhePage(ocorrencia: o)`.
**Teste:** tocar numa ocorrência abre a tela "Investigação" com título, local, responsável e descrição daquela ocorrência.

**Bug 04**
**Arquivo:** `test/widget_test.dart`
**Sintoma:** `flutter test` e o analisador acusam `MyApp` e `package:bugsresolver` inexistentes.
**Causa:** teste padrão do contador, de outro projeto; o pacote se chama `central_achados` e o app é `CentralApp`.
**Correção:** teste substituído por testes simples do modelo `Ocorrencia` e de um widget, sem depender do Firebase.
**Teste:** `flutter test` sem erro de importação.

**Bug 05**
**Arquivo:** `pubspec.yaml`
**Sintoma:** `flutter_test` e `flutter_lints` usados (teste e `analysis_options.yaml`) mas não declarados; o `pubspec.lock` já os lista como dependências de desenvolvimento.
**Causa:** bloco `dev_dependencies` removido.
**Correção:** adicionado `dev_dependencies` com `flutter_test` (sdk flutter) e `flutter_lints: ^5.0.0` (mesma versão do lock).
**Teste:** `flutter pub get` sem alterar o lock e o `include: package:flutter_lints/flutter.yaml` resolve.

## Missão 2 — Cadastro e consulta

**Bug 06**
**Arquivo:** `lib/pages/central_page.dart` (`cadastrar`)
**Sintoma:** deixando só o título ou só o local em branco, a ocorrência era registrada.
**Causa:** validação com `&&` (só bloqueava se os dois estivessem vazios).
**Correção:** trocado por `||`.
**Teste:** com título ou local vazio aparece "Informe título e local." e nada é gravado.

**Bug 07**
**Arquivo:** `lib/services/central_service.dart` (`registrar`)
**Sintoma:** o responsável era identificado pelo e-mail, que não é o identificador do usuário; a checagem de dono nunca batia com o `uid`.
**Causa:** `'autorId': u.email ?? ''`.
**Correção:** `'autorId': u.uid`.
**Teste:** no documento do Firestore, `autorId` é o uid da conta que registrou.

**Bug 08**
**Arquivo:** `lib/models/ocorrencia.dart` (`fromDoc`)
**Sintoma:** o dono nunca era reconhecido (botão de status não aparecia).
**Causa:** `autorId` lia o campo `autorNome`.
**Correção:** `autorId: d['autorId']`.
**Teste:** só a conta que registrou vê o botão "Marcar como resolvido".

**Bug 09**
**Arquivo:** `lib/models/ocorrencia.dart` (`fromDoc`)
**Sintoma:** casos em aberto apareciam como "Resolvido" e vice-versa.
**Causa:** `resolvido` lido com negação (`!`).
**Correção:** `resolvido: d['resolvido'] as bool? ?? false`.
**Teste:** ocorrência nova aparece como "Em aberto".

**Bug 10**
**Arquivo:** `lib/pages/central_page.dart` (`SwitchListTile`)
**Sintoma:** ligar "Somente não resolvidos" desligava o filtro (o interruptor ficava sempre ao contrário).
**Causa:** `somenteAbertos = !value`.
**Correção:** `somenteAbertos = value`.
**Teste:** ligar o interruptor ativa o filtro e ele permanece ligado.

**Bug 11**
**Arquivo:** `lib/pages/central_page.dart` (filtro da lista)
**Sintoma:** com o filtro ligado só apareciam os casos resolvidos.
**Causa:** `where((o) => o.resolvido)`.
**Correção:** `where((o) => !o.resolvido)`.
**Teste:** com o filtro ligado só aparecem casos "Em aberto".

**Bug 12**
**Arquivo:** `lib/services/central_service.dart` (`acompanhar`)
**Sintoma:** as ocorrências mais recentes ficavam no fim da lista.
**Causa:** `orderBy('criadoEm', descending: false)`.
**Correção:** `descending: true`.
**Teste:** a ocorrência recém-registrada aparece no topo.

**Bug 13**
**Arquivo:** `lib/services/central_service.dart` (`alterarStatus`)
**Sintoma:** marcar como resolvido gravava o mesmo valor que já existia; nada mudava e não era possível reabrir.
**Causa:** `update({'resolvido': item.resolvido})`.
**Correção:** `update({'resolvido': !item.resolvido})`.
**Teste:** o botão alterna entre "Marcar como resolvido" e "Reabrir" e o campo muda no Firestore.

## Missão 3 — Multiusuário

**Bug 14**
**Arquivo:** `lib/services/central_service.dart` (`enviarPista`)
**Sintoma:** todas as pistas iam para um documento fixo chamado `pistas`; nenhuma aparecia na ocorrência correta.
**Causa:** `.doc('pistas')` em vez do id da ocorrência.
**Correção:** `.doc(ocorrenciaId)`.
**Teste:** pista enviada pela conta B aparece na ocorrência certa, para as duas contas, em tempo real.

**Bug 15**
**Arquivo:** `lib/pages/detalhe_page.dart` (`enviar`)
**Sintoma:** com texto digitado o botão de enviar não fazia nada; com o campo vazio gravava uma pista vazia.
**Causa:** condição invertida (`isNotEmpty`).
**Correção:** `if (pista.text.trim().isEmpty) return;`.
**Teste:** campo vazio não envia; com texto envia.

**Bug 16**
**Arquivo:** `lib/pages/detalhe_page.dart` (`enviar`)
**Sintoma:** mesmo quando enviava, a pista ia com mensagem vazia.
**Causa:** `enviarPista(id, '')`.
**Correção:** `enviarPista(id, pista.text)`.
**Teste:** o texto digitado aparece na lista de pistas com o nome de quem enviou.

## Autorização (regras de segurança)

O app só deixa o dono alterar o status (`alterarStatus` compara o `uid`). Para a regra valer também no servidor foi incluído `firestore.rules`: leitura só para logados; criação exige `autorId == uid`; alteração de ocorrência só pelo dono; pistas só criadas por logados com o próprio `autorId`. As regras devem ser publicadas no Firebase (Console > Firestore > Regras).

Ocorrências antigas gravadas com e-mail em `autorId` (Bug 07) não terão dono reconhecido; registrar novas para testar.

## Roteiro de teste com duas contas

1. Copiar `lib/firebase_options.dart` real (`flutterfire configure`), `flutter pub get`, `flutter run -d chrome --web-port 8080`.
2. Janela 1 (conta A): entrar, registrar dois objetos com locais diferentes (sem dados pessoais); conferir título/local/"Por <nome>" e ordem (mais novo primeiro).
3. Janela anônima 2 (conta B): entrar e conferir que as ocorrências da conta A aparecem sem recarregar.
4. Na conta B: abrir uma ocorrência, enviar uma pista; conferir que aparece nas duas janelas e só nessa ocorrência. Conferir que a conta B não vê o botão de status.
5. Na conta A: marcar como resolvido; ligar "Somente não resolvidos" e confirmar que o caso some; desligar e ver "Resolvido"; reabrir.
6. Capturar a tela com as duas contas vendo a mesma ocorrência e salvar como `captura_duas_contas.png`.
