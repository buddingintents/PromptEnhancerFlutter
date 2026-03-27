import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prompt_enhancer/features/history/presentation/pages/history_page.dart';
import 'package:prompt_enhancer/features/metrics/presentation/pages/metrics_page.dart';
import 'package:prompt_enhancer/features/prompt/presentation/pages/home_page.dart';
import 'package:prompt_enhancer/features/trending/presentation/pages/trending_page.dart';
import 'package:prompt_enhancer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('android back returns to the previous screen', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter App'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('trending and metrics screens render without framework errors', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter App'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trending'));
    await tester.pumpAndSettle();

    expect(find.byType(TrendingPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metrics'));
    await tester.pumpAndSettle();

    expect(find.byType(MetricsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
