// file: screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:authen/screens/login_screen.dart'; // import màn login
import '../models/reward.dart';

// Import cả hai model
import '../models/redemption_history_item.dart';
import '../models/transaction_history_item.dart';

import './reward_screen.dart';
import './home_screen.dart';
import './task_screen.dart';

// Import cả hai màn hình lịch sử
import './history_screen.dart'; // Màn hình đổi thưởng
import './transaction_history_screen.dart'; // Màn hình giao dịch
import './campaign_detail_screen.dart';
import 'campaign_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  int _userCoins = 50;
  final List<Reward> _rewards = [
    Reward(
      id: 'R1',
      name: 'Voucher Giảm 20% Highlands Coffee',
      description: 'Áp dụng cho tất cả các sản phẩm nước uống.',
      content:
      'Điều kiện áp dụng:\n- Áp dụng cho tất cả các sản phẩm nước uống tại hệ thống Highlands Coffee trên toàn quốc.\n- Voucher không có giá trị quy đổi thành tiền mặt.\n- Mỗi hóa đơn chỉ được áp dụng 1 voucher.\n- Hạn sử dụng: 30/09/2025.',
      imageUrl: 'assets/images/hightland.png',
      cost: 5,
      quantity: 15,
      redemptionLimit: 1,
      timesRedeemedByUser: 0,
    ),
    Reward(
      id: 'R2',
      name: 'Miễn Phí 1 Suất Bắp Rang Bơ CGV',
      description: 'Nhận ngay 1 phần bắp rang bơ miễn phí.',
      content:
      'Nhận ngay 1 phần bắp rang bơ vị mặn (lớn) miễn phí khi mua vé xem phim 2D tại tất cả các cụm rạp CGV Cinemas. Vui lòng xuất trình mã voucher này tại quầy bắp nước để nhận ưu đãi.',
      imageUrl: 'assets/images/cgv.png',
      cost: 3,
      quantity: 5,
      redemptionLimit: 2,
      timesRedeemedByUser: 1,
    ),
    Reward(
      id: 'R3',
      name: 'Thẻ Quà Tặng 100.000đ Tiki',
      description: 'Sử dụng để mua sắm trên sàn Tiki.',
      content:
      'Sử dụng để mua sắm hàng ngàn sản phẩm trên sàn thương mại điện tử Tiki.vn. Không áp dụng cho các sản phẩm của nhà bán hàng quốc tế hoặc các dịch vụ tiện ích (thẻ cào, vé máy bay...).',
      imageUrl: 'assets/images/tiki.png',
      cost: 4,
      quantity: 10,
      redemptionLimit: 1,
      timesRedeemedByUser: 1,
    ),
  ];

  // Khai báo 2 danh sách lịch sử riêng biệt
  final List<RedemptionHistoryItem> _redemptionHistory = [];
  final List<TransactionHistoryItem> _transactionHistory = [];

  // Hàm đổi quà
  void _redeemReward(int originalIndex) {
    final reward = _rewards[originalIndex];
    if (_userCoins < reward.cost ||
        reward.quantity <= 0 ||
        reward.timesRedeemedByUser >= reward.redemptionLimit) {
      return;
    }
    setState(() {
      _userCoins -= reward.cost;
      _rewards[originalIndex] = Reward(
        id: reward.id,
        name: reward.name,
        description: reward.description,
        content: reward.content,
        imageUrl: reward.imageUrl,
        cost: reward.cost,
        quantity: reward.quantity - 1,
        redemptionLimit: reward.redemptionLimit,
        timesRedeemedByUser: reward.timesRedeemedByUser + 1,
      );

      // 1. Ghi vào LỊCH SỬ ĐỔI THƯỞNG
      final redemptionItem = RedemptionHistoryItem(
        rewardName: reward.name,
        rewardImageUrl: reward.imageUrl,
        cost: reward.cost,
        redemptionDate: DateTime.now(),
      );
      _redemptionHistory.add(redemptionItem);

      // 2. Ghi vào LỊCH SỬ GIAO DỊCH
      final transactionItem = TransactionHistoryItem(
        title: 'Đổi thưởng: ${reward.name}',
        amount: reward.cost,
        type: TransactionType.spend,
        date: DateTime.now(),
      );
      _transactionHistory.add(transactionItem);
    });

    // === SỬA LỖI: THÊM LẠI NỘI DUNG CHO showDialog ===
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi Quà Thành Công!'),
        content: Text('Bạn đã đổi thành công "${reward.name}".'),
        actions: <Widget>[
          TextButton(
            child: const Text('Tuyệt vời'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  // Hàm kiếm Xu
  void _addCoins(int amount, String reason) {
    setState(() {
      _userCoins += amount;
      final transaction = TransactionHistoryItem(
        title: reason,
        amount: amount,
        type: TransactionType.earn,
        date: DateTime.now(),
      );
      _transactionHistory.add(transaction);
    });
  }

  // Tạo 2 hàm điều hướng riêng
  void _showRedemptionHistory() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => HistoryScreen(history: _redemptionHistory)),
    );
  }

  void _showTransactionHistory() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => TransactionHistoryScreen(
              transactions: _transactionHistory)),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const HomeScreen(),
      RewardScreen(
        userCoins: _userCoins,
        rewards: _rewards,
        onRedeemReward: _redeemReward, // Truyền hàm xử lý xuống
      ),
      const CampaignListScreen(),
    ];

    const List<String> _titles = <String> [
      'Trang Chủ',
      'Ví Thưởng Của Bạn',
      'Nhiệm Vụ',
    ];

    return Scaffold(
      // === SỬA LỖI: Thêm nội dung đầy đủ cho AppBar ===
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              backgroundColor: Colors.white,
              avatar: const Icon(Icons.monetization_on, color: Colors.orange),
              label: Text(
                '$_userCoins Xu',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu & Tiện ích',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard_outlined),
              title: const Text('Lịch Sử Đổi Thưởng'),
              onTap: _showRedemptionHistory,
            ),
            ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: const Text('Lịch Sử Giao Dịch Xu'),
              onTap: _showTransactionHistory,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      // === SỬA LỖI: Thêm nội dung đầy đủ cho BottomNavigationBar ===
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Đổi thưởng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Nhiệm vụ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}