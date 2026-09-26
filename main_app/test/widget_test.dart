import 'package:flutter_test/flutter_test.dart';
import 'package:hexafalls/main.dart';

void main() {
  testWidgets('KnowledgeVerseApp mounts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const KnowledgeVerseApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(KnowledgeVerseApp), findsOneWidget);
  });
}
