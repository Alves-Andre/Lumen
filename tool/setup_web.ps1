# Prepara os arquivos do banco offline para a versão Web/PWA do Lumen:
#   web/sqlite3.wasm     SQLite compilado para WebAssembly (release oficial do pacote sqlite3)
#   web/drift_worker.js  worker do drift, compilado de tool/web/drift_worker.dart
#
# Rode na raiz do projeto sempre que atualizar os pacotes drift/sqlite3:
#   powershell -ExecutionPolicy Bypass -File tool/setup_web.ps1
$ErrorActionPreference = 'Stop'

# A versão do sqlite3.wasm precisa ser a mesma do pacote Dart sqlite3 (pubspec.lock).
$lock = Get-Content pubspec.lock -Raw
$match = [regex]::Match($lock, '(?ms)^  sqlite3:\s*\n.*?version: "([^"]+)"')
if (-not $match.Success) { throw 'Pacote sqlite3 não encontrado no pubspec.lock. Rode "flutter pub get".' }
$version = $match.Groups[1].Value

$url = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$version/sqlite3.wasm"
Write-Host "Baixando sqlite3.wasm $version..."
Invoke-WebRequest -Uri $url -OutFile web/sqlite3.wasm -UseBasicParsing

Write-Host 'Compilando drift_worker.js...'
dart compile js -O4 tool/web/drift_worker.dart -o web/drift_worker.js
Remove-Item web/drift_worker.js.deps, web/drift_worker.js.map -ErrorAction SilentlyContinue

Write-Host 'Pronto: web/sqlite3.wasm e web/drift_worker.js'
