import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/campaign.dart';
import '../services/api_service.dart';
import 'campaign_detail_screen.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({Key? key}) : super(key: key);

  @override
  _CampaignListScreenState createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  List<Campaign> campaigns = [];
  List<CampaignWithDistance> campaignsWithDistance = [];
  bool isLoading = true;
  bool isLoadingLocation = true;
  String? errorMessage;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _getCurrentLocation(),
      _loadCampaigns(),
    ]);
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        isLoadingLocation = true;
      });

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
        isLoadingLocation = false;
      });

      // Recalculate distances if campaigns are already loaded
      if (campaigns.isNotEmpty) {
        _calculateDistancesAndSort();
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadCampaigns() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final campaignList = await ApiService.getCampaigns();
      
      setState(() {
        campaigns = campaignList;
        isLoading = false;
      });

      // Calculate distances if location is already available
      if (currentPosition != null) {
        _calculateDistancesAndSort();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Cannot load campaign lists: $e';
        isLoading = false;
      });
    }
  }

  void _calculateDistancesAndSort() {
    if (currentPosition == null || campaigns.isEmpty) return;

    List<CampaignWithDistance> tempList = campaigns.map((campaign) {
      double distance = 0;
      
      if (campaign.latitude != 0 && campaign.longitude != 0) {
        distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          campaign.latitude,
          campaign.longitude,
        );
      }

      return CampaignWithDistance(
        campaign: campaign,
        distance: distance,
      );
    }).toList();

    // Sort by distance (nearest first)
    tempList.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {
      campaignsWithDistance = tempList;
    });
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
              onPressed: _getCurrentLocation,
              tooltip: 'Refresh location',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
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
        child: Text(
          'No campaigns available',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Show location loading status
    if (isLoadingLocation && currentPosition == null) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange[100],
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Getting your location to show nearest campaigns...'),
              ],
            ),
          ),
          Expanded(child: _buildCampaignList()),
        ],
      );
    }

    return Column(
      children: [
        // Location status bar
        if (currentPosition == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red[100],
            child: const Row(
              children: [
                Icon(Icons.location_off, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location not available. Campaigns are shown in default order.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
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
                Text(
                  'Campaigns sorted by distance (nearest first)',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        Expanded(child: _buildCampaignList()),
      ],
    );
  }

  Widget _buildCampaignList() {
    // Use campaigns with distance if available, otherwise use original list
    final displayList = currentPosition != null && campaignsWithDistance.isNotEmpty
        ? campaignsWithDistance
        : campaigns.map((c) => CampaignWithDistance(campaign: c, distance: 0)).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];
        return _buildCampaignCard(item);
      },
    );
  }

  Widget _buildCampaignCard(CampaignWithDistance campaignWithDistance) {
    final campaign = campaignWithDistance.campaign;
    final distance = campaignWithDistance.distance;
    final bool hasDistance = currentPosition != null && distance > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailScreen(campaign: campaign),
            ),
          );
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${campaign.pointReward} point',
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
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      campaign.address,
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
                    Icon(
                      Icons.near_me,
                      size: 16,
                      color: Colors.blue[600],
                    ),
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
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Radius: ${campaign.radius.toInt()}m',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()}m away';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km away';
    }
  }
}

// Helper class to combine campaign with distance
class CampaignWithDistance {
  final Campaign campaign;
  final double distance;

  CampaignWithDistance({
    required this.campaign,
    required this.distance,
  });
}