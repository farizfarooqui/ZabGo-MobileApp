import 'package:demo/Controllers/SearchRideController.dart';
import 'package:demo/Views/RideDetailScreen.dart';
import 'package:demo/Views/RideRequestsScreen.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Widgets/MiniMapWidget.dart';

class AvailableRidesScreen extends StatelessWidget {
  const AvailableRidesScreen({super.key});

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
    final controller = Get.put(SearchRideController());
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          'Available Rides',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SmallLoader(color: colorSecondary),
          );
        }

        if (controller.rides.isEmpty) {
          return Center(
            child: Text(
              "🚗 No rides available at the moment.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(width * 0.03),
          itemCount: controller.rides.length,
          itemBuilder: (context, index) {
            final ride = controller.rides[index];
            final currentUser = Supabase.instance.client.auth.currentUser;
            final isMyRide =
                currentUser != null && ride['car_guy_id'] == currentUser.id;

            final seats = Map<String, dynamic>.from(ride['seats']);
            final bookedSeats =
                seats.values.where((seat) => seat['isBooked'] == true).length;
            final remainingSeats = ride['total_seats'] - bookedSeats;

            final gender = ride['gender']?.toString().toLowerCase();
            final avatarImage = gender == 'female'
                ? const AssetImage('assets/images/female_avatar.png')
                : const AssetImage('assets/images/male_avatar.png');

            return GestureDetector(
              onTap: () => Get.to(() => RideDetailScreen(rideId: ride['id'])),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: height * 0.008),
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
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Driver Info Section ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: avatarImage,
                        ),
                        SizedBox(width: width * 0.025),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ride['name'] ?? "Szabist student",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (isMyRide)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.02,
                                        vertical: height * 0.004,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "MY RIDE",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    ride['gender'] ?? "",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    "Dept: ${ride['department']?.toUpperCase() ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Semester: ${ride['semester'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    "Student ID: ${ride['student_id'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (ride['from_lat'] != null && ride['from_lng'] != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0.01),
                        child: MiniMapWidget(
                          pickupLat: ride['from_lat'],
                          pickupLng: ride['from_lng'],
                          dropoffLat: ride['to_lat'],
                          dropoffLng: ride['to_lng'],
                        ),
                      ),

                    SizedBox(height: height * 0.008),

                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.green, size: height * 0.022),
                        SizedBox(width: width * 0.015),
                        Expanded(
                          child: Text(
                            ride['pickup_name'] ?? "Pickup not set",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_forward,
                            color: Colors.grey, size: height * 0.02),
                        SizedBox(width: width * 0.015),
                        Expanded(
                          child: Text(
                            ride['dropoff_name'] ?? "Drop-off not set",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.008),

                    Text(
                      'Departure: ${formatDateTime(ride['departure_time'])}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Estimated arrival: ${formatDateTime(ride['estimated_arrival_time'])}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                color: Colors.blueAccent, size: height * 0.02),
                            SizedBox(width: width * 0.015),
                            Text(
                              "${ride['ride_name']} (${ride['ride_color']})",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: height * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: remainingSeats > 0
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                remainingSeats > 0
                                    ? Icons.event_seat
                                    : Icons.close,
                                size: height * 0.018,
                                color: remainingSeats > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              SizedBox(width: width * 0.01),
                              Text(
                                remainingSeats > 0
                                    ? "$remainingSeats seats left"
                                    : "Full",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: remainingSeats > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    Text(
                      "Rs.${ride['fare_price']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    if (isMyRide) ...[
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => RideRequestsScreen(
                                  rideId: ride['id'],
                                  rideTitle:
                                      "${ride['from_location']} → ${ride['to_location']}",
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorSecondary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: height * 0.008),
                            minimumSize: Size(0, 0),
                            elevation: 2,
                          ),
                          icon:
                              Icon(Icons.manage_accounts, size: height * 0.02),
                          label: Text(
                            "Manage Requests",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
