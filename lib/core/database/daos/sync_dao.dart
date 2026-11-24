import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'sync_dao.g.dart';

/// Estado local de uma linha, usado no merge Last-Write-Wins.
typedef LocalRowState = ({DateTime updatedAt, bool isSynced});

/// Operações de banco usadas pela sincronização e pelo perfil da conta.
@DriftAccessor(
  tables: [ReadingCycles, ReadingLogs, Recitatives, PrayerRequests, VerseNotes, PlanEnrollments, UserProfiles],
)
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.attachedDatabase);

  /// Tabelas espelhadas na nuvem, na ordem de envio/recebimento.
  List<TableInfo<Table, Object?>> get syncedTables =>
      [userProfiles, readingCycles, readingLogs, recitatives, prayerRequests, verseNotes, planEnrollments];

  // ---------------------------------------------------------------- Perfil

  Future<UserProfile?> getProfile(String userId) =>
      (select(userProfiles)..where((p) => p.id.equals(userId) & p.deletedAt.isNull())).getSingleOrNull();

  Stream<UserProfile?> watchProfile(String userId) =>
      (select(userProfiles)..where((p) => p.id.equals(userId) & p.deletedAt.isNull())).watchSingleOrNull();

  /// Cria ou atualiza o perfil (fica pendente de envio).
  Future<UserProfile> saveProfile({
    required String userId,
    required String fullName,
    required int age,
    required String churchName,
  }) =>
      into(userProfiles).insertReturning(
        UserProfilesCompanion.insert(
          id: Value(userId),
          fullName: fullName.trim(),
          age: age,
          churchName: churchName.trim(),
          updatedAt: Value(DateTime.now()),
          isSynced: const Value(false),
        ),
        onConflict: DoUpdate(
          (_) => UserProfilesCompanion(
            fullName: Value(fullName.trim()),
            age: Value(age),
            churchName: Value(churchName.trim()),
            updatedAt: Value(DateTime.now()),
            isSynced: const Value(false),
            deletedAt: const Value(null),
          ),
        ),
      );

  // ------------------------------------------------------------- Pendências

  String _countPendingSql() => 'SELECT ${[
        for (final t in syncedTables) '(SELECT COUNT(*) FROM ${t.actualTableName} WHERE is_synced = 0)',
      ].join(' + ')} AS total';

  /// Quantas alterações locais ainda não foram enviadas à nuvem.
  Stream<int> watchPendingCount() => customSelect(_countPendingSql(), readsFrom: syncedTables.toSet())
      .watchSingle()
      .map((r) => r.read<int>('total'));

  Future<int> countPending() =>
      customSelect(_countPendingSql(), readsFrom: syncedTables.toSet()).getSingle().then((r) => r.read<int>('total'));

  /// Linhas de [table] com alterações ainda não enviadas.
  Future<List<D>> pendingRows<D>(TableInfo<Table, D> table) => customSelect(
        'SELECT * FROM ${table.actualTableName} WHERE is_synced = 0',
        readsFrom: {table},
      ).asyncMap((row) => table.map(row.data)).get();

  /// Marca como sincronizadas as linhas enviadas — só se não mudaram durante o
  /// envio (mesmo `updated_at`); caso contrário seguem pendentes.
  Future<void> markSynced(TableInfo<Table, Object?> table, List<({String id, DateTime updatedAt})> rows) async {
    if (rows.isEmpty) return;
    await transaction(() async {
      for (final r in rows) {
        await customUpdate(
          'UPDATE ${table.actualTableName} SET is_synced = 1 WHERE id = ? AND updated_at = ?',
          variables: [Variable.withString(r.id), Variable.withDateTime(r.updatedAt)],
          updates: {table},
          updateKind: UpdateKind.update,
        );
      }
    });
  }

  /// `updated_at`/`is_synced` locais das linhas [ids] de [table].
  Future<Map<String, LocalRowState>> localStates(TableInfo<Table, Object?> table, List<String> ids) async {
    final result = <String, LocalRowState>{};
    // Lotes de até 500 ids (limite de variáveis do SQLite é 999 nas versões antigas).
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      final rows = await customSelect(
        'SELECT id, updated_at, is_synced FROM ${table.actualTableName} '
        'WHERE id IN (${List.filled(chunk.length, '?').join(', ')})',
        variables: [for (final id in chunk) Variable.withString(id)],
        readsFrom: {table},
      ).get();
      for (final r in rows) {
        result[r.read<String>('id')] = (updatedAt: r.read<DateTime>('updated_at'), isSynced: r.read<bool>('is_synced'));
      }
    }
    return result;
  }

  /// Grava (insere ou substitui) linhas vindas da nuvem.
  Future<void> upsertAll<D>(TableInfo<Table, D> table, List<Insertable<D>> rows) async {
    if (rows.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(table, rows));
  }

  /// Marca tudo como pendente (ao vincular a uma conta os dados criados sem login).
  Future<void> markAllUnsynced() => transaction(() async {
        for (final t in syncedTables) {
          await customStatement('UPDATE ${t.actualTableName} SET is_synced = 0');
        }
        notifyUpdates({for (final t in syncedTables) TableUpdate.onTable(t, kind: UpdateKind.update)});
      });

  /// Apaga do aparelho todos os dados do usuário (ao sair da conta). A Bíblia
  /// e as preferências do app permanecem.
  Future<void> wipeUserData() => transaction(() async {
        for (final t in syncedTables.reversed) {
          await customStatement('DELETE FROM ${t.actualTableName}');
        }
        notifyUpdates({for (final t in syncedTables) TableUpdate.onTable(t, kind: UpdateKind.delete)});
      });

  /// Após receber dados da nuvem, pode haver mais de um ciclo ou plano ativo
  /// (ex.: leitura feita sem login num aparelho novo + histórico da conta).
  /// - Ciclos: fica o mais antigo (o que acumula o progresso); as leituras dos
  ///   outros passam para ele e os demais são excluídos.
  /// - Planos: fica o iniciado por último; os outros são encerrados.
  Future<void> consolidateActiveRows() => transaction(() async {
        final now = DateTime.now();
        final cycles = await (select(readingCycles)
              ..where((c) => c.endedAt.isNull() & c.deletedAt.isNull())
              ..orderBy([(c) => OrderingTerm.asc(c.startedAt)]))
            .get();
        if (cycles.length > 1) {
          final keeper = cycles.first;
          for (final other in cycles.skip(1)) {
            await (update(readingLogs)..where((l) => l.cycleId.equals(other.id))).write(ReadingLogsCompanion(
              cycleId: Value(keeper.id),
              updatedAt: Value(now),
              isSynced: const Value(false),
            ));
            await (update(readingCycles)..where((c) => c.id.equals(other.id))).write(ReadingCyclesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
              isSynced: const Value(false),
            ));
          }
        }

        final plans = await (select(planEnrollments)
              ..where((p) => p.endedAt.isNull() & p.deletedAt.isNull())
              ..orderBy([(p) => OrderingTerm.desc(p.startedAt)]))
            .get();
        if (plans.length > 1) {
          final keeper = plans.first;
          for (final other in plans.skip(1)) {
            await (update(planEnrollments)..where((p) => p.id.equals(other.id))).write(PlanEnrollmentsCompanion(
              endedAt: Value(keeper.startedAt),
              completed: const Value(false),
              updatedAt: Value(now),
              isSynced: const Value(false),
            ));
          }
        }
      });
}
