import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../constants/bible_constants.dart';
import '../../files/pick_file.dart';
import '../app_database.dart';

class BibleSeedException implements Exception {
  const BibleSeedException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Livro como lido do JSON de uma versão.
class SeedBook {
  const SeedBook({
    required this.id,
    required this.name,
    required this.abbrev,
    required this.testament,
    required this.chapters,
  });

  final int id;
  final String name;
  final String abbrev;
  final String testament;

  /// `chapters[c][v]` = texto do versículo `v + 1` do capítulo `c + 1`.
  final List<List<String>> chapters;
}

/// Importa os textos bíblicos escolhidos pelo usuário.
///
/// O app não embarca nenhuma Bíblia (os textos têm direitos autorais): na
/// primeira abertura o usuário seleciona o arquivo `.json` de cada versão.
/// Cada importação roda numa única transação — ou a versão entra inteira, ou
/// nada muda — e termina reconstruindo o índice de busca.
class BibleSeedService {
  BibleSeedService(this._db);

  final AppDatabase _db;

  /// Abre o seletor de arquivos e importa [translation]. Retorna `false` se o
  /// usuário cancelar. [replace] apaga antes o texto já instalado dessa versão.
  Future<bool> pickAndImport(
    BibleTranslation translation, {
    bool replace = false,
    void Function(double progress)? onProgress,
  }) async {
    final file = await pickFile(dialogTitle: 'Selecione o arquivo da ${translation.abbrev} (.json)');
    if (file == null) return false;
    final bytes = file.bytes;
    final String raw;
    try {
      raw = utf8.decode(bytes);
    } on FormatException {
      throw const BibleSeedException('O arquivo não está em UTF-8. Baixe novamente o .json indicado no README.');
    }
    await importJson(translation, raw, replace: replace, onProgress: onProgress);
    return true;
  }

  /// Valida e grava [raw] como [translation].
  Future<void> importJson(
    BibleTranslation translation,
    String raw, {
    bool replace = false,
    void Function(double progress)? onProgress,
  }) async {
    // compute() envia só a função top-level e a string ao isolate; uma closure
    // aqui capturaria o contexto do método (incluindo a conexão do banco).
    final books = await compute(parseBibleJson, raw);
    validateBooks(books);

    if (!replace && await _db.bibleDao.isSeeded(translation)) {
      throw BibleSeedException('A ${translation.abbrev} já está instalada.');
    }

    await _db.transaction(() async {
      if (replace) {
        await (_db.delete(_db.verses)..where((v) => v.translation.equalsValue(translation))).go();
      }
      for (var i = 0; i < books.length; i++) {
        final book = books[i];
        await _db.batch((batch) {
          // Livros: o primeiro import define nomes e abreviações (insertOrIgnore).
          batch.insert(
            _db.books,
            BooksCompanion(
              id: Value(book.id),
              name: Value(book.name),
              abbrev: Value(book.abbrev),
              testament: Value(book.testament),
              chaptersCount: Value(book.chapters.length),
            ),
            mode: InsertMode.insertOrIgnore,
          );
          batch.insertAll(
            _db.verses,
            [
              for (var c = 0; c < book.chapters.length; c++)
                for (var v = 0; v < book.chapters[c].length; v++)
                  VersesCompanion(
                    translation: Value(translation),
                    bookId: Value(book.id),
                    chapter: Value(c + 1),
                    verse: Value(v + 1),
                    verseText: Value(book.chapters[c][v]),
                  ),
            ],
            mode: InsertMode.insertOrIgnore,
          );
        });
        onProgress?.call((i + 1) / books.length);
      }
    });
    await _db.rebuildSearchIndex();
  }
}

/// Converte o JSON bruto. Função top-level para rodar em outro isolate.
///
/// Aceita dois formatos:
/// * `{"books": [{"id", "name", "abbrev", "testament", "chapters"}, ...]}`
/// * `[{"name", "chapters", "abbrev"?, "id"?}, ...]` em ordem canônica — o `id`
///   numérico vem da posição, o testamento é derivado (os 39 primeiros são AT)
///   e, sem `abbrev`, vale a abreviação canônica.
List<SeedBook> parseBibleJson(String raw) {
  final Object? root;
  try {
    root = jsonDecode(raw.startsWith('﻿') ? raw.substring(1) : raw);
  } on FormatException {
    throw const BibleSeedException('O arquivo selecionado não é um JSON válido.');
  }
  final List<dynamic> booksJson;
  if (root is List<dynamic>) {
    booksJson = root;
  } else if (root is Map<String, dynamic> && root['books'] is List<dynamic>) {
    booksJson = root['books'] as List<dynamic>;
  } else {
    throw const BibleSeedException('Formato não reconhecido: esperada uma lista de livros da Bíblia.');
  }
  try {
    final books = booksJson.cast<Map<String, dynamic>>();
    return [
      for (var i = 0; i < books.length; i++)
        SeedBook(
          // `id` pode faltar ou ser um código ("gn"): vale a posição canônica.
          id: books[i]['id'] is int ? books[i]['id'] as int : i + 1,
          name: (books[i]['name'] as String).trim(),
          abbrev: (books[i]['abbrev'] as String?)?.trim() ??
              (i < BibleConstants.bookAbbreviations.length ? BibleConstants.bookAbbreviations[i] : ''),
          testament: (books[i]['testament'] as String?)?.trim().toUpperCase() ??
              (i < BibleConstants.oldTestamentBooks ? 'AT' : 'NT'),
          chapters: [
            for (final chapter in (books[i]['chapters'] as List<dynamic>))
              [for (final verse in (chapter as List<dynamic>)) (verse as String).trim()],
          ],
        ),
    ];
  } on TypeError {
    throw const BibleSeedException('Formato não reconhecido: cada livro precisa de "name" e "chapters".');
  }
}

/// Garante a integridade canônica antes de gravar qualquer coisa.
void validateBooks(List<SeedBook> books) {
  if (books.length != BibleConstants.totalBooks) {
    throw BibleSeedException('Esperados ${BibleConstants.totalBooks} livros, encontrados ${books.length}.');
  }
  final ids = books.map((b) => b.id).toSet();
  for (var id = BibleConstants.firstBookId; id <= BibleConstants.lastBookId; id++) {
    if (!ids.contains(id)) throw BibleSeedException('Livro com id $id ausente.');
  }
  var totalChapters = 0;
  for (final b in books) {
    if (b.testament != 'AT' && b.testament != 'NT') {
      throw BibleSeedException('${b.name}: testament deve ser "AT" ou "NT".');
    }
    if (b.chapters.isEmpty) throw BibleSeedException('${b.name}: sem capítulos.');
    for (var c = 0; c < b.chapters.length; c++) {
      if (b.chapters[c].isEmpty) throw BibleSeedException('${b.name} ${c + 1}: sem versículos.');
      if (b.chapters[c].any((v) => v.isEmpty)) {
        throw BibleSeedException('${b.name} ${c + 1}: versículo vazio.');
      }
    }
    totalChapters += b.chapters.length;
  }
  if (totalChapters != BibleConstants.totalChapters) {
    throw BibleSeedException('Esperados ${BibleConstants.totalChapters} capítulos, encontrados $totalChapters.');
  }
}
