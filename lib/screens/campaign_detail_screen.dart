import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/campaign.dart';
import '../services/checkins_service.dart';
import 'qr_scan_screen.dart';

class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetailScreen({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  @override
  _CampaignDetailScreenState createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  bool isCheckingIn = false;
  bool checkInSuccess = false;
  Position? currentPosition;
  bool isInRange = false;
  double? distanceToLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Need location permission to check-in');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage('Please grant location permission in settings');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
      });

      _calculateDistance();
    } catch (e) {
      _showMessage('Cannot get recent location: $e');
    }
  }

  void _calculateDistance() {
  if (currentPosition == null || widget.campaign.latitude == 0 || widget.campaign.longitude == 0) {
    setState(() {
      distanceToLocation = null;
      isInRange = false;
    });
    return;
  }

  final double distance = Geolocator.distanceBetween(
    currentPosition!.latitude,
    currentPosition!.longitude,
    widget.campaign.latitude,
    widget.campaign.longitude,
  );

  setState(() {
    distanceToLocation = distance;
    isInRange = distance <= widget.campaign.radiusMeters;
  });
  print('📍 User location: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
print('📍 Campaign location: ${widget.campaign.latitude}, ${widget.campaign.longitude}');
  }

  Future<void> _performCheckIn() async {
    if (isCheckingIn) return;

    if (mounted) setState(() => isCheckingIn = true);

    try {
      // B1. Quét QR
      final scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const QRScanScreen()),
      );

      if (scannedCode == null) {
        _showPopup("⚠️ Lỗi", "Không quét được mã QR!", false);
        return;
      }

      // B2. Parse QR
      Map<String, dynamic> qrData;
      try {
        qrData = Map<String, dynamic>.from(jsonDecode(scannedCode));
      } catch (_) {
        _showPopup("❌ Sai định dạng", "QR code không hợp lệ!", false);
        return;
      }

      // B3. So sánh với campaign hiện tại
      bool isValid =
          qrData["id"] == widget.campaign.id &&
              qrData["ssid"] == widget.campaign.requiredWifiSsid &&
              qrData["bssid"] == widget.campaign.requiredWifiBssid &&
              qrData["status"] == widget.campaign.status;

      if (!isValid) {
        _showPopup("❌ Thất bại", "Mã QR không khớp với chiến dịch!", false);
        return;
      }

      // B4. Gọi API check-in
      try {
        final success = await CheckInService.createCheckIn(
          campaignId: widget.campaign.id,
          points: widget.campaign.rewardPerCheckin,
        );

        if (success) {
          // B5. Hiển thị popup thành công
          _showPopup("🎉 Thành công",
              "Bạn đã nhận được ${widget.campaign.rewardPerCheckin} xu(s)!", true,
              reloadList: true);
        }
      } catch (e) {
        _showPopup("⚠️ Lỗi", "Check-in thất bại: $e", false);
      }
    } finally {
      if (mounted) setState(() => isCheckingIn = false);
    }
  }


  /// Popup thông báo
  void _showPopup(String title, String message, bool success, {bool reloadList = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // đóng popup
                if (success) {
                  Navigator.of(context).pop(true); // 🔥 trả về true để list biết refresh
                }
              },
              child: const Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-in successfully!'),
        content: Text(
          'Bạn đã nhận ${widget.campaign.rewardPerCheckin} xu(s)',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to campaign list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign detail'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
            const SizedBox(height: 16),
            _buildRewardCard(),
            const SizedBox(height: 24),
            _buildCheckInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.campaign.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.campaign.locationName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.campaign.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.my_location, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text('Check-in radius: ${widget.campaign.radiusMeters.toInt()}m'),
              ],
            ),
            if (widget.campaign.requiredWifiSsid != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.wifi, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Text('Wi-Fi: ${widget.campaign.requiredWifiSsid}'),
                ],
              ),
            ],
            if (distanceToLocation != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isInRange ? Icons.check_circle : Icons.cancel,
                    color: isInRange ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Distance: ${distanceToLocation!.toInt()}m',
                    style: TextStyle(
                      color: isInRange ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reward',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.campaign.rewardPerCheckin} xu(s)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Receive after check-in successfully'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isCheckingIn ? null : _performCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: isInRange ? Colors.green : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isCheckingIn
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                isInRange ? 'Check-in right now' : 'Cannot check-in',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}