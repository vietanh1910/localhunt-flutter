import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/campaign.dart';
import 'campaign_detail_screen.dart';

/// Bước rẽ của tuyến đường
class RouteStep {
  final double distance;   // mét
  final double duration;   // giây
  final String? name;      // tên đường
  final String type;       // maneuver.type
  final String? modifier;  // left/right/straight/...
  final LatLng location;   // điểm để zoom

  RouteStep({
    required this.distance,
    required this.duration,
    required this.name,
    required this.type,
    required this.modifier,
    required this.location,
  });
}

class CampaignMapTab extends StatefulWidget {
  final List<Campaign> campaigns;
  final Position? currentPosition;
  final Future<void> Function() onRefreshLocation;

  const CampaignMapTab({
    Key? key,
    required this.campaigns,
    required this.currentPosition,
    required this.onRefreshLocation,
  }) : super(key: key);

  @override
  State<CampaignMapTab> createState() => _CampaignMapTabState();
}

class _CampaignMapTabState extends State<CampaignMapTab> {
  final MapController _mapController = MapController();

  Campaign? _selected;

  // polyline & summary
  List<LatLng> _route = [];
  double? _routeDistanceMeters;
  double? _routeDurationSeconds;
  List<RouteStep> _steps = [];

  @override
  void didUpdateWidget(covariant CampaignMapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != null &&
        (oldWidget.currentPosition == null ||
            oldWidget.currentPosition!.latitude != widget.currentPosition!.latitude ||
            oldWidget.currentPosition!.longitude != widget.currentPosition!.longitude)) {
      // Zoom to hơn khi có vị trí: 17
      _mapController.move(
        LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
        17,
      );
    }
  }

  LatLng _initialCenter() {
    if (widget.currentPosition != null) {
      return LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude);
    }
    for (final c in widget.campaigns) {
      if (c.latitude != 0 && c.longitude != 0) {
        return LatLng(c.latitude, c.longitude);
      }
    }
    return const LatLng(21.028511, 105.804817);
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // current position
    if (widget.currentPosition != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
          child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
        ),
      );
    }

    // campaigns
    for (final c in widget.campaigns) {
      if (c.latitude == 0 || c.longitude == 0) continue;
      markers.add(
        Marker(
          width: 48,
          height: 48,
          point: LatLng(c.latitude, c.longitude),
          child: GestureDetector(
            onTap: () => _onSelectCampaign(c),
            child: const Icon(Icons.location_on, color: Colors.red, size: 36),
          ),
        ),
      );
    }

    return markers;
  }

  void _onSelectCampaign(Campaign c) {
    setState(() {
      _selected = c;
      _route = [];
      _steps = [];
      _routeDistanceMeters = null;
      _routeDurationSeconds = null;
    });
    // Zoom kỹ vào điểm khi chọn: 18
    _mapController.move(LatLng(c.latitude, c.longitude), 18);
    _showPOISheet(c);
  }

  void _showPOISheet(Campaign c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(c.locationName, style: const TextStyle(fontSize: 13))),
              ],
            ),
            const SizedBox(height: 6),
            Text(c.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text('+${c.rewardPerCheckin} point', style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
                const SizedBox(width: 8),
                Text('Bán kính: ${c.radiusMeters.toInt()}m', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.alt_route),
                    // Đổi nhãn thành "Tuyến đường" (không nhắc OSRM/ORM)
                    label: const Text('Tuyến đường'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _buildRoute(c); // vẽ polyline + mở hướng dẫn
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Check-in'),
                    onPressed: () {
                      if (!mounted) return;
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: c)),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy tuyến đường + bước rẽ (đi bộ) và vẽ polyline ngay trong app
  Future<void> _buildRoute(Campaign c) async {
    if (widget.currentPosition == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có vị trí hiện tại')),
      );
      return;
    }

    final oLat = widget.currentPosition!.latitude;
    final oLon = widget.currentPosition!.longitude;
    final dLat = c.latitude;
    final dLon = c.longitude;

    final uri = Uri.parse(
      // backend routing miễn phí (ẩn tên ở UI)
      'https://router.project-osrm.org/route/v1/foot/$oLon,$oLat;$dLon,$dLat'
          '?overview=full&geometries=polyline&steps=true',
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final data = json.decode(res.body);

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) throw Exception('No route');
      final route0 = routes[0] as Map<String, dynamic>;

      final encoded = route0['geometry'] as String;
      final points = _decodePolyline(encoded, 5);

      final distance = (route0['distance'] as num).toDouble(); // m
      final duration = (route0['duration'] as num).toDouble(); // s

      final parsedSteps = <RouteStep>[];
      final legs = route0['legs'] as List?;
      if (legs != null && legs.isNotEmpty) {
        final leg0 = legs[0] as Map<String, dynamic>;
        final legSteps = leg0['steps'] as List?;
        if (legSteps != null) {
          for (final s in legSteps) {
            final step = s as Map<String, dynamic>;
            final man = step['maneuver'] as Map<String, dynamic>?;
            final loc = man?['location'] as List?;
            parsedSteps.add(
              RouteStep(
                distance: (step['distance'] as num?)?.toDouble() ?? 0,
                duration: (step['duration'] as num?)?.toDouble() ?? 0,
                name: step['name'] as String?,
                type: man?['type'] as String? ?? 'turn',
                modifier: man?['modifier'] as String?,
                location: (loc != null && loc.length == 2)
                    ? LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble())
                    : (points.isNotEmpty ? points.first : const LatLng(0, 0)),
              ),
            );
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _route = points;
        _routeDistanceMeters = distance;
        _routeDurationSeconds = duration;
        _steps = parsedSteps;
      });

      _fitRoute(points);
      _showRouteSheet();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tạo được tuyến đường: $e')),
      );
    }
  }

  // Fit camera theo tuyến đường (zoom vừa khung, hoặc fallback zoom 16)
  void _fitRoute(List<LatLng> pts) {
    if (pts.isEmpty) return;

    var minLat = pts.first.latitude, maxLat = pts.first.latitude;
    var minLon = pts.first.longitude, maxLon = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }
    final center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);

    // Nếu bạn dùng flutter_map >=7 có fitCamera, có thể dùng:
    // try {
    //   final bounds = LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
    //   _mapController.fitCamera(
    //     CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    //   );
    //   return;
    // } catch (_) {}
    // Fallback:
    _mapController.move(center, 16); // zoom 16 cho toàn tuyến
  }

  // ===== Helpers hiển thị =====
  String _fmtDistance(double m) =>
      m < 1000 ? '${m.toStringAsFixed(0)} m' : '${(m / 1000).toStringAsFixed(1)} km';

  String _fmtDuration(double s) {
    final minutes = (s / 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  String _buildInstruction(RouteStep st) {
    final mod = st.modifier?.toLowerCase();
    final nm = (st.name != null && st.name!.isNotEmpty) ? ' vào ${st.name}' : '';
    switch (st.type) {
      case 'depart': return 'Bắt đầu$nm';
      case 'arrive': return 'Đến nơi';
      case 'turn':
        if (mod == 'left') return 'Rẽ trái$nm';
        if (mod == 'right') return 'Rẽ phải$nm';
        if (mod == 'slight left') return 'Chếch trái$nm';
        if (mod == 'slight right') return 'Chếch phải$nm';
        if (mod == 'uturn') return 'Quay đầu$nm';
        return 'Rẽ$nm';
      case 'continue': return 'Đi thẳng$nm';
      case 'new name': return 'Tiếp tục$nm';
      case 'roundabout': return 'Vào vòng xuyến$nm';
      default: return 'Tiếp tục$nm';
    }
  }

  IconData _iconForStep(RouteStep st) {
    final mod = st.modifier?.toLowerCase();
    switch (st.type) {
      case 'arrive': return Icons.flag;
      case 'depart': return Icons.play_arrow;
      case 'turn':
        if (mod == 'left') return Icons.turn_left;
        if (mod == 'right') return Icons.turn_right;
        if (mod == 'slight left') return Icons.turn_slight_left;
        if (mod == 'slight right') return Icons.turn_slight_right;
        if (mod == 'uturn') return Icons.u_turn_left;
        return Icons.turn_sharp_right;
      case 'continue': return Icons.straight;
      case 'roundabout': return Icons.roundabout_left;
      default: return Icons.directions_walk;
    }
  }

  void _showRouteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4, // sheet cao hơn chút
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (ctx, scroll) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.directions_walk),
                    const SizedBox(width: 8),
                    Text(
                      _routeDistanceMeters != null && _routeDurationSeconds != null
                          ? '${_fmtDuration(_routeDurationSeconds!)} • ${_fmtDistance(_routeDistanceMeters!)}'
                          : 'Tuyến đường',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    controller: scroll,
                    itemCount: _steps.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final st = _steps[i];
                      return ListTile(
                        dense: true,
                        leading: Icon(_iconForStep(st)),
                        title: Text(_buildInstruction(st)),
                        subtitle: Text('${_fmtDistance(st.distance)} • ${_fmtDuration(st.duration)}'),
                        onTap: () => _mapController.move(st.location, 18), // zoom kỹ khi chạm bước
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // polyline decoder (precision 5/6) -> List<LatLng>
  List<LatLng> _decodePolyline(String encoded, int precision) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 1 ? (result >> 1) : ~(result >> 1);
      lat += dlat;

      shift = 0; result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 1 ? (result >> 1) : ~(result >> 1);
      lng += dlng;

      final factor = precision == 6 ? 1e6 : 1e5;
      points.add(LatLng(lat / factor, lng / factor));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = widget.currentPosition != null;
    final initial = _initialCenter();

    return Column(
      children: [
        // attribution + trạng thái
        Container(
          width: double.infinity,
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Expanded(
                child: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 12)),
              ),
              if (!hasLocation)
                TextButton(onPressed: widget.onRefreshLocation, child: const Text('Lấy vị trí')),
            ],
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initial,
              // Zoom mặc định to hơn khi vào Map
              initialZoom: hasLocation ? 17 : 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.authen.authen', // đổi theo applicationId của bạn
              ),

              // Vẽ tuyến
              PolylineLayer<Object>(
                polylines: _route.isEmpty
                    ? const <Polyline<Object>>[]
                    : <Polyline<Object>>[
                  Polyline<Object>(
                    points: _route,
                    color: Colors.blue,
                    strokeWidth: 5,
                  ),
                ],
              ),

              // Marker
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
        ),
      ],
    );
  }
}
