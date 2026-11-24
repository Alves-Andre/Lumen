// Abertura do banco local em cada plataforma, por import condicional:
// * Android/iOS: SQLite nativo (arquivo no diretório do app);
// * Web/PWA (inclusive Safari no iPhone): SQLite em WebAssembly, persistido no
//   navegador (OPFS ou IndexedDB, o que o navegador suportar).
export 'database_native.dart' if (dart.library.js_interop) 'database_web.dart';
