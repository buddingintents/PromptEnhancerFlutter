import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_enhancer/app/app.dart';

void main() {
  testWidgets('renders the splash route on startup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PromptEnhancerApp()));
    await tester.pumpAndSettle();

    expect(find.text('Prompt Enhancer'), findsOneWidget);
    expect(find.text('Enter App'), findsOneWidget);
  });

  testWidgets('navigates from splash to home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PromptEnhancerApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter App'));
    await tester.pumpAndSettle();

    expect(find.text('Prompt Workspace'), findsOneWidget);
    expect(find.text('Refine Prompt'), findsOneWidget);
  });
}
