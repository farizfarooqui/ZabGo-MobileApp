import 'package:demo/Controllers/ChatController.dart';
import 'package:demo/Controllers/MyRidesController.dart';
import 'package:demo/Views/RideDetailScreen.dart';
import 'package:demo/Views/ChatScreen.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

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
    final controller = Get.put(MyRidesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'My Rides',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorPrimary,
        elevation: 0,
        actions: [
          Obx(() => controller.getPendingRequestsCount() > 0
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () => controller.changeTab(2),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${controller.getPendingRequestsCount()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: Column(
        children: [
          // Tab Selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _tabButton("Offered", 0, controller),
                _tabButton("Joined", 1, controller),
                _tabButton("Requests", 2, controller),
              ],
            ),
          ),

          // Content based on selected tab
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: SmallLoader(color: colorSecondary));
              }

              switch (controller.selectedTabIndex.value) {
                case 0:
                  return _buildOfferedRides(controller);
                case 1:
                  return _buildJoinedRides(controller);
                case 2:
                  return _buildRideRequests(controller);
                default:
                  return _buildOfferedRides(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index, MyRidesController controller) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedTabIndex.value == index;
        final requestCount =
            index == 2 ? controller.getPendingRequestsCount() : 0;

        return GestureDetector(
          onTap: () => controller.changeTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? colorSecondary : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (requestCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$requestCount',
                      style: TextStyle(
                        color: isSelected ? colorSecondary : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOfferedRides(MyRidesController controller) {
    final RefreshController refreshController =
        RefreshController(initialRefresh: false);

    void _onRefresh() async {
      await controller.fetchMyRides();
      refreshController.refreshCompleted();
    }

    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: _onRefresh,
      header: const WaterDropHeader(
              waterDropColor: colorSecondary,
              idleIcon:
                  Icon(Icons.autorenew_rounded, size: 16, color: Colors.white),
            ),
      child: Obx(() {
        if (controller.myOfferedRides.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.drive_eta, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No rides offered yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Create a ride from the Home tab",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myOfferedRides.length,
          itemBuilder: (context, index) {
            final ride = controller.myOfferedRides[index];
            final availableSeats = controller.getAvailableSeats(ride);
            final bookedSeats = controller.getBookedSeats(ride);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.drive_eta, color: colorSecondary),
                    ),
                    title: Text(
                      "${ride['pickup_name']} → ${ride['dropoff_name']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${formatDateTime(ride['departure_time'])}"),
                        Text("Rs.${ride['fare_price']} • ${ride['ride_name']}"),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$availableSeats/${ride['total_seats']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          "seats left",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () =>
                        Get.to(() => RideDetailScreen(rideId: ride['id'])),
                  ),
                  if (bookedSeats > 0) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.people,
                              color: Colors.green.shade700, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "$bookedSeats passenger${bookedSeats > 1 ? 's' : ''} booked",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildJoinedRides(MyRidesController controller) {
    final RefreshController refreshController =
        RefreshController(initialRefresh: false);

    void _onRefresh() async {
      await controller.fetchMyJoinedRides();
      refreshController.refreshCompleted();
    }

    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: _onRefresh,
      header: const WaterDropHeader(
              waterDropColor: colorSecondary,
              idleIcon:
                  Icon(Icons.autorenew_rounded, size: 16, color: Colors.white),
            ),
      child: Obx(() {
        if (controller.myJoinedRides.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_seat, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No rides joined yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Search and join rides from the Home tab",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myJoinedRides.length,
          itemBuilder: (context, index) {
            final ride = controller.myJoinedRides[index];
            final mySeats = controller.getMyBookedSeats(ride);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.event_seat, color: Colors.blue),
                ),
                title: Text(
                  "${ride['pickup_name']} → ${ride['dropoff_name']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${formatDateTime(ride['departure_time'])}"),
                    Text("Rs.${ride['fare_price']} • ${ride['ride_name']}"),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Seat${mySeats.length > 1 ? 's' : ''} ${mySeats.join(', ')}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () => Get.to(() => RideDetailScreen(rideId: ride['id'])),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildRideRequests(MyRidesController controller) {
    final RefreshController refreshController =
        RefreshController(initialRefresh: false);

    void _onRefresh() async {
      await controller.fetchAllRideRequests();
      refreshController.refreshCompleted();
    }

    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: _onRefresh,
      header: const WaterDropHeader(
              waterDropColor: colorSecondary,
              idleIcon:
                  Icon(Icons.autorenew_rounded, size: 16, color: Colors.white),
            ),
      child: Obx(() {
        if (controller.allRideRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No pending requests",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Requests from passengers will appear here",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.allRideRequests.length,
          itemBuilder: (context, index) {
            final request = controller.allRideRequests[index];
            final userData = request['users'];
            final rideData = request['rides'];
            final seatNumbers =
                List<String>.from(request['seat_numbers'] ?? []);

            if (userData == null || rideData == null) {
              return const SizedBox.shrink();
            }

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
                          (userData['name'] ?? 'U')[0].toUpperCase(),
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
                              userData['name'] ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              "${userData['department'] ?? 'Unknown'} • Year ${userData['year'] ?? 'N/A'}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Get.put(ChatController());
                          Get.to(() => ChatScreen(chatUser: userData));
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        tooltip: "Send Message",
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Ride Info
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${rideData['pickup_name'] ?? 'Unknown'} → ${rideData['dropoff_name'] ?? 'Unknown'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.event_seat,
                          color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Seats: ${seatNumbers.join(', ')}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  if (request['message'] != null &&
                      request['message'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "\"${request['message']}\"",
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text("Reject Request"),
                                content: Text(
                                  "Reject ${userData['name'] ?? 'this user'}'s request for seat(s) ${seatNumbers.join(', ')}?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: greyLightColor),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
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
                              await controller.rejectRideRequest(request['id']);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close, size: 16),
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
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text("Accept Request"),
                                content: Text(
                                  "Accept ${userData['name'] ?? 'this user'}'s request for seat(s) ${seatNumbers.join(', ')}?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: greyLightColor),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
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
                              await controller.acceptRideRequest(request);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade500,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text(
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
        );
      }),
    );
  }
}
