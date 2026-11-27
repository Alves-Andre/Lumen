<p align="center">
  <img src="assets/branding/lumen_icon.png" alt="Lumen" width="120" />
</p>

<h1 align="center">Lumen</h1>

<p align="center">
  Vida devocional cristã, offline: leitura da Bíblia, ofensiva diária, recitativos e caderno de oração.<br/>
  Pensado para as práticas da Congregação Cristã no Brasil (CCB).
</p>

---

## Baixar e instalar (Android)

**[⬇️ Baixar o Lumen 1.2.0 para Android (APK, 24 MB)](apk/Lumen-1.2.0-android.apk)**

1. No celular, abra o link acima e toque em **Download** (ou em "View raw").
2. Abra o arquivo baixado. O Android vai pedir para **permitir a instalação de apps desconhecidos** pelo navegador ou gerenciador de arquivos: permita só para esta instalação.
3. Toque em **Instalar** e abra o Lumen.

> Serve para celulares Android 7.0 ou mais novos, de 64 bits (praticamente todos os aparelhos de 2017 em diante).
> Para atualizar, instale o APK novo por cima do antigo: seus dados são mantidos.

## Primeiro uso: importar a Bíblia

Por respeito aos direitos autorais das traduções, **o Lumen não vem com o texto bíblico**. Na primeira abertura, ele pede que você escolha uma tradução e importe o arquivo dela. Isso é feito **uma única vez**; depois, tudo funciona sem internet.

1. Na tela de boas-vindas, escolha a tradução. A **ARC** vem sugerida, por ser a usada nos cultos da CCB e nos recitativos.
2. Baixe o arquivo pelo link que o app mostra (botão **Copiar link**). No celular, abra o link, toque nos três pontinhos do navegador e escolha **Baixar**; o arquivo vai para a pasta *Downloads*, ou para o app *Arquivos* no iPhone.
3. Toque em **Selecionar arquivo** e escolha o `.json` baixado. Aguarde alguns segundos enquanto o app importa e prepara a busca.

| Tradução | Arquivo |
|---|---|
| ARC: Almeida Revista e Corrigida | [arc.json](https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/arc.json) |
| ACF: Almeida Corrigida Fiel | [acf.json](https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/acf.json) |
| AA: Almeida Revisada Imprensa Bíblica | [aa.json](https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/aa.json) |
| NVI: Nova Versão Internacional | [nvi.json](https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/nvi.json) |
| KJA: King James Atualizada | [kja.json](https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/kja.json) |
| ARA, NAA, NVT, NTLH | Arquivo próprio, no mesmo formato (não estão no repositório de origem) |
| Outra tradução | **Importar outra tradução**, informando a sigla e o nome |

Para adicionar, trocar ou remover traduções depois, use **Configurações → Traduções da Bíblia**. Nessa tela você escolhe a tradução de **leitura**, que também pode ser trocada no topo do leitor, e a **principal**, usada no texto dos novos recitativos (por padrão, a ARC). Substituir ou remover uma tradução não afeta leituras, anotações nem recitativos.

O arquivo precisa ter os 66 livros com a contagem de capítulos tradicional. Se algum livro vier com capítulos a mais ou a menos, o app recusa e diz qual livro está com defeito.

## Funcionalidades

**Bíblia**
- Várias traduções (ARC, ARA, ACF, AA, NAA, NVI, NVT, NTLH, KJA ou qualquer outra importada), com troca rápida no leitor.
- Leitura com ajuste de fonte e temas Claro, Sépia, Escuro ou Automático.
- Busca por palavras que ignora acentos e maiúsculas e aceita palavras incompletas ("past" encontra "pastores"); o resultado abre o capítulo no versículo.
- Tocar num versículo: copiar, criar nota devocional ou salvar como recitativo.
- "Concluir e ir para o próximo" sem interromper a leitura; o resumo da sessão aparece ao parar.
- Registro retroativo (outra data ou Bíblia física), com vários capítulos de uma vez.

**Constância**
- Ofensiva diária com Escudos: a cada 15 dias seguidos de leitura, 1 escudo; cada escudo protege a ofensiva num dia sem leitura (cumulativos).
- Histórico em calendário com dias lidos, escudos usados e dias com devocional.
- Jornada Bíblica: capítulos lidos no ciclo, média dos últimos 14 dias e previsão de término.
- Planos de leitura opcionais: Bíblia em 1 ou 2 anos, Novo Testamento em 90 dias, Evangelhos em 30 dias, Salmos e Provérbios em 31 dias.

**Recitativos (Culto de Jovens e Menores)**
- Cadastro com o texto da ARC preenchido automaticamente, data do culto, comum congregação e observações.
- Modo treino em 3 níveis, com palavras ocultas reveladas ao toque.
- Lembranças "Há N anos, neste dia, você recitou…".

**Oração e devocional**
- Caderno de oração com "Orei hoje (+1)" e orações respondidas com testemunho.
- Diário com as anotações feitas durante a leitura.

**Outros**
- Widget na tela inicial (Android) com ofensiva, escudos, leitura de hoje e próximo recitativo.
- Lembrete diário de leitura e notificações de lembranças, todos locais.
- Backup e restauração em `.json`.
- Modo escuro e paleta própria "Céu & Linho" / "Noite".
- Login opcional (e-mail/senha ou Google) com sincronização offline-first entre aparelhos; sem conta, tudo fica só no aparelho.
- Web App instalável (PWA) para iPhone, com o banco funcionando offline no navegador.

## Conta e sincronização (opcional)

Com o Supabase configurado, o app pede login na primeira abertura (com a opção **Continuar sem conta**). Depois, faz três perguntas rápidas (nome, idade e igreja) e sincroniza leituras, ciclos, planos, recitativos, orações e notas entre aparelhos. O app continua abrindo na hora e funcionando 100% offline; a nuvem só recebe as alterações quando há internet.

Passo a passo (SQL, Google OAuth, URLs de retorno e builds): **[docs/supabase-setup.md](docs/supabase-setup.md)**. O esquema do banco na nuvem, com RLS, está em [`supabase/schema.sql`](supabase/schema.sql).

## Web App (iPhone)

O mesmo código roda no navegador como PWA:

```bash
flutter build web --release --base-href /lumen/ --dart-define-from-file=supabase.json
```

Publique a pasta `build/web` (GitHub Pages, Netlify, Vercel…). No iPhone, abra o endereço no Safari e toque em **Compartilhar → Adicionar à Tela de Início**. O banco é SQLite em WebAssembly (`web/sqlite3.wasm` e `web/drift_worker.js`, gerados por `tool/setup_web.ps1`) e os dados ficam no próprio navegador. Na web não há lembretes por notificação nem widget.

## Tecnologias

| Área | Escolha |
|---|---|
| Framework | Flutter 3.50 (Dart 3.14), Material 3 (`material_ui`) |
| Estado | Riverpod 3 (`riverpod_generator`) |
| Banco local | Drift + SQLite, com índice FTS5 para a busca |
| Navegação | go_router (`StatefulShellRoute`, 4 abas) |
| Notificações | flutter_local_notifications + timezone |
| Widget | home_widget (provider nativo em Kotlin) |
| Backup | share_plus + file_picker |
| Nuvem (opcional) | Supabase (Auth + PostgreSQL com RLS), connectivity_plus, uuid |
| Web | Drift WASM (SQLite em WebAssembly, OPFS/IndexedDB) |

## Estrutura

```
lib/
├── app/                 # MaterialApp, abas e portão de inicialização (login, perfil, Bíblia)
├── core/
│   ├── database/        # Tabelas Drift, DAOs, conexão nativa/web, importação das Bíblias, migrações
│   ├── backup/          # Exportar/importar JSON
│   ├── cloud/           # Chaves e inicialização do Supabase
│   ├── notifications/   # Lembretes locais
│   ├── providers/       # Banco, preferências, sincronização de notificações
│   ├── router/          # Rotas (go_router)
│   ├── settings/        # Preferências do usuário
│   ├── theme/           # Paletas e tema
│   ├── utils/           # Datas, referências bíblicas, formatação
│   └── widgets/         # Componentes visuais (botões 3D, cards…)
└── features/
    ├── auth/            # Login (e-mail e Google), perfil (onboarding), nova senha
    ├── bible/           # Livros, leitor, busca, leitura retroativa
    ├── dashboard/       # Aba Hoje e widget da tela inicial
    ├── reading_plan/    # Ofensiva, projeção, planos, histórico
    ├── recitatives/     # Recitativos, treino, lembranças
    ├── prayer/          # Caderno de oração e calendário de leituras
    ├── devotions/       # Anotações devocionais
    ├── settings/        # Configurações
    └── sync/            # Motor de sincronização Drift ⇄ Supabase (push, pull, LWW)
```

A lógica de regras (ofensiva com escudos, projeção, planos, lembranças e memorização) fica em `domain/` como funções puras e é coberta por testes em `test/`.

## Como rodar

### Pré-requisitos
- Flutter 3.50+ (`flutter doctor` sem erros para Android)
- Android SDK com a plataforma 37 e JDK 17
- O arquivo `arc.json` para importar no primeiro uso (veja abaixo)

### Passos

```bash
flutter pub get
dart run build_runner build   # gera os arquivos *.g.dart (Drift e Riverpod)
flutter test
flutter run                                        # sem nuvem
flutter run --dart-define-from-file=supabase.json  # com login e sincronização
```

Os arquivos `*.g.dart` estão versionados; só é preciso rodar o `build_runner` depois de mudar tabelas ou providers.

### Textos bíblicos no desenvolvimento

O app não empacota nenhuma Bíblia (`assets/bible_*.json` está no `.gitignore`); em desenvolvimento, importe pelo próprio app como no primeiro uso. No emulador, envie o arquivo para a pasta Downloads antes:

```bash
adb push arc.json /sdcard/Download/arc.json
```

Formatos aceitos: uma lista de livros em ordem canônica (`[{"name", "chapters": [["v1", "v2"], …], "abbrev"?, "id"?}]`) ou um objeto `{"books": [...]}` (ver [docs/bible_arc.sample.json](docs/bible_arc.sample.json)). A importação exige os 66 livros e os 1.189 capítulos, sem versículos vazios; sem `abbrev`, o app usa as abreviações canônicas.

> **Direitos autorais:** a ARC pertence à Sociedade Bíblica do Brasil e a NVI à Biblica. Por isso nem o repositório nem o APK contêm os textos — cada usuário obtém e importa o próprio arquivo. A licença do repositório de origem cobre a organização dos dados, não os textos.

## Gerar o APK

```bash
flutter build apk --release --split-per-abi
```

O arquivo para celulares atuais é `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Para publicar uma nova versão para download, suba o `version` no `pubspec.yaml`, copie esse arquivo para `apk/Lumen-<versão>-android.apk` e atualize o link no início deste README.

Antes de copiar, confirme que nenhum texto bíblico foi empacotado (o APK não deve conter `bible_*.json`). APKs locais feitos com Bíblias embutidas ficam em `/dist`, que é ignorado pelo git.

**No Windows**, se o Gradle falhar com `Unable to establish loopback connection`, use uma pasta temporária com caminho curto:

```bash
TEMP='D:\tmp' TMP='D:\tmp' flutter build apk --release --split-per-abi
```

### Ícone

A logo fica em `assets/branding/lumen_logo.png`. Para regenerar os ícones (Android adaptativo, iOS e abertura):

```bash
dart run tool/make_icons.dart
dart run flutter_launcher_icons
```

## Banco de dados

Schema Drift na versão 6, com migrações automáticas a partir da 1. Tabelas: `books`, `verses` (uma linha por versículo e tradução), `installed_translations` (traduções importadas neste aparelho; não sincroniza), `verses_fts` (índice de busca), `reading_cycles`, `reading_logs`, `recitatives`, `prayer_requests`, `verse_notes`, `plan_enrollments`, `user_profiles` e `app_settings_entries`.

Na v5 as tabelas do usuário passaram a usar `id` UUID e ganharam `updated_at`, `is_synced` e `deleted_at` (exclusão lógica). A migração converte os dados existentes e os deixa pendentes para subir à nuvem no primeiro login. Consultas de leitura sempre filtram `deleted_at IS NULL`.

Notas para quem for mexer:
- Providers que retornam classes geradas pelo Drift (`Book`, `Verse`…) são escritos à mão, sem `@riverpod`, porque o `riverpod_generator` não enxerga tipos de arquivos `part` do Drift (ver `build.yaml`).
- Os recitativos guardam o texto da tradução principal (ARC por padrão) no momento do cadastro, independentemente da tradução de leitura.
- O backup usa o formato `devocional-backup` (nome anterior do app); não mude, para manter compatibilidade. A versão 2 do backup usa UUID; backups v1 (ids inteiros) são convertidos na importação.
- Chaves `sync.*` em `app_settings_entries` são estado da sincronização deste aparelho e ficam fora do backup.

## Pendências antes de publicar

- [ ] Trocar o `applicationId` (`com.example.devocional`) em `android/app/build.gradle.kts`. Mudar depois de instalado cria outro app, então os usuários precisam restaurar o backup.
- [ ] Configurar uma chave de assinatura de release (hoje o release usa a chave de depuração).
- [ ] Se um dia o app embutir os textos bíblicos (ou for para as lojas), obter licenças da SBB (ARC) e da Biblica (NVI).
- [ ] iOS: compilar num Mac com Xcode e criar a extensão do widget (WidgetKit).
- [ ] Política de privacidade: obrigatória nas lojas e recomendada agora que o app coleta nome, idade e igreja.
- [ ] Para login com Google nativo no Android (sem abrir o navegador), seria preciso um cliente OAuth Android com o SHA-1 da chave de assinatura; hoje o login usa o fluxo web do Supabase, que dispensa isso.
