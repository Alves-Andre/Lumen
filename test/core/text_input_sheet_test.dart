import 'package:devocional/core/theme/app_theme.dart';
import 'package:devocional/core/widgets/text_input_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('confirma o texto e fecha sem usar o controlador descartado', (tester) async {
    String? result = 'não chamado';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result = await showTextInputSheet(
                context,
                title: 'Como foi o culto?',
                initialText: 'Antes',
                confirmLabel: 'Confirmar',
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Antes'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Deus falou sobre fé');
    await tester.tap(find.text('CONFIRMAR'));
    await tester.pumpAndSettle(); // animação de fechamento completa

    expect(tester.takeException(), isNull);
    expect(result, 'Deus falou sobre fé');
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('fechar arrastando/tocando fora retorna null', (tester) async {
    String? result = 'não chamado';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result = await showTextInputSheet(context, title: 'T', confirmLabel: 'OK'),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result, isNull);
  });
}
