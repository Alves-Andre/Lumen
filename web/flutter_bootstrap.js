{{flutter_js}}
{{flutter_build_config}}

// Inicialização do Lumen na web.
// * O motor gráfico (CanvasKit) vem do próprio site, e não da CDN do Google:
//   funciona offline e não depende de outro domínio no iPhone.
// * Sem o service worker do Flutter (descontinuado: ele se desinstala e
//   recarrega a página, o que travava o app aberto pela Tela de Início do
//   iPhone). O cache offline fica com o sw.js, registrado no index.html.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: 'canvaskit/',
  },
});
