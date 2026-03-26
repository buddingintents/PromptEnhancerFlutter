import 'package:prompt_enhancer/features/trending/domain/entities/trending_topic.dart';

class TrendingState {
  const TrendingState({
    this.topics = const [],
    this.loading = false,
    this.error,
  });

  final List<TrendingTopic> topics;
  final bool loading;
  final String? error;

  TrendingState copyWith({
    List<TrendingTopic>? topics,
    bool? loading,
    Object? error = _sentinel,
  }) {
    return TrendingState(
      topics: topics ?? this.topics,
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();
