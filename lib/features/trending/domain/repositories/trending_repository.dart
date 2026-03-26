import 'package:prompt_enhancer/features/trending/domain/entities/trending_topic.dart';

abstract class TrendingRepository {
  Future<List<TrendingTopic>> getTrendingTopics({int days = 7});
}
