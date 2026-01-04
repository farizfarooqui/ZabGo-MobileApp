import 'package:demo/Controllers/OfferRideController.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Views/MapPickerScreen.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';

class OfferRideScreen extends StatelessWidget {
  OfferRideScreen({super.key});
  final controller = Get.put(OfferRideController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        title: const Text(
          "Offer a Ride",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: colorPrimary,
        elevation: 2,
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: SmallLoader(
                color: colorSecondary,
              ))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("📍 Route Information"),
                    _buildMapPreview(
                      context: context,
                      label: "Pickup Location",
                      color: Colors.green,
                      icon: Icons.location_on_rounded,
                      controller: controller.fromController,
                      onTap: () async {
                        final loc = await Get.to(() => const MapPickerScreen(
                            title: "Select Pickup Location"));
                        if (loc != null) {
                          controller.fromLatLng = loc;
                          controller.fromController.text =
                              "${loc.lat.toStringAsFixed(4)}, ${loc.lng.toStringAsFixed(4)}";
                        }
                      },
                    ),
                    _textField("Pickup Location Name",
                        controller.pickupNameController, TextInputType.name),

                    const SizedBox(height: 12),
                    _buildMapPreview(
                      // mapPath: 'assets/images/map_placeholder2.png',
                      context: context,
                      label: "Drop-off Location",
                      color: Colors.redAccent,
                      icon: Icons.flag_rounded,
                      controller: controller.toController,
                      onTap: () async {
                        final loc = await Get.to(() => const MapPickerScreen(
                            title: "Select Drop Location"));
                        if (loc != null) {
                          controller.toLatLng = loc;
                          controller.toController.text =
                              "${loc.lat.toStringAsFixed(4)}, ${loc.lng.toStringAsFixed(4)}";
                        }
                      },
                    ),
                    _textField("Drop-off Location Name",
                        controller.dropOffNameController, TextInputType.name),

                    const SizedBox(height: 16),

                    // 💰 Section: Ride Details
                    _sectionTitle("🚘 Ride Details"),
                    _textField("Fare Price (PKR)", controller.fareController,
                        TextInputType.number),
                    _textField("Car Name", controller.carNameController),
                    _textField("Car Color", controller.carColorController),
                    _textField(
                        "Car Number Plate", controller.carNumberController),
                    _textField("Total Seats", controller.totalSeatsController,
                        TextInputType.number, 6),
                    const SizedBox(height: 16),

                    // ⏰ Section: Timing
                    _sectionTitle("🕒 Schedule"),
                    _dateTimePicker(
                      context,
                      label: "Departure Time",
                      controller: controller.departureTimeController,
                    ),
                    _dateTimePicker(
                      context,
                      label: "Estimated Arrival Time",
                      controller: controller.estimatedArrivalController,
                    ),
                    _sectionTitle("Contact no: (Optional)"),

                    _textField("Phone number", controller.contactNoController,
                        TextInputType.phone),
                    const SizedBox(height: 30),

                    // ✅ Post Ride Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.postRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor: colorPrimary.withOpacity(0.4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Post Ride",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorSecondary,
          ),
        ),
      );
  Widget _textField(
    String label,
    TextEditingController ctrl, [
    TextInputType? type,
    int? maxValue, // sirf number fields ke liye
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: type ?? TextInputType.text,
        inputFormatters: [
          // Agar field type number ho to filter aur maxValue lagao
          if (type == TextInputType.number) ...[
            FilteringTextInputFormatter.digitsOnly,
            if (maxValue != null)
              TextInputFormatter.withFunction((oldValue, newValue) {
                if (newValue.text.isEmpty) return newValue;

                final value = int.tryParse(newValue.text) ?? 0;

                if (value > maxValue) {
                  return oldValue; // zyada hua to old value wapis
                }
                return newValue;
              }),
          ]
        ],
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.edit, color: colorSecondary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    final hasLocation = controller.text.isNotEmpty;

    // Safe parsing lat/lng from controller text if available
    double? lat, lng;
    if (hasLocation && controller.text.contains(',')) {
      try {
        final parts = controller.text.split(',');
        lat = double.tryParse(parts[0].trim());
        lng = double.tryParse(parts[1].trim());
      } catch (e) {
        lat = null;
        lng = null;
      }
    }

    final defaultCenter = LatLng(25.3960, 68.3578);
    final locationPoint =
        (lat != null && lng != null) ? LatLng(lat, lng) : defaultCenter;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // --- Map Preview ---
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  initialCenter: locationPoint,
                  initialZoom: hasLocation ? 14 : 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.demo',
                  ),
                  if (hasLocation)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: locationPoint,
                          width: 40,
                          height: 40,
                          child: Icon(icon, color: color, size: 36),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // --- Gradient Overlay ---
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // --- Text / Label ---
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasLocation ? controller.text : "Tap to select $label",
                        style: TextStyle(
                          color: hasLocation ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimePicker(BuildContext context,
      {required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (date == null) return;

          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time == null) return;

          final combined = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          controller.text = combined.toString().substring(0, 16);
        },
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(Icons.access_time_rounded,
                  color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.grey.withOpacity(0.4), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
