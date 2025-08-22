import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/campaign.dart';
import '../services/campaign_service.dart';
import 'campaign_detail_screen.dart';
import 'campaign_map_tab.dart';

class CampaignListScreen extends StatefulWidget {
  final Campaign? completedCampaign; // ✅ nhận campaign đã hoàn thành

  const CampaignListScreen({Key? key, this.completedCampaign}) : super(key: key);

  @override
  _CampaignListScreenState createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen>
    with SingleTickerProviderStateMixin {
  List<Campaign> campaigns = [];
  List<CampaignWithDistance> campaignsWithDistance = [];
  bool isLoading = true;
  bool isLoadingLocation = true;
  String? errorMessage;
  Position? currentPosition;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ Lấy location trước rồi gọi API
  Future<void> _initializeData() async {
    try {
      await _getCurrentLocation();
      await _loadCampaigns();

      // ✅ Nếu có campaign vừa completed thì cập nhật vào list
      if (widget.completedCampaign != null) {
        final index =
        campaigns.indexWhere((c) => c.id == widget.completedCampaign!.id);
        if (index != -1) {
          setState(() {
            campaigns[index] = widget.completedCampaign!;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Initialize data failed: $e";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (mounted) setState(() => isLoadingLocation = true);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => isLoadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        currentPosition = position;
        isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingLocation = false);
    }
  }

  Future<void> _loadCampaigns() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final campaignList = await CampaignService.getCampaigns(
        lat: currentPosition?.latitude,
        lon: currentPosition?.longitude,
      );

      if (!mounted) return;

      setState(() {
        campaigns = campaignList;
        isLoading = false;
      });

      if (currentPosition != null) _calculateDistancesAndSort();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Cannot load campaign lists: $e';
        isLoading = false;
      });
    }
  }

  void _calculateDistancesAndSort() {
    if (currentPosition == null || campaigns.isEmpty) return;

    final tempList = campaigns.map((campaign) {
      double distance = 0;
      if (campaign.latitude != 0 && campaign.longitude != 0) {
        distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          campaign.latitude,
          campaign.longitude,
        );
      }
      return CampaignWithDistance(campaign: campaign, distance: distance);
    }).toList();

    tempList.sort((a, b) => a.distance.compareTo(b.distance));
    if (mounted) setState(() => campaignsWithDistance = tempList);
  }

  Future<void> _refresh() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Campaign'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () async {
                await _getCurrentLocation();
                await _loadCampaigns();
              },
              tooltip: 'Refresh location',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'List'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(onRefresh: _refresh, child: _buildListBody()),
          CampaignMapTab(
            campaigns: campaigns,
            currentPosition: currentPosition,
            onRefreshLocation: _getCurrentLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildListBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading campaigns...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCampaigns,
              child: const Text('Retry!'),
            ),
          ],
        ),
      );
    }

    if (campaigns.isEmpty) {
      return const Center(
        child: Text('No campaigns available', style: TextStyle(fontSize: 16)),
      );
    }

    return Column(
      children: [
        if (currentPosition == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red[100],
            child: const Row(
              children: [
                Icon(Icons.location_off, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Expanded(child: Text('Location not available.')),
              ],
            ),
          ),
        if (currentPosition != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green[100],
            child: const Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Campaigns sorted by distance'),
              ],
            ),
          ),
        Expanded(child: _buildCampaignList()),
      ],
    );
  }

  Widget _buildCampaignList() {
    final displayList = currentPosition != null && campaignsWithDistance.isNotEmpty
        ? campaignsWithDistance
        : campaigns
        .map((c) => CampaignWithDistance(campaign: c, distance: 0))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];
        return _buildCampaignCard(item);
      },
    );
  }

  Widget _buildCampaignCard(CampaignWithDistance cwd) {
    final campaign = cwd.campaign;
    final distance = cwd.distance;
    final hasDistance = currentPosition != null && distance > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailScreen(campaign: campaign),
            ),
          );

          if (result == true) {
            // 🔥 gọi lại API để refresh danh sách
            _loadCampaigns();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${campaign.rewardPerCheckin} point',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      campaign.locationName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              if (hasDistance) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.near_me, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDistance(distance),
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                campaign.description,
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()}m away';
    return '${(meters / 1000).toStringAsFixed(1)}km away';
  }
}

class CampaignWithDistance {
  final Campaign campaign;
  final double distance;
  CampaignWithDistance({required this.campaign, required this.distance});
}
