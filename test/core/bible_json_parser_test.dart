import 'dart:convert';

import 'package:devocional/core/database/seed/bible_seed_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formato objeto com "books"', () {
    final raw = jsonEncode({
      'books': [
        {'id': 1, 'name': 'Gênesis', 'abbrev': 'Gn', 'testament': 'AT', 'chapters': [['v1', 'v2']]},
      ],
    });
    final books = parseBibleJson(raw);
    expect(books.single.id, 1);
    expect(books.single.testament, 'AT');
    expect(books.single.chapters.single, ['v1', 'v2']);
  });

  test('formato lista: id pela posição e testamento derivado', () {
    final raw = jsonEncode([
      for (var i = 0; i < 66; i++)
        {
          'abbrev': 'L${i + 1}',
          'name': 'Livro ${i + 1}',
          'chapters': [
            [' texto '],
          ],
        },
    ]);
    final books = parseBibleJson('\uFEFF$raw');
    expect(books, hasLength(66));
    expect(books.first.id, 1);
    expect(books[38].testament, 'AT');
    expect(books[39].testament, 'NT');
    expect(books.last.id, 66);
    expect(books.first.chapters.single.single, 'texto');
  });

  test('formato do repositório de origem: id textual ("gn") e sem abreviação', () {
    final raw = jsonEncode([
      {'id': 'gn', 'name': 'Gênesis', 'chapters': [['No princípio Deus criou os céus e a terra.']]},
      {'id': 'ex', 'name': 'Êxodo', 'chapters': [['v']]},
    ]);
    final books = parseBibleJson('\uFEFF$raw');
    expect(books.map((b) => b.id), [1, 2]);
    expect(books.first.abbrev, 'Gn'); // abreviação canônica quando o JSON não traz
    expect(books.first.testament, 'AT');
  });

  test('validação rejeita contagem canônica incorreta', () {
    final books = parseBibleJson(jsonEncode([
      for (var i = 0; i < 66; i++)
        {
          'abbrev': 'L',
          'name': 'L',
          'chapters': [
            ['v'],
          ],
        },
    ]));
    expect(() => validateBooks(books), throwsA(isA<BibleSeedException>()));
  });

  test('JSON sem lista nem "books" é rejeitado', () {
    expect(() => parseBibleJson('{"x": 1}'), throwsA(isA<BibleSeedException>()));
  });
}
