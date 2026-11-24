# Configurar o Supabase (login e sincronização)

O Lumen funciona sem nuvem. Estes passos ligam o login (e-mail/senha e Google), o perfil (nome, idade e igreja) e a sincronização entre aparelhos, inclusive o Web App no iPhone.

## 1. Criar o projeto e as tabelas

1. Em [supabase.com](https://supabase.com), crie um projeto (região `South America (São Paulo)`).
2. Abra **SQL Editor → New query**, cole todo o conteúdo de [`supabase/schema.sql`](../supabase/schema.sql) e clique em **Run**. O script pode ser executado de novo sem apagar dados.
3. Em **Project Settings → API Keys**, copie a **Project URL** (`https://<id-do-projeto>.supabase.co`) e a **Publishable key** (`sb_publishable_...`; a antiga *anon key* também funciona). Nunca use a *Secret key*.
4. Na raiz do projeto, copie `supabase.example.json` para `supabase.json` (ignorado pelo git) e cole os dois valores.

A chave anon/publishable vai dentro do app e é pública por natureza. Quem protege os dados é o RLS, ligado pelo script: cada pessoa só lê e altera as próprias linhas. Nunca use a chave `service_role` no app.

## 2. Checklist: Google OAuth e URLs de retorno (Android + Web App no iPhone)

1. **Google Cloud Console → APIs e serviços → Tela de consentimento OAuth**: crie a tela do tipo *Externo*, com nome "Lumen" e e-mail de suporte. Deixe *Domínios autorizados* **vazio**: o Google não aceita `supabase.co`, porque é um domínio compartilhado; só é preciso preencher esse campo com um domínio próprio. Publique a tela ("Em produção") para que qualquer conta Google consiga entrar.
2. **Google Cloud Console → Credenciais → Criar credenciais → ID do cliente OAuth → Aplicativo da Web**. Em *URIs de redirecionamento autorizados*, adicione `https://SEU-PROJETO.supabase.co/auth/v1/callback`. Copie o **Client ID** e o **Client Secret**. Um único cliente do tipo Web atende ao Android e ao iPhone, porque o login acontece no navegador.
3. **Supabase → Authentication → Sign In / Providers → Google**: ative o provedor e cole o Client ID e o Client Secret. Em **Email**, deixe *Confirm email* ligado (recomendado).
4. **Supabase → Authentication → URL Configuration**:
   - **Site URL**: o endereço do Web App, por exemplo `https://seu-usuario.github.io/lumen/`.
   - **Redirect URLs**: adicione as três:
     - `https://seu-usuario.github.io/lumen/` (Web App, iPhone/Safari)
     - `lumen://login-callback` (app Android)
     - `http://localhost:3000/` (testes locais com `flutter run -d chrome --web-port 3000`)
5. **Teste no iPhone**: abra o Web App no Safari, faça login com Google, toque em **Compartilhar → Adicionar à Tela de Início** e abra pelo ícone. O login com e-mail funciona dentro do app instalado. O login com Google pode abrir o Safari; nesse caso, volte ao ícone e entre de novo (a sessão do Safari e a do ícone são separadas no iOS).

> Os links de confirmação de cadastro e de "Esqueci minha senha" usam as mesmas URLs de retorno. Abra o e-mail no mesmo aparelho em que pediu o link.

## 3. Rodar e gerar builds com as chaves

```bash
# Android (emulador ou celular)
flutter run --dart-define-from-file=supabase.json

# APK com login
flutter build apk --release --split-per-abi --dart-define-from-file=supabase.json

# Web App (PWA). Troque /lumen/ pelo caminho onde o site será publicado.
flutter build web --release --base-href /lumen/ --dart-define-from-file=supabase.json
```

Sem `--dart-define-from-file`, o build sai sem nuvem: não mostra login e mantém tudo só no aparelho, como na versão 1.1.

## Como a sincronização funciona

- O app sempre lê e grava no banco local (Drift/SQLite, ou SQLite WebAssembly no navegador). Abre na hora e funciona 100% offline.
- Cada registro tem `id` UUID gerado no aparelho, `updated_at`, `is_synced` e `deleted_at` (exclusão lógica, para que exclusões feitas offline cheguem aos outros aparelhos).
- **Pull** (primeiro): baixa da nuvem o que mudou desde o último cursor de cada tabela e mescla por *Last-Write-Wins* (`updated_at`). Uma alteração local pendente e mais nova não é sobrescrita.
- **Push**: envia em lote (`upsert`) o que está com `is_synced = false` e marca como sincronizado.
- O cursor usa `synced_at`, carimbado pelo servidor, então um relógio errado no celular não faz nenhuma alteração ser pulada. No servidor, um gatilho descarta escritas mais antigas que a versão atual.
- A sincronização roda ao abrir o app, ao voltar para ele, quando a internet volta, alguns segundos depois de cada alteração e no botão **Sincronizar agora** (Configurações).
- **Aparelho novo**: o primeiro login baixa tudo (perfil, leituras, ciclos, planos, recitativos, orações e notas). A Bíblia continua sendo importada localmente.
- **Sem conta**: tudo o que foi feito sem login é vinculado à conta no primeiro login. Sair da conta envia o que estiver pendente e remove os dados da conta deste aparelho.

## Conhecer quem usa o app

No SQL Editor:

```sql
select church_name, count(*) as pessoas, round(avg(age)) as idade_media
from public.profiles
group by church_name
order by pessoas desc;
```
