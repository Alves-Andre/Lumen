import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

/// Web/PWA: SQLite compilado para WebAssembly.
///
/// `web/sqlite3.wasm` e `web/drift_worker.js` são gerados por
/// `tool/setup_web.ps1`. O drift escolhe o melhor armazenamento disponível
/// (OPFS num worker; IndexedDB no Safari mais antigo), e os dados continuam no
/// aparelho, disponíveis offline.
QueryExecutor openAppDatabase(String name) => LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: name,
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      if (kDebugMode && result.missingFeatures.isNotEmpty) {
        debugPrint(
          'Banco web em modo ${result.chosenImplementation}; '
          'recursos ausentes no navegador: ${result.missingFeatures}',
        );
      }
      return result.resolvedExecutor;
    });
