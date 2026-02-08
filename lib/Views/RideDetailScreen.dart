import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Controllers/RideDetailController.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class RideDetailScreen extends StatelessWidget {
  final String rideId;

  const RideDetailScreen({super.key, required this.rideId});

  String formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('MMM d, hh:mm a').format(dt);
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RideDetailController(rideId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Ride Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: SmallLoader(color: colorSecondary));
        }

        if (controller.ride.isEmpty) {
          return const Center(child: Text("Ride not found"));
        }

        final ride = controller.ride;
        final seats = Map<String, dynamic>.from(ride['seats'] ?? {});
        final totalSeats = ride['total_seats'] ?? 0;
        final bookedSeats =
            seats.values.where((s) => s['isBooked'] == true).length;
        final remainingSeats = totalSeats - bookedSeats;

        final pickupLat = ride['from_lat'] ?? 24.8607;
        final pickupLng = ride['from_lng'] ?? 67.0011;
        final dropoffLat = ride['to_lat'] ?? 24.9200;
        final dropoffLng = ride['to_lng'] ?? 67.1000;

        final pickup = LatLng(pickupLat, pickupLng);
        final dropoff = LatLng(dropoffLat, dropoffLng);
        final bounds = LatLngBounds(pickup, dropoff);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Ride Header ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${ride['ride_name']} (${ride['ride_color']})",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        buildViewIDButton(ride['front_id_url']),
                      ],
                    ),
                    Text("Car Number: ${ride['ride_number']}",
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13)),
                    if (ride['number'] != null &&
                        ride['number'].toString().isNotEmpty) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: ride['number'].toString()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone number copied!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_rounded,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              ride['number'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.copy,
                                size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 220,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCameraFit: CameraFit.bounds(
                              bounds: bounds,
                              padding: const EdgeInsets.all(60),
                            ),
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ride['pickup_name'],
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ride['dropoff_name'],
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Departure: ${formatDateTime(ride['departure_time'])}",
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    Text(
                      "Fare: Rs.${ride['fare_price']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Seat Map ---
              Text(
                "Available Seats ($remainingSeats remaining)",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: seats.length,
                itemBuilder: (context, index) {
                  final seatNum = seats.keys.elementAt(index);
                  final seat = seats[seatNum];
                  final isBooked = seat['isBooked'] ?? false;

                  // Wrap each seat in Obx to rebuild when selection changes
                  return Obx(() {
                    final isSelected =
                        controller.selectedSeats.contains(seatNum);

                    final bgColor = controller.getSeatColor(seat, isSelected);

                    return GestureDetector(
                      onTap: isBooked
                          ? null
                          : () => controller.toggleSeatSelection(seatNum),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green.shade800
                                : Colors.grey.shade400,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 6,
                              )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Seat $seatNum",
                          style: TextStyle(
                            color: isBooked ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),

              const SizedBox(height: 25),

              // --- Seat Legend ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Seat Legend:",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _legendItem(Colors.grey.shade300, "Available"),
                        _legendItem(Colors.green, "Selected"),
                        _legendItem(Colors.blue.shade700, "Male"),
                        _legendItem(Colors.pink.shade700, "Female"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              if (!controller.isRideOwner) ...[
                // Message Input
                TextField(
                  controller: controller.messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Any special requests or information...",
                    hintStyle:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    filled: true,
                    fillColor:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                            Colors.grey.shade100,
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade400, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Send Request Button
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary, // theme-aware
                      padding: const EdgeInsets.symmetric(
                          horizontal: 38, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                    icon: Icon(Icons.send,
                        color: Theme.of(context).colorScheme.onSecondary),
                    label: Text(
                      "Send Seat Request",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    onPressed: () async {
                      if (controller.selectedSeats.isEmpty) {
                        Get.snackbar(
                          "No Seat Selected",
                          "Please select at least one seat before sending request.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      if (controller.messageController.text.trim().isEmpty) {
                        Get.snackbar(
                          "Message Required",
                          "Please type a message before sending request.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      // Show Confirmation Dialog
                      final send = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text("Send Seat Request"),
                          content: Text(
                            "Selected seat(s): ${controller.selectedSeats.join(', ')}\n\nMessage:\n${controller.messageController.text}",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false), // Cancel
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context, true), // Send
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Send",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (send == true) {
                        controller
                            .sendSeatRequest(controller.messageController.text);
                      }
                    },
                  ),
                ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 30),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: Colors.blue.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.directions_car_rounded,
                            color: Colors.blue.shade700, size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This is your ride",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You can manage or delete your ride below if it's no longer available.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning_rounded,
                                        color: Colors.redAccent, size: 26),
                                    SizedBox(width: 10),
                                    Text(
                                      "Delete Ride",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  "Are you sure you want to delete this ride? This action cannot be undone.",
                                  style: TextStyle(fontSize: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: colorSecondary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await controller.deleteRide();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white),
                          label: const Text(
                            "Delete This Ride",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget buildViewIDButton(String? frontIdUrl) {
    if (frontIdUrl == null || frontIdUrl.isEmpty) {
      return const SizedBox();
    }

    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        label: const Text(
          "View ID",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10),
        ),
        onPressed: () {
          Get.dialog(
            Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: InteractiveViewer(
                          clipBehavior: Clip.none,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              frontIdUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const SmallLoader(color: colorSecondary);
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  "Failed to load image",
                                  style: TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
