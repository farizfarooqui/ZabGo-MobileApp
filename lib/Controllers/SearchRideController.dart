import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRideController extends GetxController {
  final supabase = Supabase.instance.client;

  var rides = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRides();
    listenForRideUpdates();
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.administrativeArea}";
      } else {
        return "Unknown location";
      }
    } catch (e) {
      return "Error getting location";
    }
  }

  Future<void> fetchRides() async {
    try {
      isLoading(true);

      // final response = await supabase
      //     .from('rides')
      //     .select('*')
      //     .eq('status', 'active')
      //     .order('created_at', ascending: false);


      final now = DateTime.now().toUtc();
      final response = await supabase
          .from('rides')
          .select('*')
          .eq('status', 'active')
          .gte('departure_time', now.toIso8601String())
          .order('departure_time', ascending: true);

      rides.value = response;
    } catch (e) {
      log("Fetch rides error: $e");
    } finally {
      isLoading(false);
    }
  }

  void listenForRideUpdates() {
    supabase
        .channel('public:rides')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'rides',
          callback: (payload) {
            log("New ride added: ${payload.newRecord}");
            if (payload.newRecord['status'] == 'active') {
              rides.insert(0, payload.newRecord);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'rides',
          callback: (payload) {
            log("Ride updated: ${payload.newRecord}");
            final index =
                rides.indexWhere((r) => r['id'] == payload.newRecord['id']);
            if (index != -1) {
              // Update the ride with new seat data (this includes real-time seat booking updates)
              rides[index] = payload.newRecord;

              // Force UI update for seat color changes
              rides.refresh();
            }
          },
        )
        .subscribe();
  }

  /// Get available seats count for a ride
  int getAvailableSeats(Map<String, dynamic> ride) {
    final seats = Map<String, dynamic>.from(ride['seats'] ?? {});
    final totalSeats = ride['total_seats'] ?? 0;
    final bookedSeats = seats.values.where((s) => s['isBooked'] == true).length;
    return totalSeats - bookedSeats;
  }

  /// Get seat color for display in ride list
  Color getSeatStatusColor(int availableSeats, int totalSeats) {
    final bookedSeats = totalSeats - availableSeats;
    final percentage = bookedSeats / totalSeats;

    if (percentage >= 1.0) {
      return Colors.red; // Fully booked
    } else if (percentage >= 0.7) {
      return Colors.orange; // Almost full
    } else if (percentage >= 0.3) {
      return Colors.yellow; // Half full
    } else {
      return Colors.green; // Plenty of seats
    }
  }
}
