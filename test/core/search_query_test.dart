import 'package:devocional/core/database/daos/bible_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada palavra vira um prefixo entre aspas, em minúsculas', () {
    expect(BibleDao.buildFtsQuery('O Senhor é o meu Pastor'), '"o"* "senhor"* "é"* "o"* "meu"* "pastor"*');
  });

  test('aspas, operadores e pontuação digitados não chegam ao FTS', () {
    expect(BibleDao.buildFtsQuery('"amor" OR (fé) -graça*'), '"amor"* "or"* "fé"* "graça"*');
    expect(BibleDao.buildFtsQuery('João 3:16'), '"joão"* "3"* "16"*');
  });

  test('sem palavras não há consulta', () {
    expect(BibleDao.buildFtsQuery('   '), isNull);
    expect(BibleDao.buildFtsQuery('?!*"'), isNull);
  });
}
