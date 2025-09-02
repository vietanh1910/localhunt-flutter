// File: lib/screens/qr_display_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:authen/services/api_service.dart';
import 'package:authen/models/voucher_qr_response.dart';

class QrDisplayScreen extends StatefulWidget {
  final VoucherQrResponse qrResponse;
  final ApiService apiService;

  const QrDisplayScreen({
    super.key,
    required this.qrResponse,
    required this.apiService,
  });

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  Timer? _countdownTimer;
  Timer? _statusCheckTimer;

  Duration _remainingTime = Duration.zero;
  Uint8List? _qrImageBytes;
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.qrResponse.status;
    _decodeQrImage();
    _startCountdown();
    _startPollingForStatus();
  }

  void _decodeQrImage() {
    try {
      _qrImageBytes = Base64Decoder().convert(widget.qrResponse.qrImageBase64);
    } catch (e) {
      print('Lỗi khi giải mã hình ảnh QR: $e');
    }
  }

  void _startCountdown() {
    _remainingTime = widget.qrResponse.expiryDate.difference(DateTime.now());

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final newRemainingTime = _remainingTime - const Duration(seconds: 1);
      setState(() {
        _remainingTime = newRemainingTime;
      });
      if (newRemainingTime.inSeconds <= 0) {
        setState(() {
          _currentStatus = 'EXPIRED';
        });
        _stopAllTimers();
      }
    });
  }

  void _startPollingForStatus() {
    if (_currentStatus != 'ACTIVE') return;

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        final newStatusResponse = await widget.apiService.getQrStatus(widget.qrResponse.code);

        if (mounted && newStatusResponse.status != _currentStatus) {
          setState(() {
            _currentStatus = newStatusResponse.status;
          });

          if (_currentStatus == 'USED' || _currentStatus == 'EXPIRED') {
            _stopAllTimers();
            if (_currentStatus == 'USED') {
              _showSuccessDialog();
            }
          }
        }
      } catch (e) {
        print("Lỗi khi kiểm tra trạng thái QR: $e");
        _stopAllTimers();
      }
    });
  }

  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Thành công!'),
        content: const Text('Voucher của bạn đã được sử dụng.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _stopAllTimers() {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
  }

  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = _remainingTime.isNegative || _currentStatus == 'EXPIRED';
    final bool isUsed = _currentStatus == 'USED';
    final bool isActive = !isExpired && !isUsed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR Voucher'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUsed)
                const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 150, color: Colors.green),
                    SizedBox(height: 10),
                    Text('Voucher đã được sử dụng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                )
              else if (isExpired)
                const Column(
                  children: [
                    Icon(Icons.timer_off_outlined, size: 150, color: Colors.red),
                    SizedBox(height: 10),
                    Text('Mã QR đã hết hạn!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                )
              else if (_qrImageBytes != null)
                  Image.memory(_qrImageBytes!, width: 250, height: 250, fit: BoxFit.contain)
                else
                  const CircularProgressIndicator(),

              const SizedBox(height: 30),

              if (isActive)
                Text(
                  'Mã QR sẽ hết hạn trong: ${_formatDuration(_remainingTime)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 20),
              Text('Mã code: ${widget.qrResponse.code}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 10),

              Text(
                'Trạng thái: $_currentStatus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _currentStatus == 'ACTIVE' ? Colors.blue : (_currentStatus == 'USED' ? Colors.green : Colors.red),
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, isUsed);
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                ),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}