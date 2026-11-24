import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Android/iOS: SQLite nativo. O `drift_flutter` resolve o diretório do app e
/// abre o banco num isolate em segundo plano, sem travar a interface.
/// (O `sqlite3_flutter_libs` foi descontinuado; a biblioteca nativa do SQLite
/// agora vem do próprio pacote `sqlite3` via build hooks.)
QueryExecutor openAppDatabase(String name) => driftDatabase(name: name);
