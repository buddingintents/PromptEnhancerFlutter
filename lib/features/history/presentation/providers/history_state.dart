import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_filters.dart';

class HistoryState {
  const HistoryState({
    this.allItems = const [],
    this.filteredItems = const [],
    this.selectedTopic,
    this.selectedProvider,
    this.selectedDateFilter = HistoryDateFilter.all,
    this.loading = false,
    this.error,
  });

  final List<HistoryEntry> allItems;
  final List<HistoryEntry> filteredItems;
  final String? selectedTopic;
  final String? selectedProvider;
  final HistoryDateFilter selectedDateFilter;
  final bool loading;
  final String? error;

  int get visibleCount => filteredItems.length;

  List<String> get topics {
    final values =
        allItems
            .map((item) => item.topic)
            .where((value) => value.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return values;
  }

  int get topicCount => topics.length;

  List<String> get providers {
    final values =
        allItems
            .map((item) => item.provider)
            .where((value) => value.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return values;
  }

  int get providerCount => providers.length;

  HistoryState copyWith({
    List<HistoryEntry>? allItems,
    List<HistoryEntry>? filteredItems,
    Object? selectedTopic = _sentinel,
    Object? selectedProvider = _sentinel,
    HistoryDateFilter? selectedDateFilter,
    bool? loading,
    Object? error = _sentinel,
  }) {
    return HistoryState(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedTopic: identical(selectedTopic, _sentinel)
          ? this.selectedTopic
          : selectedTopic as String?,
      selectedProvider: identical(selectedProvider, _sentinel)
          ? this.selectedProvider
          : selectedProvider as String?,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();
