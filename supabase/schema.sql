-- =============================================================================
-- Lumen — esquema da nuvem (Supabase / PostgreSQL)
--
-- Execute uma única vez no SQL Editor do painel do Supabase. O script é
-- idempotente: pode ser executado de novo sem apagar dados.
--
-- A Bíblia (livros e versículos) NÃO vai para a nuvem: fica só no aparelho.
-- Aqui ficam apenas os dados gerados pelo usuário.
--
-- Convenções da sincronização (offline-first):
-- * id          UUID gerado no aparelho (registros criados offline não colidem);
-- * updated_at  momento da última alteração NO APARELHO (base do Last-Write-Wins);
-- * deleted_at  exclusão lógica: a exclusão feita offline chega aos outros aparelhos;
-- * synced_at   momento em que o SERVIDOR gravou a linha. O app baixa as
--               alterações com synced_at maior que o último recebido, então um
--               relógio errado no celular não faz nenhuma alteração ser pulada.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Gatilho comum: carimba synced_at e aplica o Last-Write-Wins no servidor
-- (uma versão mais antiga que chega atrasada não sobrescreve a mais nova).
-- -----------------------------------------------------------------------------
create or replace function public.lumen_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    -- Ninguém transfere uma linha para outra conta.
    if to_jsonb(new) ? 'user_id' and (to_jsonb(new) ->> 'user_id') is distinct from (to_jsonb(old) ->> 'user_id') then
      raise exception 'user_id não pode ser alterado';
    end if;
    if new.updated_at < old.updated_at then
      return null; -- versão mais antiga: ignora a escrita (Last-Write-Wins)
    end if;
  end if;
  new.synced_at := clock_timestamp();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- 1. Perfil (onboarding: nome, idade e igreja)
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text not null check (char_length(full_name) between 1 and 120),
  age         int  check (age > 0 and age < 120),
  church_name text not null check (char_length(church_name) between 1 and 120),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  synced_at   timestamptz not null default clock_timestamp()
);

-- -----------------------------------------------------------------------------
-- 2. Progresso do usuário (espelho das tabelas locais do Drift)
-- -----------------------------------------------------------------------------

-- Ciclos de leitura da Bíblia (cada leitura pertence a um ciclo; sem eles o
-- progresso "x de 1.189 capítulos" não poderia ser restaurado num aparelho novo).
create table if not exists public.reading_cycles (
  id         uuid primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  started_at timestamptz not null,
  ended_at   timestamptz,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at  timestamptz not null default clock_timestamp()
);

create table if not exists public.reading_logs (
  id         uuid primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  book_id    int  not null check (book_id between 1 and 66),
  chapter    int  not null check (chapter between 1 and 150),
  read_at    timestamptz not null,
  source     text not null check (source in ('app', 'physical_bible')),
  cycle_id   uuid not null,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at  timestamptz not null default clock_timestamp()
);

create table if not exists public.recitatives (
  id                  uuid primary key,
  user_id             uuid not null references auth.users (id) on delete cascade,
  book_id             int  not null check (book_id between 1 and 66),
  chapter             int  not null check (chapter >= 1),
  verse_start         int  not null check (verse_start >= 1),
  verse_end           int  check (verse_end is null or verse_end >= verse_start),
  verse_text_snapshot text not null,
  service_date        timestamptz not null,
  congregation        text,
  notes               text,
  status              text not null check (status in ('pending', 'recited')),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  deleted_at          timestamptz,
  synced_at           timestamptz not null default clock_timestamp()
);

create table if not exists public.prayer_requests (
  id               uuid primary key,
  user_id          uuid not null references auth.users (id) on delete cascade,
  title            text not null check (char_length(title) between 1 and 200),
  description      text,
  category         text not null,
  status           text not null check (status in ('active', 'answered')),
  pray_count       int  not null default 0 check (pray_count >= 0),
  last_prayed_at   timestamptz,
  answered_at      timestamptz,
  answer_testimony text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  deleted_at       timestamptz,
  synced_at        timestamptz not null default clock_timestamp()
);

create table if not exists public.verse_notes (
  id         uuid primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  book_id    int  not null check (book_id between 1 and 66),
  chapter    int  not null check (chapter >= 1),
  verse      int  check (verse is null or verse >= 1),
  content    text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at  timestamptz not null default clock_timestamp()
);

-- Planos de leitura iniciados (o plano em si é fixo no app; aqui só a inscrição).
create table if not exists public.plan_enrollments (
  id         uuid primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  plan_id    text not null,
  started_at timestamptz not null,
  ended_at   timestamptz,
  completed  boolean not null default false,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at  timestamptz not null default clock_timestamp()
);

-- -----------------------------------------------------------------------------
-- Índices: o download incremental filtra por usuário e ordena por (synced_at, id).
-- -----------------------------------------------------------------------------
create index if not exists profiles_synced_idx         on public.profiles         (synced_at, id);
create index if not exists reading_cycles_sync_idx     on public.reading_cycles   (user_id, synced_at, id);
create index if not exists reading_logs_sync_idx       on public.reading_logs     (user_id, synced_at, id);
create index if not exists recitatives_sync_idx        on public.recitatives      (user_id, synced_at, id);
create index if not exists prayer_requests_sync_idx    on public.prayer_requests  (user_id, synced_at, id);
create index if not exists verse_notes_sync_idx        on public.verse_notes      (user_id, synced_at, id);
create index if not exists plan_enrollments_sync_idx   on public.plan_enrollments (user_id, synced_at, id);

-- -----------------------------------------------------------------------------
-- Gatilhos
-- -----------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles', 'reading_cycles', 'reading_logs', 'recitatives',
    'prayer_requests', 'verse_notes', 'plan_enrollments'
  ] loop
    execute format('drop trigger if exists lumen_before_write on public.%I', t);
    execute format(
      'create trigger lumen_before_write before insert or update on public.%I '
      'for each row execute function public.lumen_before_write()', t);
  end loop;
end;
$$;

-- -----------------------------------------------------------------------------
-- 3. Segurança: Row Level Security
-- Cada usuário só enxerga e altera as próprias linhas. (select auth.uid()) é
-- avaliado uma vez por consulta, não por linha (recomendação do Supabase).
-- -----------------------------------------------------------------------------
alter table public.profiles         enable row level security;
alter table public.reading_cycles   enable row level security;
alter table public.reading_logs     enable row level security;
alter table public.recitatives      enable row level security;
alter table public.prayer_requests  enable row level security;
alter table public.verse_notes      enable row level security;
alter table public.plan_enrollments enable row level security;

-- Perfil: a chave é o próprio id do usuário.
drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "profiles_delete_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);
create policy "profiles_update_own" on public.profiles
  for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "profiles_delete_own" on public.profiles
  for delete to authenticated using ((select auth.uid()) = id);

-- Demais tabelas: dono = user_id.
do $$
declare
  t text;
begin
  foreach t in array array[
    'reading_cycles', 'reading_logs', 'recitatives',
    'prayer_requests', 'verse_notes', 'plan_enrollments'
  ] loop
    execute format('drop policy if exists %I on public.%I', t || '_select_own', t);
    execute format('drop policy if exists %I on public.%I', t || '_insert_own', t);
    execute format('drop policy if exists %I on public.%I', t || '_update_own', t);
    execute format('drop policy if exists %I on public.%I', t || '_delete_own', t);
    execute format(
      'create policy %I on public.%I for select to authenticated using ((select auth.uid()) = user_id)',
      t || '_select_own', t);
    execute format(
      'create policy %I on public.%I for insert to authenticated with check ((select auth.uid()) = user_id)',
      t || '_insert_own', t);
    execute format(
      'create policy %I on public.%I for update to authenticated '
      'using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)',
      t || '_update_own', t);
    execute format(
      'create policy %I on public.%I for delete to authenticated using ((select auth.uid()) = user_id)',
      t || '_delete_own', t);
  end loop;
end;
$$;

-- Visitantes sem login (role anon) não têm acesso a nenhuma tabela.
revoke all on public.profiles, public.reading_cycles, public.reading_logs, public.recitatives,
  public.prayer_requests, public.verse_notes, public.plan_enrollments from anon;
grant select, insert, update, delete on public.profiles, public.reading_cycles, public.reading_logs,
  public.recitatives, public.prayer_requests, public.verse_notes, public.plan_enrollments to authenticated;

-- -----------------------------------------------------------------------------
-- Consulta útil para conhecer o perfil de quem usa o app (rode no SQL Editor):
--   select church_name, count(*) as pessoas, round(avg(age)) as idade_media
--   from public.profiles group by church_name order by pessoas desc;
-- -----------------------------------------------------------------------------
