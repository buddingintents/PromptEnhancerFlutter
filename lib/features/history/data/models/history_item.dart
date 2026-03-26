import 'package:hive/hive.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';

class HistoryItem {
  const HistoryItem({
    required this.prompt,
    required this.refinedPrompt,
    required this.topic,
    required this.tokens,
    required this.timestamp,
    required this.provider,
    required this.latencyMs,
  });

  final String prompt;
  final String refinedPrompt;
  final String topic;
  final int tokens;
  final DateTime timestamp;
  final String provider;
  final int latencyMs;

  String get storageKey => timestamp.microsecondsSinceEpoch.toString();

  HistoryEntry toDomain() {
    return HistoryEntry(
      prompt: prompt,
      refinedPrompt: refinedPrompt,
      topic: topic,
      tokens: tokens,
      timestamp: timestamp,
      provider: provider,
      latencyMs: latencyMs,
    );
  }

  factory HistoryItem.fromDomain(HistoryEntry entry) {
    return HistoryItem(
      prompt: entry.prompt,
      refinedPrompt: entry.refinedPrompt,
      topic: entry.topic,
      tokens: entry.tokens,
      timestamp: entry.timestamp,
      provider: entry.provider,
      latencyMs: entry.latencyMs,
    );
  }
}

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 1;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < numOfFields; index++)
        reader.readByte(): reader.read(),
    };

    return HistoryItem(
      prompt: fields[0] as String? ?? '',
      refinedPrompt: fields[1] as String? ?? '',
      topic: fields[2] as String? ?? '',
      tokens: fields[3] as int? ?? 0,
      timestamp:
          fields[4] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      provider: fields[5] as String? ?? 'Unknown',
      latencyMs: fields[6] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.prompt)
      ..writeByte(1)
      ..write(obj.refinedPrompt)
      ..writeByte(2)
      ..write(obj.topic)
      ..writeByte(3)
      ..write(obj.tokens)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.provider)
      ..writeByte(6)
      ..write(obj.latencyMs);
  }
}

abstract final class HistoryStorageKeys {
  static const String boxName = 'history_items';
}
