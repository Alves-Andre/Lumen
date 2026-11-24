import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/features/sync/data/sync_service.dart';
import 'package:devocional/features/sync/data/sync_tables.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_sync_remote.dart';

const _user = '11111111-1111-4111-8111-111111111111';
const _otherUser = '22222222-2222-4222-8222-222222222222';

/// Horário [hours] horas à frente (depois de qualquer escrita feita pelo teste).
DateTime _later(int hours) => DateTime.now().add(Duration(hours: hours));

/// Um "aparelho": banco local próprio + serviço de sincronização apontando
/// para o mesmo servidor falso.
class _Device {
  _Device(FakeSyncRemote remote) : db = AppDatabase.forTesting(NativeDatabase.memory()) {
    service = SyncService(db, remote);
  }

  final AppDatabase db;
  late final SyncService service;

  Future<void> seedBible() => db.batch((b) {
        b.insert(db.books, const BooksCompanion(
          id: Value(45),
          name: Value('Romanos'),
          abbrev: Value('Rm'),
          testament: Value('NT'),
          chaptersCount: Value(16),
        ));
        b.insertAll(db.verses, [
          for (var v = 1; v <= 3; v++)
            VersesCompanion(bookId: const Value(45), chapter: const Value(8), verse: Value(v), verseText: Value('Verso $v.')),
        ]);
      });

  Future<void> login(String userId) => service.attachUser(userId);

  /// Força o `updated_at` (os testes de Last-Write-Wins precisam de horários conhecidos).
  Future<void> setUpdatedAt(String table, String id, DateTime at) => db.customUpdate(
        'UPDATE $table SET updated_at = ? WHERE id = ?',
        variables: [Variable.withDateTime(at), Variable.withString(id)],
      );
}

void main() {
  late FakeSyncRemote remote;
  late _Device a;
  late _Device b;

  setUp(() async {
    remote = FakeSyncRemote();
    a = _Device(remote);
    b = _Device(remote);
    await a.seedBible();
    await b.seedBible();
  });

  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  test('push envia as pendências com user_id e marca como sincronizadas', () async {
    await a.login(_user);
    await a.db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 20, 8));
    await a.db.prayerDao.createRequest(title: 'Família', category: PrayerCategory.family);
    expect(await a.db.syncDao.countPending(), 3); // ciclo + leitura + oração

    final report = await a.service.sync(_user);
    expect(report.pushed, 3);
    expect(await a.db.syncDao.countPending(), 0);
    final log = remote.tables['reading_logs']!.values.single;
    expect(log['user_id'], _user);
    expect(log['book_id'], 45);
    expect(log['source'], 'app');
    expect(remote.tables['prayer_requests']!.values.single['category'], 'family');

    final again = await a.service.sync(_user);
    expect(again.pushed, 0);
  });

  test('novo aparelho restaura tudo (full pull), inclusive o progresso do ciclo', () async {
    await a.login(_user);
    await a.db.syncDao.saveProfile(userId: _user, fullName: 'André Alves', age: 30, churchName: 'CCB');
    await a.db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 19));
    await a.db.readingDao.logChapter(bookId: 45, chapter: 9, readAt: DateTime(2026, 11, 20));
    await a.db.recitativesDao.createRecitative(bookId: 45, chapter: 8, verseStart: 1, serviceDate: DateTime(2026, 11, 22));
    await a.db.notesDao.createNote(bookId: 45, chapter: 8, content: 'Nenhuma condenação');
    await a.db.plansDao.start('nt-90-dias', at: DateTime(2026, 11, 1));
    await a.service.sync(_user);

    await b.login(_user);
    final report = await b.service.sync(_user);
    expect(report.pulled, greaterThanOrEqualTo(7));
    expect((await b.db.syncDao.getProfile(_user))!.churchName, 'CCB');
    final cycle = await b.db.readingDao.getActiveCycle();
    expect(await b.db.readingDao.countUniqueChaptersInCycle(cycle!.id), 2);
    expect(await b.db.recitativesDao.getAll(), hasLength(1));
    expect(await b.db.notesDao.watchAll().first, hasLength(1));
    expect((await b.db.plansDao.watchActive().first)!.planId, 'nt-90-dias');
    // O que veio da nuvem não volta a subir.
    expect(await b.db.syncDao.countPending(), 0);
  });

  test('exclusão feita offline chega ao outro aparelho', () async {
    await a.login(_user);
    final noteId = await a.db.notesDao.createNote(bookId: 45, chapter: 8, content: 'Rascunho');
    await a.service.sync(_user);
    await b.login(_user);
    await b.service.sync(_user);
    expect(await b.db.notesDao.watchAll().first, hasLength(1));

    await a.db.notesDao.deleteNote(noteId);
    expect(await a.db.notesDao.watchAll().first, isEmpty);
    await a.service.sync(_user);
    expect(remote.tables['verse_notes']![noteId]!['deleted_at'], isNotNull);

    await b.service.sync(_user);
    expect(await b.db.notesDao.watchAll().first, isEmpty);
  });

  test('Last-Write-Wins: a edição mais recente vence nos dois aparelhos', () async {
    await a.login(_user);
    final id = await a.db.prayerDao.createRequest(title: 'Original', category: PrayerCategory.church);
    await a.service.sync(_user);
    await b.login(_user);
    await b.service.sync(_user);

    // Os dois editam offline; B edita depois de A.
    await a.db.prayerDao.updateRequest(id: id, title: 'Versão do A', category: PrayerCategory.church);
    await a.setUpdatedAt('prayer_requests', id, _later(1));
    await b.db.prayerDao.updateRequest(id: id, title: 'Versão do B', category: PrayerCategory.church);
    await b.setUpdatedAt('prayer_requests', id, _later(2));

    // B sincroniza primeiro; depois A (com a versão mais antiga) não sobrescreve.
    await b.service.sync(_user);
    await a.service.sync(_user);
    await b.service.sync(_user);

    Future<String> title(_Device d) async => (await d.db.prayerDao.watchActive().first).single.title;
    expect(await title(a), 'Versão do B');
    expect(await title(b), 'Versão do B');
    expect(remote.tables['prayer_requests']![id]!['title'], 'Versão do B');
  });

  test('alteração local mais nova não é sobrescrita pela nuvem e sobe em seguida', () async {
    await a.login(_user);
    final id = await a.db.prayerDao.createRequest(title: 'Original', category: PrayerCategory.church);
    await a.service.sync(_user);
    await b.login(_user);
    await b.service.sync(_user);

    await b.db.prayerDao.updateRequest(id: id, title: 'Antiga do B', category: PrayerCategory.church);
    await b.setUpdatedAt('prayer_requests', id, _later(1));
    await a.db.prayerDao.updateRequest(id: id, title: 'Nova do A', category: PrayerCategory.church);
    await a.setUpdatedAt('prayer_requests', id, _later(2));
    await a.service.sync(_user);

    await b.service.sync(_user); // pull traz a do A (mais nova) por cima da pendência antiga do B
    expect((await b.db.prayerDao.watchActive().first).single.title, 'Nova do A');
    expect(await b.db.syncDao.countPending(), 0);
  });

  test('dados criados sem conta são vinculados no primeiro login e somam ao histórico', () async {
    // Conta já tem histórico vindo do aparelho A.
    await a.login(_user);
    await a.db.readingDao.logChapter(bookId: 45, chapter: 1, readAt: DateTime(2026, 10, 1));
    await a.service.sync(_user);

    // No aparelho B a pessoa leu sem conta (outro ciclo ativo).
    await b.db.readingDao.logChapter(bookId: 45, chapter: 2, readAt: DateTime(2026, 11, 20));
    await b.login(_user);
    await b.service.sync(_user);

    final cycles = await b.db.readingDao.watchCycles().first;
    expect(cycles.where((c) => c.endedAt == null), hasLength(1), reason: 'um único ciclo ativo');
    final active = await b.db.readingDao.getActiveCycle();
    expect(await b.db.readingDao.countUniqueChaptersInCycle(active!.id), 2);

    // A consolidação também chega ao aparelho A.
    await a.service.sync(_user);
    final activeA = await a.db.readingDao.getActiveCycle();
    expect(await a.db.readingDao.countUniqueChaptersInCycle(activeA!.id), 2);
  });

  test('entrar com outra conta apaga os dados locais da anterior', () async {
    await a.login(_user);
    await a.db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 20));
    await a.service.sync(_user);

    await a.login(_otherUser);
    expect(await a.db.readingDao.getAllReadDates(), isEmpty);
    await a.service.sync(_otherUser);
    expect(await a.db.readingDao.getAllReadDates(), isEmpty, reason: 'dados de outra conta não vêm junto');
    // A Bíblia permanece.
    expect(await a.db.bibleDao.getChapter(BibleTranslation.arc, 45, 8), hasLength(3));
  });

  test('sair da conta limpa o aparelho e o estado da sincronização', () async {
    await a.login(_user);
    await a.db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 20));
    await a.service.sync(_user);
    await a.service.detachUser();
    expect(await a.db.readingDao.getAllReadDates(), isEmpty);
    expect(await a.db.settingsDao.getValue(SyncKeys.ownerId), isNull);
    expect(await a.service.lastSyncAt(), isNull);

    // Ao entrar de novo, tudo volta.
    await a.login(_user);
    await a.service.sync(_user);
    expect(await a.db.readingDao.getAllReadDates(), hasLength(1));
  });

  test('download paginado traz todas as linhas (mais de uma página)', () async {
    await a.login(_user);
    final cycle = await a.db.readingDao.getOrCreateActiveCycle();
    await a.db.batch((batch) {
      for (var i = 0; i < 1200; i++) {
        batch.insert(a.db.readingLogs, ReadingLogsCompanion.insert(
          bookId: 45,
          chapter: 1 + i % 16,
          readAt: DateTime(2020).add(Duration(days: i)),
          source: ReadingSource.app,
          cycleId: cycle.id,
        ));
      }
    });
    await a.service.sync(_user);
    expect(remote.tables['reading_logs'], hasLength(1200));

    await b.login(_user);
    await b.service.sync(_user);
    expect(await b.db.readingDao.getAllReadDates(), hasLength(1200));

    // Sincronização seguinte só pergunta o que mudou (nada).
    final before = remote.fetchCalls;
    final report = await b.service.sync(_user);
    expect(report.pulled, 0);
    expect(remote.fetchCalls - before, 7, reason: 'uma consulta vazia por tabela');
  });

  test('sem internet: as alterações ficam pendentes e sobem depois', () async {
    await a.login(_user);
    await a.db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 20));
    remote.offline = true;
    await expectLater(a.service.sync(_user), throwsException);
    expect(await a.db.syncDao.countPending(), 2);

    remote.offline = false;
    await a.service.sync(_user);
    expect(await a.db.syncDao.countPending(), 0);
  });

  test('alteração feita durante o envio continua pendente', () async {
    await a.login(_user);
    final id = await a.db.prayerDao.createRequest(title: 'Antes', category: PrayerCategory.personal);
    final row = (await a.db.syncDao.pendingRows(a.db.prayerRequests)).single;
    // Simula edição entre o upsert e a marcação: updated_at mudou.
    await a.setUpdatedAt('prayer_requests', id, row.updatedAt.add(const Duration(seconds: 5)));
    await a.db.syncDao.markSynced(a.db.prayerRequests, [(id: id, updatedAt: row.updatedAt)]);
    expect(await a.db.syncDao.countPending(), 1);
  });
}
