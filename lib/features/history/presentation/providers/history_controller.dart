import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_filters.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_state.dart';
import 'package:prompt_enhancer/features/metrics/presentation/providers/metrics_providers.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_providers.dart';

class HistoryController extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    Future.microtask(loadHistory);
    return const HistoryState(loading: true);
  }

  Future<void> loadHistory() async {
    final selectedTopic = state.selectedTopic;
    final selectedProvider = state.selectedProvider;
    final selectedDateFilter = state.selectedDateFilter;

    state = state.copyWith(loading: true, error: null);

    try {
      final items = await ref.read(getHistoryUseCaseProvider)();
      state = _buildFilteredState(
        items: items,
        selectedTopic: selectedTopic,
        selectedProvider: selectedProvider,
        selectedDateFilter: selectedDateFilter,
      ).copyWith(loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, error: _mapError(error));
    }
  }

  void setTopicFilter(String? value) {
    state = _buildFilteredState(
      items: state.allItems,
      selectedTopic: value,
      selectedProvider: state.selectedProvider,
      selectedDateFilter: state.selectedDateFilter,
    );
  }

  void setProviderFilter(String? value) {
    state = _buildFilteredState(
      items: state.allItems,
      selectedTopic: state.selectedTopic,
      selectedProvider: value,
      selectedDateFilter: state.selectedDateFilter,
    );
  }

  void setDateFilter(HistoryDateFilter value) {
    state = _buildFilteredState(
      items: state.allItems,
      selectedTopic: state.selectedTopic,
      selectedProvider: state.selectedProvider,
      selectedDateFilter: value,
    );
  }

  Future<String> deleteItem(HistoryEntry entry) async {
    try {
      await ref.read(deleteHistoryUseCaseProvider)(entry.timestamp);
      _refreshDerivedFeatures();
      await loadHistory();
      return state.error ?? 'History item deleted.';
    } catch (error) {
      final message = _mapDeleteError(error);
      state = state.copyWith(error: message);
      return message;
    }
  }

  HistoryState _buildFilteredState({
    required List<HistoryEntry> items,
    required String? selectedTopic,
    required String? selectedProvider,
    required HistoryDateFilter selectedDateFilter,
  }) {
    final filteredItems =
        items
            .where((item) {
              final matchesTopic =
                  selectedTopic == null ||
                  selectedTopic.isEmpty ||
                  item.topic == selectedTopic;
              final matchesProvider =
                  selectedProvider == null ||
                  selectedProvider.isEmpty ||
                  item.provider == selectedProvider;
              final matchesDate = _matchesDateFilter(
                item.timestamp,
                selectedDateFilter,
              );
              return matchesTopic && matchesProvider && matchesDate;
            })
            .toList(growable: false)
          ..sort((left, right) => right.timestamp.compareTo(left.timestamp));

    return state.copyWith(
      allItems: items,
      filteredItems: filteredItems,
      selectedTopic: selectedTopic,
      selectedProvider: selectedProvider,
      selectedDateFilter: selectedDateFilter,
      error: null,
    );
  }

  bool _matchesDateFilter(DateTime timestamp, HistoryDateFilter filter) {
    if (filter == HistoryDateFilter.all) {
      return true;
    }

    final now = DateTime.now();
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case HistoryDateFilter.all:
        return true;
      case HistoryDateFilter.today:
        return date == today;
      case HistoryDateFilter.last7Days:
        return !date.isBefore(today.subtract(const Duration(days: 6)));
      case HistoryDateFilter.last30Days:
        return !date.isBefore(today.subtract(const Duration(days: 29)));
    }
  }

  void _refreshDerivedFeatures() {
    ref.invalidate(trendingControllerProvider);
    ref.invalidate(metricsControllerProvider);
  }

  String _mapDeleteError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Unable to delete this history item right now.';
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Unable to load history right now.';
  }
}
