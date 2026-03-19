import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/app/app.dart';
import 'package:prompt_enhancer/core/storage/hive_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeHive();

  runApp(const ProviderScope(child: PromptEnhancerApp()));
}
