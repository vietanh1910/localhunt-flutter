// File: lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:authen/models/redemption_history_item.dart';
import 'package:authen/models/voucher_qr_response.dart';
import 'package:authen/services/api_service.dart';
import 'package:authen/screens/qr_display_screen.dart';

import '../enums/redemption_status.dart';

class HistoryScreen extends StatefulWidget {
  final ApiService apiService;
  final int currentUserId;

  const HistoryScreen({
    Key? key,
    required this.apiService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RedemptionHistoryItem> _redeemedVouchers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRedeemedVouchers();
  }

  Future<void> _fetchRedeemedVouchers() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final history = await widget.apiService.getMyRedeemedVouchers(widget.currentUserId);
      if (mounted) setState(() => _redeemedVouchers = history);
    } catch (e) {
      if (mounted) setState(() => _error = 'Không thể tải lịch sử: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUseVoucher(RedemptionHistoryItem historyItem) async {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));
    try {
      final qrResponse = await widget.apiService.getOrCreateVoucherQr(
        voucherId: historyItem.voucher.id,
        userId: widget.currentUserId,
      );
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading

      // Chờ kết quả trả về từ màn hình QR
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrDisplayScreen(
            qrResponse: qrResponse,
            apiService: widget.apiService,
          ),
        ),
      );

      // Nếu kết quả trả về là 'true' (nghĩa là voucher đã được sử dụng thành công)
      // thì tải lại lịch sử để cập nhật giao diện
      if (result == true) {
        _fetchRedeemedVouchers();
      }
    } catch(e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher Của Tôi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
        onRefresh: _fetchRedeemedVouchers,
        child: _redeemedVouchers.isEmpty
            ? const Center(child: Text('Bạn chưa đổi voucher nào.'))
            : ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: _redeemedVouchers.length,
          itemBuilder: (ctx, index) {
            final historyItem = _redeemedVouchers[index];
            final voucher = historyItem.voucher;
            // === LẤY TRẠNG THÁI TỪ historyItem THAY VÌ TỪ VOUCHER ===
            final bool isUsed = historyItem.status == RedemptionStatus.used;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(voucher.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(voucher.description, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text(
                      'Đổi lúc: ${DateFormat('HH:mm, dd/MM/yyyy').format(historyItem.redeemedAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      // === GIAO DIỆN NÚT BẤM DỰA VÀO BIẾN isUsed ===
                      child: ElevatedButton(
                        onPressed: isUsed ? null : () => _handleUseVoucher(historyItem),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUsed ? Colors.grey[700] : Colors.blue, // Màu xám đậm khi đã dùng
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(isUsed ? 'Đã Sử Dụng' : 'Sử Dụng'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}