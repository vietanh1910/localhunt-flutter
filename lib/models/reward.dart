// file: models/reward.dart

class Reward {
  final String id;
  final String name;
  final String description;
  final String content;
  final String imageUrl;
  final int cost;
  final int quantity;
  final int redemptionLimit;
  final int timesRedeemedByUser;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.cost,
    required this.quantity,
    required this.redemptionLimit,
    required this.timesRedeemedByUser,
  });
}