import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prompt_enhancer/core/firebase/firebase_bootstrap.dart';
import 'package:prompt_enhancer/core/storage/secure_storage_service.dart';
import 'package:prompt_enhancer/features/history/data/services/device_identity_service.dart';
import 'package:prompt_enhancer/features/history/data/services/firebase_history_service.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('anonymous auth can save history to Firebase Realtime Database', (
    tester,
  ) async {
    await initializeFirebaseServices();

    expect(Firebase.apps, isNotEmpty);
    expect(FirebaseAuth.instance.currentUser, isNotNull);
    expect(FirebaseAuth.instance.currentUser!.isAnonymous, isTrue);

    final timestamp = DateTime.now().toUtc();
    final entry = HistoryEntry(
      prompt: 'Integration test prompt ${timestamp.microsecondsSinceEpoch}',
      refinedPrompt:
          'Integration test refined prompt ${timestamp.microsecondsSinceEpoch}',
      topic: 'integration-test',
      tokens: 42,
      timestamp: timestamp,
      provider: 'firebase-test',
      latencyMs: 123,
      reasoningDepth: 'standard',
      topicConfidence: 0.88,
      countryCode: 'IN',
    );

    final service = FirebaseHistoryService(
      database: FirebaseDatabase.instance,
      deviceIdentityService: DeviceIdentityService(
        secureStorage: SecureStorageService(),
      ),
    );

    await service.saveHistoryItem(entry);

    final snapshot = await FirebaseDatabase.instance
        .ref('${FirebaseHistoryService.historyNode}/${entry.storageKey}')
        .get();

    expect(snapshot.exists, isTrue);

    final value = Map<Object?, Object?>.from(snapshot.value as Map);
    expect(value['category'], entry.topic);
    expect(value['provider'], entry.provider);
    expect(value['tokens'], entry.tokens);
    expect(value['originalPrompt'], entry.prompt);
    expect(value['refinedPrompt'], entry.refinedPrompt);
    expect(value['reasoningDepth'], entry.reasoningDepth);

    await FirebaseDatabase.instance
        .ref('${FirebaseHistoryService.historyNode}/${entry.storageKey}')
        .remove();
  });
}
