// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter_test/flutter_test.dart';

import 'package:herramientas_app/main.dart';

void main() {
  testWidgets(
    'la pantalla principal muestra el encabezado y las herramientas',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.text('CAJA DE HERRAMIENTAS'), findsOneWidget);
      expect(find.text('Herramientas'), findsOneWidget);
      expect(find.text('Género'), findsOneWidget);
    },
  );
}
