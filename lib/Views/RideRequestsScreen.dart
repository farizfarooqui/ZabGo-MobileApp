import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo/Controllers/RideRequestController.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:intl/intl.dart';

class RideRequestsScreen extends StatelessWidget {
  final String rideId;
  final String rideTitle;

  const RideRequestsScreen({
    super.key,
    required this.rideId,
    required this.rideTitle,
  });

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
    final controller = Get.put(RideRequestController());

    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRideRequests(rideId);
      controller.listenToRideRequestChanges(rideId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          'Ride Requests',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: SmallLoader(color: colorSecondary));
        }

        if (controller.rideRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  "No pending requests",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Passengers will see their requests here",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchRideRequests(rideId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.rideRequests.length,
            itemBuilder: (context, index) {
              final request = controller.rideRequests[index];
              final userData = request['users'];
              final seatNumbers =
                  List<String>.from(request['seat_numbers'] ?? []);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    // Passenger Info Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorSecondary,
                          child: Text(
                            userData['name'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${userData['department']} • Year ${userData['year']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            request['status'].toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Requested Seats
                    Row(
                      children: [
                        const Icon(
                          Icons.event_seat,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Requested Seats: ${seatNumbers.join(', ')}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Message (if provided)
                    if (request['message'] != null &&
                        request['message'].toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Message:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              request['message'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Request Time
                    Text(
                      "Requested ${formatDateTime(request['created_at'])}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Reject Request"),
                                  content: Text(
                                    "Are you sure you want to reject ${userData['name']}'s request for seat(s) ${seatNumbers.join(', ')}?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: greyLightColor),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        "Reject",
                                        style: TextStyle(color: colorPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await controller.rejectRideRequest(
                                  request['id'],
                                  rideId,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text(
                              "Reject",
                              style: TextStyle(color: colorPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Accept Request"),
                                  content: Text(
                                    "Accept ${userData['name']}'s request for seat(s) ${seatNumbers.join(', ')}?\n\nThis will book the seats for the passenger.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: greyLightColor),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text(
                                        "Accept",
                                        style: TextStyle(color: colorPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await controller.acceptRideRequest(
                                  request['id'],
                                  rideId,
                                  seatNumbers,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade500,
                              foregroundColor: Colors.white,
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.check, size: 18),
                            label:const Text(
                                        "Accept",
                                        style: TextStyle(color: colorPrimary),
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
