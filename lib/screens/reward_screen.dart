// file: screens/reward_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // Import thư viện math để sử dụng giá trị Pi
import '../models/reward.dart';
import './reward_detail_screen.dart';

class RewardScreen extends StatefulWidget {
  final int userCoins;
  final List<Reward> rewards;
  final Function(int) onRedeemReward;

  const RewardScreen({
    Key? key,
    required this.userCoins,
    required this.rewards,
    required this.onRedeemReward,
  }) : super(key: key);

  @override
  _RewardScreenState createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _shakeAnimation = Tween<double>(begin: -0.02, end: 0.02)
        .animate(_animationController);

    _colorAnimation = ColorTween(
      begin: Colors.deepOrangeAccent,
      end: Colors.amber,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDetail(BuildContext context, Reward reward, int originalIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RewardDetailScreen(
          reward: reward,
          userCoins: widget.userCoins,
          onRedeem: () {
            widget.onRedeemReward(originalIndex);
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.help_outline, color: Colors.blue),
            const SizedBox(width: 8),
            // ĐÃ SỬA LỖI: Bọc Text bằng Expanded để tự động co giãn, không bị tràn
            const Expanded(
              child: Text(
                'Hướng Dẫn Đổi Thưởng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildTutorialStep(
                  '1.', 'Kiểm tra số Xu bạn đang có ở thanh trên cùng.'),
              _buildTutorialStep('2.',
                  'Mỗi phần thưởng sẽ hiển thị số Xu cần thiết để đổi.'),
              _buildTutorialStep(
                  '3.', 'Nếu đủ Xu, nhấn nút "Đổi" để nhận quà ngay lập tức!'),
              _buildTutorialStep('4.',
                  'Nhấn "Chi Tiết" để xem thêm các điều kiện áp dụng của phần thưởng.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Đã Hiểu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number,
              style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Reward> availableRewards = widget.rewards.where((reward) {
      return reward.quantity > 0 &&
          reward.timesRedeemedByUser < reward.redemptionLimit;
    }).toList();

    return Stack(
      children: [
        availableRewards.isEmpty
            ? const Center(
          child: Text(
            'Hiện không có phần thưởng nào khả dụng.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
          itemCount: availableRewards.length,
          itemBuilder: (context, index) {
            final reward = availableRewards[index];
            final originalIndex = widget.rewards.indexOf(reward);
            final bool canAfford = widget.userCoins >= reward.cost;

            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            reward.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.card_giftcard,
                                    size: 50, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward.name,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                reward.description,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Đã đổi: ${reward.timesRedeemedByUser}/${reward.redemptionLimit} | Còn lại: ${reward.quantity}',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade800,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          avatar: Icon(Icons.monetization_on,
                              color:
                              canAfford ? Colors.orange : Colors.grey),
                          label: Text('${reward.cost} Xu',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          backgroundColor: canAfford
                              ? Colors.orange.shade50
                              : Colors.grey.shade300,
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  _showDetail(context, reward, originalIndex),
                              child: const Text('Chi Tiết'),
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: canAfford
                                  ? () =>
                                  widget.onRedeemReward(originalIndex)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Đổi'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _shakeAnimation.value * math.pi,
                child: FloatingActionButton(
                  mini: true,
                  tooltip: 'Hướng dẫn đổi thưởng',
                  onPressed: () {
                    _showTutorialDialog(context);
                  },
                  backgroundColor: _colorAnimation.value,
                  child:
                  const Icon(Icons.question_mark, color: Colors.white, size: 24),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}