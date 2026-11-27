import 'dart:convert';

import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/core/database/seed/bible_seed_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contagem canônica de capítulos (Gn..Ap) — 1.189 no total.
const _counts = [
  50, 40, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29, 36, 10, 13, 10, 42, 150, 31, 12, 8, 66, 52, 5, 48, 12, 14, 3, 9, //
  1, 4, 7, 3, 3, 3, 2, 14, 4, 28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13, 5, 5, 3, 5, 1, 1, 1, 22,
];

/// Bíblia sintética no formato do repositório de origem (id textual, sem abreviação).
String _bibleJson(String Function(int book, int chapter) text) => jsonEncode([
      for (var b = 0; b < 66; b++)
        {
          'id': 'l${b + 1}',
          'name': 'Livro ${b + 1}',
          'chapters': [
            for (var c = 0; c < _counts[b]; c++) [text(b + 1, c + 1)],
          ],
        },
    ]);

void main() {
  late AppDatabase db;
  late BibleSeedService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = BibleSeedService(db);
  });

  tearDown(() => db.close());

  test('importa a ARC: livros com abreviação canônica, versículos e busca indexada', () async {
    final progress = <double>[];
    await service.importJson(
      BibleTranslation.arc,
      _bibleJson((b, c) => b == 43 && c == 3 ? 'Porque Deus amou o mundo de tal maneira' : 'Texto $b:$c.'),
      onProgress: progress.add,
    );

    expect(await db.bibleDao.isSeeded(BibleTranslation.arc), isTrue);
    expect(await db.bibleDao.isSeeded(BibleTranslation.nvi), isFalse);
    expect((await db.bibleDao.getBook(1)).abbrev, 'Gn');
    expect((await db.bibleDao.getBook(19)).chaptersCount, 150);
    expect(progress.last, 1);

    final hits = await db.bibleDao.search(BibleTranslation.arc, 'deus amou');
    expect(hits.total, 1);
    expect(hits.hits.single.bookId, 43);
  });

  test('não importa duas vezes sem "substituir"', () async {
    await service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'A $b:$c.'));
    expect(
      () => service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'B $b:$c.')),
      throwsA(isA<BibleSeedException>()),
    );
  });

  test('substituir troca o texto da versão e reindexa a busca', () async {
    await service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'antigo $b:$c.'));
    await service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'novo $b:$c.'), replace: true);

    expect((await db.bibleDao.getChapter(BibleTranslation.arc, 1, 1)).single.verseText, 'novo 1:1.');
    expect((await db.bibleDao.search(BibleTranslation.arc, 'antigo')).total, 0);
    expect((await db.bibleDao.search(BibleTranslation.arc, 'novo')).total, 1189);
  });

  test('ARC e NVI importadas separadamente convivem', () async {
    await service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'arc $b:$c.'));
    await service.importJson(BibleTranslation.nvi, _bibleJson((b, c) => 'nvi $b:$c.'));
    expect((await db.bibleDao.getChapter(BibleTranslation.nvi, 1, 1)).single.verseText, 'nvi 1:1.');
    expect((await db.bibleDao.getChapter(BibleTranslation.arc, 1, 1)).single.verseText, 'arc 1:1.');
  });

  test('arquivos inválidos são recusados com mensagem clara, sem gravar nada', () async {
    Future<void> attempt(String raw) => service.importJson(BibleTranslation.arc, raw);
    await expectLater(attempt('isto não é json'), throwsA(isA<BibleSeedException>()));
    await expectLater(attempt('{"x": 1}'), throwsA(isA<BibleSeedException>()));
    await expectLater(attempt('[{"title": "sem name nem chapters"}]'), throwsA(isA<BibleSeedException>()));
    await expectLater(attempt(jsonEncode([{'name': 'Só um livro', 'chapters': [['v']]}])), throwsA(isA<BibleSeedException>()));
    expect(await db.bibleDao.isSeeded(BibleTranslation.arc), isFalse);
  });

  group('várias traduções', () {
    test('catálogo e personalizada convivem; lista na ordem do catálogo', () async {
      await service.importJson(BibleTranslation.ntlh, _bibleJson((b, c) => 'ntlh $b:$c.'));
      await service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'arc $b:$c.'));
      final nbv = BibleTranslation.custom(abbrev: 'nbv', fullName: 'Nova Bíblia Viva');
      expect(nbv.code, 'u-nbv');
      expect(nbv.abbrev, 'NBV');
      await service.importJson(nbv, _bibleJson((b, c) => 'nbv $b:$c.'));

      final installed = await db.bibleDao.getInstalled();
      expect(installed.map((t) => t.abbrev), ['ARC', 'NTLH', 'NBV']);
      final custom = installed.last;
      expect(custom.fullName, 'Nova Bíblia Viva');
      expect(custom.isCustom, isTrue);
      expect((await db.bibleDao.getChapter(custom, 1, 1)).single.verseText, 'nbv 1:1.');
      expect((await db.bibleDao.search(custom, 'nbv')).total, 1189);

      // Sigla de uma tradução do catálogo vira a do catálogo.
      expect(BibleTranslation.custom(abbrev: 'ntlh', fullName: 'qualquer'), BibleTranslation.ntlh);
    });

    test('remover tira o texto, a busca e as preferências que apontavam para ela', () async {
      await service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'arc $b:$c.'));
      await service.importJson(BibleTranslation.nvi, _bibleJson((b, c) => 'nvi $b:$c.'));
      await db.settingsDao.setValue('bible_translation', 'nvi');
      await db.settingsDao.setValue('primary_translation', 'nvi');

      await service.removeTranslation(BibleTranslation.nvi);
      expect(await db.bibleDao.getInstalled(), [BibleTranslation.arc]);
      expect(await db.bibleDao.getChapter(BibleTranslation.nvi, 1, 1), isEmpty);
      expect((await db.bibleDao.search(BibleTranslation.nvi, 'nvi')).total, 0);
      expect((await db.bibleDao.search(BibleTranslation.arc, 'arc')).total, 1189);
      expect(await db.settingsDao.getValue('bible_translation'), isNull);
      expect(await db.settingsDao.getValue('primary_translation'), isNull);

      // A última tradução não pode sair.
      await expectLater(service.removeTranslation(BibleTranslation.arc), throwsA(isA<BibleSeedException>()));
    });

    test('tradução principal: escolhida, senão ARC, senão a primeira; usada nos recitativos', () async {
      await service.importJson(BibleTranslation.nvi, _bibleJson((b, c) => 'nvi $b:$c.'));
      expect(await db.bibleDao.resolvePrimary(), BibleTranslation.nvi, reason: 'sem ARC, vale a primeira');

      await service.importJson(BibleTranslation.arc, _bibleJson((b, c) => 'arc $b:$c.'));
      expect(await db.bibleDao.resolvePrimary(), BibleTranslation.arc, reason: 'ARC é a preferida');
      final id1 = await db.recitativesDao.createRecitative(bookId: 1, chapter: 1, verseStart: 1, serviceDate: DateTime(2026, 12, 1));
      expect((await db.recitativesDao.getById(id1))!.recitative.verseTextSnapshot, 'arc 1:1.');

      await db.settingsDao.setValue('primary_translation', 'nvi');
      expect(await db.bibleDao.resolvePrimary(), BibleTranslation.nvi);
      final id2 = await db.recitativesDao.createRecitative(bookId: 1, chapter: 2, verseStart: 1, serviceDate: DateTime(2026, 12, 1));
      expect((await db.recitativesDao.getById(id2))!.recitative.verseTextSnapshot, 'nvi 1:2.');
      // O recitativo antigo mantém o texto com que foi criado.
      expect((await db.recitativesDao.getById(id1))!.recitative.verseTextSnapshot, 'arc 1:1.');
    });

    test('livro com capítulos a mais é recusado dizendo qual livro', () async {
      final data = jsonDecode(_bibleJson((b, c) => 't $b:$c.')) as List<dynamic>;
      // Defeito real visto num arquivo da NTLH: 2 Samuel com 14 capítulos repetidos no fim.
      ((data[9] as Map<String, dynamic>)['chapters'] as List<dynamic>).addAll(List.filled(14, ['repetido']));
      await expectLater(
        service.importJson(BibleTranslation.ntlh, jsonEncode(data)),
        throwsA(isA<BibleSeedException>().having((e) => e.message, 'message', contains('Livro 10 tem 38 capítulos'))),
      );
      expect(await db.bibleDao.getInstalled(), isEmpty);
    });

    test('importar de novo a mesma tradução exige substituir', () async {
      await service.importJson(BibleTranslation.kja, _bibleJson((b, c) => 'kja $b:$c.'));
      await expectLater(
        service.importJson(BibleTranslation.kja, _bibleJson((b, c) => 'outra $b:$c.')),
        throwsA(isA<BibleSeedException>()),
      );
    });
  });
}
