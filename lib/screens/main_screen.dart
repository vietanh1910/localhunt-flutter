// file: screens/main_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/reward.dart';
import '../models/redemption_history_item.dart';
import './reward_screen.dart';
import './home_screen.dart';
import './task_screen.dart';
import './history_screen.dart';
import 'campaign_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index của tab đang được chọn

  // --- LIFTING STATE UP ---
  // Toàn bộ trạng thái quan trọng của ứng dụng được chuyển từ RewardScreen lên đây
  // để có thể chia sẻ và quản lý từ một nơi duy nhất.
  int _userCoins = 50;
  final List<Reward> _rewards = [
    // ... (Giữ nguyên dữ liệu Reward của bạn)
    Reward(
      id: 'R1',
      name: 'Voucher Giảm 20% Highlands Coffee',
      description: 'Áp dụng cho tất cả các sản phẩm nước uống.',
      content: 'Điều kiện áp dụng:\n- Áp dụng cho tất cả các sản phẩm nước uống tại hệ thống Highlands Coffee trên toàn quốc.\n- Voucher không có giá trị quy đổi thành tiền mặt.\n- Mỗi hóa đơn chỉ được áp dụng 1 voucher.\n- Hạn sử dụng: 30/09/2025.',
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
      content: 'Nhận ngay 1 phần bắp rang bơ vị mặn (lớn) miễn phí khi mua vé xem phim 2D tại tất cả các cụm rạp CGV Cinemas. Vui lòng xuất trình mã voucher này tại quầy bắp nước để nhận ưu đãi.',
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
      content: 'Sử dụng để mua sắm hàng ngàn sản phẩm trên sàn thương mại điện tử Tiki.vn. Không áp dụng cho các sản phẩm của nhà bán hàng quốc tế hoặc các dịch vụ tiện ích (thẻ cào, vé máy bay...).',
      imageUrl: 'assets/images/tiki.png',
      cost: 4,
      quantity: 10,
      redemptionLimit: 1,
      timesRedeemedByUser: 1,
    ),
  ];
  final List<RedemptionHistoryItem> _redemptionHistory = [];

  // Hàm xử lý việc đổi quà, cũng được chuyển lên đây
  void _redeemReward(int originalIndex) {
    final reward = _rewards[originalIndex];
    if (_userCoins < reward.cost ||
        reward.quantity <= 0 ||
        reward.timesRedeemedByUser >= reward.redemptionLimit) {
      // Hiển thị thông báo không thành công nếu cần
      return;
    }
    setState(() {
      _userCoins -= reward.cost;
      _rewards[originalIndex] = Reward(
        id: reward.id, name: reward.name, description: reward.description, content: reward.content, imageUrl: reward.imageUrl, cost: reward.cost,
        quantity: reward.quantity - 1, // Giảm số lượng
        redemptionLimit: reward.redemptionLimit,
        timesRedeemedByUser: reward.timesRedeemedByUser + 1, // Tăng số lần đã đổi
      );

      // Thêm vào lịch sử đổi thưởng
      final historyItem = RedemptionHistoryItem(
        rewardName: reward.name, rewardImageUrl: reward.imageUrl, cost: reward.cost, redemptionDate: DateTime.now(),
      );
      _redemptionHistory.add(historyItem);
    });

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

  // Hàm điều hướng sang trang lịch sử, gọi từ Drawer
  void _showHistory() {
    Navigator.of(context).pop(); // Đóng Drawer trước khi điều hướng
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => HistoryScreen(history: _redemptionHistory)),
    );
  }

  // Hàm chọn tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình tương ứng với các tab
    // Truyền dữ liệu và hàm callback xuống cho RewardScreen
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
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Hiển thị số xu ở AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              backgroundColor: Colors.white,
              avatar: const Icon(Icons.monetization_on, color: Colors.orange),
              label: Text(
                '$_userCoins Xu',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue,),
              ),
            ),
          )
        ],
      ),
      // THÊM MỚI: Burger Menu (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Cài đặt',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Lịch Sử Đổi Thưởng'),
              onTap: _showHistory, // Gọi hàm hiển thị lịch sử
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                // Thêm logic đăng xuất và quay về trang đăng nhập tại đây
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()), // Quay về LoginPage
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // THÊM MỚI: Bottom Navigation Bar
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