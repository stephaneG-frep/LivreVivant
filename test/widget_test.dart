import 'package:flutter_test/flutter_test.dart';
import 'package:livre_vivant/main.dart';

void main() {
  testWidgets('LivreVivant démarre sans crash', (WidgetTester tester) async {
    await tester.pumpWidget(const LivreVivantApp());
    await tester.pump();

    expect(find.byType(LivreVivantApp), findsOneWidget);
  });
}
