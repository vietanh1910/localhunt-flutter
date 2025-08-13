import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/campaign.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
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
    isInRange = distance <= widget.campaign.radius;
  });
  print('📍 User location: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
print('📍 Campaign location: ${widget.campaign.latitude}, ${widget.campaign.longitude}');
  }

  Future<void> _performCheckIn() async {
    // Nếu đang check-in thì bỏ qua
    if (isCheckingIn) return;

    // Bắt đầu check-in
    if (mounted) {
      setState(() {
        isCheckingIn = true;
      });
    }

    try {
      // Mock quét QR code
      String scannedCode = "TEST1234";
      debugPrint("Quét được mã: $scannedCode");

      // Giả lập gọi API / xử lý mất 2 giây
      await Future.delayed(const Duration(seconds: 2));

      // Ví dụ: kiểm tra mã QR đúng không
      bool isValid = scannedCode == "TEST1234";

      if (!mounted) return; // Nếu đã rời màn hình thì thoát luôn

      if (isValid) {
        setState(() {
          checkInSuccess = true;
        });

        // Thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Check-in thành công!")),
        );
      } else {
        // Thông báo thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mã QR không hợp lệ!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi check-in: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCheckingIn = false;
        });
      }
    }
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
          'Bạn đã nhận ${widget.campaign.pointReward} xu(s)',
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
                    widget.campaign.address,
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
                Text('Check-in radius: ${widget.campaign.radius.toInt()}m'),
              ],
            ),
            if (widget.campaign.wifiName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.wifi, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Text('Wi-Fi: ${widget.campaign.wifiName}'),
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
                      '${widget.campaign.pointReward} xu(s)',
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