import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MiniMapWidget extends StatelessWidget {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;

  const MiniMapWidget({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
  });

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(pickupLat, pickupLng);
    final dropoff = LatLng(dropoffLat, dropoffLng);
    final bounds = LatLngBounds(pickup, dropoff);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: FlutterMap(
          options: MapOptions(
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(40),
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.demo',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: pickup,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_pin,
                      color: Colors.green, size: 36),
                ),
                Marker(
                  point: dropoff,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.flag_rounded,
                      color: Colors.red, size: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
