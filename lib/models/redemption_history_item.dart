
class RedemptionHistoryItem {
  final String rewardName;
  final String rewardImageUrl;
  final int cost;
  final DateTime redemptionDate;

  RedemptionHistoryItem({
    required this.rewardName,
    required this.rewardImageUrl,
    required this.cost,
    required this.redemptionDate,
  });
}