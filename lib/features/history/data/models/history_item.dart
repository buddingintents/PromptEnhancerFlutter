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
    required this.reasoningDepth,
    required this.topicConfidence,
    this.countryCode,
    this.deviceId,
    this.deviceModel,
  });

  final String prompt;
  final String refinedPrompt;
  final String topic;
  final int tokens;
  final DateTime timestamp;
  final String provider;
  final int latencyMs;
  final String reasoningDepth;
  final double topicConfidence;
  final String? countryCode;
  final String? deviceId;
  final String? deviceModel;

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
      reasoningDepth: reasoningDepth,
      topicConfidence: topicConfidence,
      countryCode: countryCode,
      deviceId: deviceId,
      deviceModel: deviceModel,
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
      reasoningDepth: entry.reasoningDepth,
      topicConfidence: entry.topicConfidence,
      countryCode: entry.countryCode,
      deviceId: entry.deviceId,
      deviceModel: entry.deviceModel,
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
      reasoningDepth: fields[7] as String? ?? '',
      topicConfidence: (fields[8] as num?)?.toDouble() ?? 0,
      countryCode: fields[9] as String?,
      deviceId: fields[10] as String?,
      deviceModel: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.latencyMs)
      ..writeByte(7)
      ..write(obj.reasoningDepth)
      ..writeByte(8)
      ..write(obj.topicConfidence)
      ..writeByte(9)
      ..write(obj.countryCode)
      ..writeByte(10)
      ..write(obj.deviceId)
      ..writeByte(11)
      ..write(obj.deviceModel);
  }
}

abstract final class HistoryStorageKeys {
  static const String boxName = 'history_items';
}
