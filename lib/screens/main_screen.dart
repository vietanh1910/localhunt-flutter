// File: lib/screens/main_screen.dart

import 'package:flutter/material.dart';

// Import các models cần thiết
import '../models/user.dart';
import '../models/voucher.dart';
import '../models/transaction_history_item.dart';

// Import các services
import '../services/api_service.dart';
import '../services/auth_api.dart'; // Giữ lại nếu bạn có hàm logout ở đây

// Import các màn hình
import 'login_screen.dart';
import 'reward_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'transaction_history_screen.dart';
import 'campaign_list_screen.dart';

class MainScreen extends StatefulWidget {
  final String loginToken;
  final User user;

  const MainScreen({Key? key, required this.loginToken, required this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late User _currentUser;
  late int _userCoins;

  late final ApiService _apiService;

  // State quản lý danh sách voucher có thể đổi
  late Future<List<Voucher>> _vouchersFuture;
  List<Voucher> _vouchers = [];

  // State quản lý lịch sử giao dịch (ví dụ tạm thời ở client)
  final List<TransactionHistoryItem> _transactionHistory = [];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _userCoins = _currentUser.points;

    // Khởi tạo ApiService và truyền token xác thực vào
    _apiService = ApiService();
    _apiService.setAuthToken(widget.loginToken);

    // Bắt đầu tải danh sách voucher có thể đổi
    _fetchAvailableVouchers();
  }

  // Tải danh sách các voucher mà người dùng CHƯA đổi từ backend
  void _fetchAvailableVouchers() {
    // Gán Future vào state để FutureBuilder có thể theo dõi
    _vouchersFuture = _apiService.getAvailableVouchers();

    // Xử lý kết quả khi Future hoàn thành
    _vouchersFuture.then((fetchedVouchers) {
      if (mounted) {
        setState(() => _vouchers = fetchedVouchers);
      }
    }).catchError((error) {
      // Hiển thị lỗi cho người dùng nếu không tải được voucher
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString().replaceFirst("Exception: ", "")), backgroundColor: Colors.red)
        );
      }
    });
  }

  // Xử lý logic khi người dùng bấm nút "Đổi" trên RewardScreen
  Future<void> _redeemVoucher(Voucher voucherToRedeem) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator())
    );

    try {
      await _apiService.redeemVoucher(voucherId: voucherToRedeem.id);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Tắt dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đổi voucher '${voucherToRedeem.name}' thành công!"), backgroundColor: Colors.green)
        );

        // Cập nhật state cục bộ (số xu, lịch sử giao dịch)
        setState(() {
          _userCoins -= voucherToRedeem.cost;
          _transactionHistory.insert(0, TransactionHistoryItem(
            title: "Đổi voucher: ${voucherToRedeem.name}",
            date: DateTime.now(),
            amount: -voucherToRedeem.cost,
          ));
        });

        // Quan trọng: Tải lại danh sách voucher để voucher vừa đổi biến mất
        _fetchAvailableVouchers();
      }
    } catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Tắt dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString().replaceFirst("Exception: ", "")), backgroundColor: Colors.red)
        );
      }
    }
  }

  // Xử lý đăng xuất
  Future<void> _logout() async {
    // TODO: Gọi hàm xóa token từ AuthApi hoặc storage
    // Ví dụ: await AuthApi.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
  void _navigateToScreen(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const HomeScreen(),
      RewardScreen(
        vouchers: _vouchers,
        userCoins: _userCoins,
        onRedeem: _redeemVoucher,
        token: widget.loginToken,
      ),
      const CampaignListScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(['Trang Chủ', 'Ví Thưởng', 'Nhiệm vụ'][_selectedIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              backgroundColor: Colors.white,
              avatar: const Icon(Icons.monetization_on, color: Colors.orange),
              label: Text('$_userCoins Xu', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_currentUser.fullName),
              accountEmail: Text(_currentUser.email),
              currentAccountPicture: CircleAvatar(
                child: Text(_currentUser.fullName.isNotEmpty ? _currentUser.fullName[0].toUpperCase() : 'U'),
              ),
              decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
                leading: const Icon(Icons.card_giftcard_outlined),
                title: const Text('Voucher Của Tôi'),
                onTap: () {
                  Navigator.pop(context);
                  // Điều hướng đến HistoryScreen, truyền ApiService và UserId
                  _navigateToScreen(HistoryScreen(
                    apiService: _apiService,
                    currentUserId: _currentUser.id,
                  ));
                }
            ),
            ListTile(
                leading: const Icon(Icons.history_toggle_off),
                title: const Text('Lịch Sử Giao Dịch Xu'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToScreen(TransactionHistoryScreen(transactions: _transactionHistory));
                }
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Voucher>>(
        future: _vouchersFuture,
        builder: (context, snapshot) {
          // Hiển thị loading chỉ khi đang tải lần đầu và chưa có dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting && _vouchers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hiển thị lỗi chỉ khi tải lần đầu thất bại
          if (snapshot.hasError && _vouchers.isEmpty) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        snapshot.error.toString().replaceFirst("Exception: ", ""),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _fetchAvailableVouchers, child: const Text("Thử lại"))
                  ],
                )
            );
          }
          // Luôn hiển thị UI chính, dữ liệu sẽ được cập nhật một cách mượt mà
          return IndexedStack(index: _selectedIndex, children: widgetOptions);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Đổi thưởng'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Nhiệm vụ'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}