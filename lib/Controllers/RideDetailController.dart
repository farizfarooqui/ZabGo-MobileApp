import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo/Utils/Utils.dart';

class RideDetailController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var ride = {}.obs;
  var selectedSeats = <String>{}.obs;
  final TextEditingController messageController = TextEditingController();

  final String rideId;

  RideDetailController(this.rideId);

  @override
  void onInit() {
    super.onInit();
    fetchRideDetails();
    listenToRideChanges();
  }

  Color getSeatColor(Map<String, dynamic> seat, bool isSelected) {
    final isBooked = seat['isBooked'] ?? false;
    final gender = seat['gender'];

    if (isSelected) {
      return Colors.green.shade400;
    }

    if (isBooked) {
      if (gender == 'Female') {
        return Colors.pink.shade700;
      } else if (gender == 'Male') {
        return Colors.blue.shade700;
      } else {
        return Colors.grey.shade600;
      }
    }
    return Colors.grey.shade300;
  }

  Future<void> fetchRideDetails() async {
    try {
      isLoading(true);
      final response =
          await supabase.from('rides').select().eq('id', rideId).single();

      ride.value = response;
    } catch (e) {
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ✅ NEW realtime listener syntax
  void listenToRideChanges() {
    final channel = supabase.channel('rides_changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'rides',
      callback: (payload) {
        if (payload.newRecord['id'] == rideId) {
          ride.value = payload.newRecord;
        }
      },
    );

    channel.subscribe();
  }

  void toggleSeatSelection(String seatNumber) {
    if (selectedSeats.contains(seatNumber)) {
      selectedSeats.remove(seatNumber);
    } else {
      selectedSeats.add(seatNumber);
    }
  }

  /// Check if current user is the ride owner
  bool get isRideOwner {
    final user = supabase.auth.currentUser;
    if (user == null || ride.isEmpty) return false;
    return ride['car_guy_id'] == user.id;
  }

  /// Check if user already has a pending request for this ride
  Future<bool> hasExistingRequest() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final existingRequest = await supabase
          .from('ride_requests')
          .select()
          .eq('ride_id', rideId)
          .eq('requested_by', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      return existingRequest != null;
    } catch (e) {
      log("Check existing request error: $e");
      return false;
    }
  }

  /// Send seat request instead of direct booking
  Future<void> sendSeatRequest(String? message) async {
    if (selectedSeats.isEmpty) {
      Utils.showError("No Seats", "Please select at least one seat.");
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      Utils.showError("Error", "You must be logged in.");
      return;
    }

    // Check if user is trying to request their own ride
    if (isRideOwner) {
      Utils.showError("Error", "You cannot request seats for your own ride.");
      return;
    }

    // Check if user already has a pending request
    if (await hasExistingRequest()) {
      Utils.showError("Request Exists",
          "You already have a pending request for this ride.");
      return;
    }

    try {
      isLoading(true);
      // Check if selected seats are still available
      final currentSeats = Map<String, dynamic>.from(ride['seats']);
      for (final seat in selectedSeats) {
        final seatData = currentSeats[seat];
        if (seatData['isBooked'] == true) {
          Utils.showError("Seat Unavailable", "Seat $seat is already booked.");
          selectedSeats.clear();
          return;
        }
      }
      await supabase.from('ride_requests').insert({
        'ride_id': rideId,
        'seat_numbers': selectedSeats.toList(),
        'requested_by': user.id,
        'message': message?.trim() ?? '',
        'status': 'pending',
      });

      // Also create a chat message if there's a message
      if (message != null && message.trim().isNotEmpty) {
        final rideOwnerId = ride['car_guy_id'];
        if (rideOwnerId != null && rideOwnerId != user.id) {
          try {
            final rideInfo =
                "${ride['from_location']} → ${ride['to_location']}";
            final chatMessage =
                "🚗 Ride Request: $rideInfo\n\nSeats: ${selectedSeats.join(', ')}\n\nMessage: ${message.trim()}";

            await supabase.from('messages').insert({
              'sender_id': user.id,
              'receiver_id': rideOwnerId,
              'content': chatMessage,
              'created_at': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            log("Failed to create chat message: $e");
            // Don't fail the request if chat message fails
          }
        }
      }

      Utils.showSuccess("Success!", message: "Seat request sent successfully.");
      selectedSeats.clear();
    } catch (e) {
      log("Seat request error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteRide() async {
    try {
      isLoading(true);
      await supabase.from('rides').delete().eq('id', rideId);
      Get.close(2);
      Get.snackbar("Ride Deleted", "Your ride has been successfully removed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete ride: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}
