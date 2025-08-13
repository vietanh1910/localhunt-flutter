import 'package:flutter/material.dart';

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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
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
    } catch (e) {
      setState(() {
        errorMessage = 'Cannot load campaign lists: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Campaign'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCampaigns,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return _buildCampaignCard(campaign);
      },
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
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
}