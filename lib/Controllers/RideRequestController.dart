import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Utils/Utils.dart';

class RideRequestController extends GetxController {
  final supabase = Supabase.instance.client;

  var isRequesting = false.obs;
  var isLoading = false.obs;
  var rideRequests = <Map<String, dynamic>>[].obs;
  var myRequests = <Map<String, dynamic>>[].obs;

  final messageController = TextEditingController();

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  /// Send seat request with specific seat numbers
  Future<void> sendSeatRequest({
    required String rideId,
    required List<String> seatNumbers,
    String? message,
  }) async {
    if (seatNumbers.isEmpty) {
      Utils.showError("No Seats", "Please select at least one seat.");
      return;
    }

    try {
      isRequesting(true);

      final user = supabase.auth.currentUser;
      if (user == null) {
        Utils.showError("Error", "You must be logged in.");
        return;
      }

      // Check if user already has a pending request for this ride
      final existingRequest = await supabase
          .from('ride_requests')
          .select()
          .eq('ride_id', rideId)
          .eq('requested_by', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingRequest != null) {
        Utils.showError("Request Exists", "You already have a pending request for this ride.");
        return;
      }

      await supabase.from('ride_requests').insert({
        'ride_id': rideId,
        'seat_numbers': seatNumbers,
        'requested_by': user.id,
        'message': message?.trim() ?? '',
        'status': 'pending',
      });

      Utils.showSuccess("Success!", message: "Seat request sent successfully.");
      messageController.clear();

    } catch (e) {
      log("Seat request error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isRequesting(false);
    }
  }

  /// Fetch all ride requests for a specific ride (for drivers)
  Future<void> fetchRideRequests(String rideId) async {
    try {
      isLoading(true);

      final response = await supabase
          .from('ride_requests')
          .select('''
            *,
            users!ride_requests_requested_by_fkey(name, department, year)
          ''')
          .eq('ride_id', rideId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      rideRequests.value = List<Map<String, dynamic>>.from(response);

    } catch (e) {
      log("Fetch ride requests error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Fetch user's own ride requests
  Future<void> fetchMyRequests() async {
    try {
      isLoading(true);

      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('ride_requests')
          .select('''
            *,
            rides:ride_id(from_location, to_location, departure_time, fare_price)
          ''')
          .eq('requested_by', user.id)
          .order('created_at', ascending: false);

      myRequests.value = List<Map<String, dynamic>>.from(response);

    } catch (e) {
      log("Fetch my requests error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Accept a ride request (for drivers)
  Future<void> acceptRideRequest(String requestId, String rideId, List<String> seatNumbers) async {
    try {
      isLoading(true);

      final user = supabase.auth.currentUser;
      if (user == null) {
        Utils.showError("Error", "You must be logged in.");
        return;
      }

      // First, get current ride data to check seat availability
      final rideResponse = await supabase
          .from('rides')
          .select('seats, car_guy_id')
          .eq('id', rideId)
          .single();

      // Verify the current user is the ride owner
      if (rideResponse['car_guy_id'] != user.id) {
        Utils.showError("Error", "You can only accept requests for your own rides.");
        return;
      }

      final currentSeats = Map<String, dynamic>.from(rideResponse['seats']);

      // Check if any requested seat is already booked
      for (final seatNumber in seatNumbers) {
        final seatData = currentSeats[seatNumber];
        if (seatData != null && seatData['isBooked'] == true) {
          Utils.showError("Seat Unavailable", "Seat $seatNumber is already booked.");
          return;
        }
      }

      // Get user info from the request to update seat data with gender
      final requestResponse = await supabase
          .from('ride_requests')
          .select('''
            *,
            users:requested_by(name, department, year)
          ''')
          .eq('id', requestId)
          .single();

      final passengerData = requestResponse['users'];
      final requestedBy = requestResponse['requested_by'];

      // Get passenger's gender from users table (assuming you have gender field)
      final passengerGenderResponse = await supabase
          .from('users')
          .select('name')
          .eq('id', requestedBy)
          .single();

      // Update seat data with booking info and gender
      for (final seatNumber in seatNumbers) {
        currentSeats[seatNumber] = {
          "isBooked": true,
          "bookedBy": requestedBy,
          "gender": "unspecified", // You can implement gender detection or ask during signup
        };
      }

      // Start a transaction-like operation
      // 1. Update the request status
      await supabase
          .from('ride_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);

      // 2. Update the ride seats
      await supabase
          .from('rides')
          .update({'seats': currentSeats})
          .eq('id', rideId);

      Utils.showSuccess("Success!", message: "Request accepted! Seats booked successfully.");

      // Refresh the requests list
      await fetchRideRequests(rideId);

    } catch (e) {
      log("Accept request error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Reject a ride request (for drivers)
  Future<void> rejectRideRequest(String requestId, String rideId) async {
    try {
      isLoading(true);

      await supabase
          .from('ride_requests')
          .update({'status': 'rejected'})
          .eq('id', requestId);

      Utils.showSuccess("Opps", message: "Request rejected.");
      await fetchRideRequests(rideId);

    } catch (e) {
      log("Reject request error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Listen to real-time changes in ride requests
  void listenToRideRequestChanges(String rideId) {
    final channel = supabase.channel('ride_requests_$rideId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'ride_requests',
      callback: (payload) {
        if (payload.newRecord['ride_id'] == rideId) {
          fetchRideRequests(rideId); // Refresh the list
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'ride_requests',
      callback: (payload) {
        if (payload.newRecord['ride_id'] == rideId) {
          fetchRideRequests(rideId); // Refresh the list
        }
      },
    );

    channel.subscribe();
  }
}
