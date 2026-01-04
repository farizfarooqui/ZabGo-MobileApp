import 'package:demo/Controllers/OfferRideController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  final String title;
  const MapPickerScreen({super.key, required this.title});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) return;
    }

    final pos = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(pos.latitude, pos.longitude), 14);
    setState(() => _pickedLocation = LatLng(pos.latitude, pos.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(25.379119, 68.336353),
              initialZoom: 14,
              onTap: (tapPos, point) => setState(() => _pickedLocation = point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_pickedLocation != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _pickedLocation!,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 40),
                  )
                ])
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Set Location"),
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      final data = LatLngData(
                          _pickedLocation!.latitude, _pickedLocation!.longitude);
                      Get.back(result: data);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
