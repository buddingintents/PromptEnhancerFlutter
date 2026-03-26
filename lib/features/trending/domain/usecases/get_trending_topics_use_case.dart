import 'package:prompt_enhancer/features/trending/domain/entities/trending_topic.dart';
import 'package:prompt_enhancer/features/trending/domain/repositories/trending_repository.dart';

class GetTrendingTopicsUseCase {
  const GetTrendingTopicsUseCase(this._trendingRepository);

  final TrendingRepository _trendingRepository;

  Future<List<TrendingTopic>> call({int days = 7}) {
    return _trendingRepository.getTrendingTopics(days: days);
  }
}
