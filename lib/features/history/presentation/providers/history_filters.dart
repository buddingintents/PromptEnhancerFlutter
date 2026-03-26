enum HistoryDateFilter { all, today, last7Days, last30Days }

extension HistoryDateFilterX on HistoryDateFilter {
  String get label {
    switch (this) {
      case HistoryDateFilter.all:
        return 'All time';
      case HistoryDateFilter.today:
        return 'Today';
      case HistoryDateFilter.last7Days:
        return 'Last 7 days';
      case HistoryDateFilter.last30Days:
        return 'Last 30 days';
    }
  }
}
