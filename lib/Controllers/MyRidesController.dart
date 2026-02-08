import 'dart:developer';
import 'package:demo/Service/Internet.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Utils/Utils.dart';

class MyRidesController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var myOfferedRides = <Map<String, dynamic>>[].obs;
  var myJoinedRides = <Map<String, dynamic>>[].obs;
  var allRideRequests = <Map<String, dynamic>>[].obs;
  var selectedTabIndex = 0.obs; // 0 = Offered, 1 = Joined, 2 = Requests

  late final RealtimeChannel _channel;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    listenToRideRequestChanges();
  }

  @override
  void onClose() {
    myOfferedRides.clear();
    myJoinedRides.clear();
    allRideRequests.clear();
    supabase.removeChannel(_channel);
    super.onClose();
  }

  Future<void> _initializeData() async {
    final isOnline = await InternetService.hasInternet();
    if (!isOnline) {
      Utils.showError(
          'No Internet', 'Please connect to the internet and try again.');
      return;
    }
    await Future.wait([
      fetchMyRides(),
      fetchMyJoinedRides(),
      fetchAllRideRequests(),
    ]);
  }

  /// Fetch rides offered by current user
  Future<void> fetchMyRides() async {
    try {
      isLoading(true);
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('rides')
          .select('*')
          .eq('car_guy_id', user.id)
          .order('created_at', ascending: false);

      myOfferedRides.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log("Fetch my rides error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Fetch rides where current user has booked seats
  Future<void> fetchMyJoinedRides() async {
    try {
      isLoading(true);
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Get all rides where user has booked seats
      final response = await supabase
          .from('rides')
          .select('*')
          .neq('car_guy_id', user.id)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      // Filter rides where user has booked seats
      final joinedRides = <Map<String, dynamic>>[];
      for (final ride in response) {
        final seats = Map<String, dynamic>.from(ride['seats'] ?? {});
        bool hasBookedSeat = false;

        for (final seatData in seats.values) {
          if (seatData['bookedBy'] == user.id) {
            hasBookedSeat = true;
            break;
          }
        }

        if (hasBookedSeat) {
          joinedRides.add(ride);
        }
      }

      myJoinedRides.value = joinedRides;
    } catch (e) {
      log("Fetch joined rides error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Fetch all ride requests for user's offered rides
  Future<void> fetchAllRideRequests() async {
    try {
      isLoading(true);
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Always use the fallback method for more reliable filtering
      await fetchAllRideRequestsFallback();
    } catch (e) {
      log("Fetch all ride requests error: $e");
      allRideRequests.value = [];
    }
  }

  /// Fallback method to fetch ride requests without complex joins
  Future<void> fetchAllRideRequestsFallback() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // First get user's rides
      final userRides =
          await supabase.from('rides').select('id').eq('car_guy_id', user.id);

      log("User ${user.id} has ${userRides.length} rides");

      if (userRides.isEmpty) {
        log("No rides found for user, clearing requests");
        allRideRequests.value = [];
        return;
      }

      final rideIds = userRides.map((ride) => ride['id']).toList();

      // Get requests for these rides
      final requests = await supabase
          .from('ride_requests')
          .select('*')
          .inFilter('ride_id', rideIds)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      log("Found ${requests.length} pending requests for user's rides");

      // Manually fetch user and ride details for each request
      final enrichedRequests = <Map<String, dynamic>>[];

      for (final request in requests) {
        try {
          // Fetch user details
          final userData = await supabase
              .from('users')
              .select('id, name, department, year, email')
              .eq('id', request['requested_by'])
              .maybeSingle();

          // Fetch ride details
          final rideData = await supabase
              .from('rides')
              .select('pickup_name, dropoff_name, departure_time')
              .eq('id', request['ride_id'])
              .maybeSingle();

          // Only add if both user and ride data exist
          if (userData != null && rideData != null) {
            enrichedRequests.add({
              ...request,
              'users': userData,
              'rides': rideData,
            });
          }
        } catch (e) {
          log("Error fetching data for request ${request['id']}: $e");
          // Skip this request if there's an error
          continue;
        }
      }

      allRideRequests.value = enrichedRequests;
    } catch (e) {
      log("Fetch ride requests fallback error: $e");
      Utils.showError("Error", "Could not load ride requests: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  /// Accept a ride request
  Future<void> acceptRideRequest(Map<String, dynamic> request) async {
    try {
      isLoading(true);

      final requestId = request['id'];
      final rideId = request['ride_id'];
      final seatNumbers = List<String>.from(request['seat_numbers'] ?? []);
      final requestedBy = request['requested_by'];

      // Get current ride data
      final rideResponse = await supabase
          .from('rides')
          .select('seats')
          .eq('id', rideId)
          .single();

      final currentSeats = Map<String, dynamic>.from(rideResponse['seats']);

      // Check seat availability
      for (final seatNumber in seatNumbers) {
        final seatData = currentSeats[seatNumber];
        if (seatData != null && seatData['isBooked'] == true) {
          Utils.showError(
              "Seat Unavailable", "Seat $seatNumber is already booked.");
          return;
        }
      }

      // Fetch user's gender before updating seats
      final userGenderResponse = await supabase
          .from('users')
          .select('gender')
          .eq('id', requestedBy)
          .maybeSingle();

      final userGender = userGenderResponse?['gender'] ?? 'unspecified';

      // Update seat data
      for (final seatNumber in seatNumbers) {
        currentSeats[seatNumber] = {
          "isBooked": true,
          "bookedBy": requestedBy,
          "gender": userGender,
        };
      }

      // Update request status
      await supabase
          .from('ride_requests')
          .update({'status': 'accepted'}).eq('id', requestId);

      // Update ride seats
      await supabase
          .from('rides')
          .update({'seats': currentSeats}).eq('id', rideId);

      // Send acceptance notification via chat
      try {
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          final rideResponse = await supabase
              .from('rides')
              .select('from_location, to_location')
              .eq('id', rideId)
              .single();

          final rideInfo =
              "${rideResponse['from_location']} → ${rideResponse['to_location']}";
          final chatMessage =
              "✅ Request Accepted!\n\nYour seat request for $rideInfo has been accepted.\nSeats: ${seatNumbers.join(', ')}\n\nSee you on the ride!";

          await supabase.from('messages').insert({
            'sender_id': currentUser.id,
            'receiver_id': requestedBy,
            'content': chatMessage,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        log("Failed to send acceptance message: $e");
      }

      Utils.showSuccess("Success!",
          message: "Request accepted! Seats booked successfully.");

      // Refresh data
      await fetchAllRideRequests();
      await fetchMyRides();
    } catch (e) {
      log("Accept request error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Reject a ride request
  Future<void> rejectRideRequest(String requestId) async {
    try {
      isLoading(true);

      // First get request details for chat message
      final requestDetails = await supabase
          .from('ride_requests')
          .select('requested_by, ride_id, seat_numbers')
          .eq('id', requestId)
          .single();

      await supabase
          .from('ride_requests')
          .update({'status': 'rejected'}).eq('id', requestId);

      // Send rejection notification via chat
      try {
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          final rideResponse = await supabase
              .from('rides')
              .select('from_location, to_location')
              .eq('id', requestDetails['ride_id'])
              .single();

          final rideInfo =
              "${rideResponse['from_location']} → ${rideResponse['to_location']}";
          final seatNumbers =
              List<String>.from(requestDetails['seat_numbers'] ?? []);
          final chatMessage =
              "❌ Request Declined\n\nYour seat request for $rideInfo has been declined.\nSeats: ${seatNumbers.join(', ')}\n\nFeel free to look for other rides!";

          await supabase.from('messages').insert({
            'sender_id': currentUser.id,
            'receiver_id': requestDetails['requested_by'],
            'content': chatMessage,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        log("Failed to send rejection message: $e");
      }

      Utils.showSuccess("Ops!", message: "Request rejected.");
      await fetchAllRideRequests();
    } catch (e) {
      log("Reject request error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Get available seats count for a ride
  int getAvailableSeats(Map<String, dynamic> ride) {
    final seats = Map<String, dynamic>.from(ride['seats'] ?? {});
    final totalSeats = ride['total_seats'] ?? 0;
    final bookedSeats = seats.values.where((s) => s['isBooked'] == true).length;
    return totalSeats - bookedSeats;
  }

  /// Get booked seats count for a ride
  int getBookedSeats(Map<String, dynamic> ride) {
    final seats = Map<String, dynamic>.from(ride['seats'] ?? {});
    return seats.values.where((s) => s['isBooked'] == true).length;
  }

  /// Get count of pending requests for user's rides
  int getPendingRequestsCount() {
    return allRideRequests.length;
  }

  void listenToRideRequestChanges() {
    _channel = supabase.channel('my_ride_requests');

    _channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'ride_requests',
      callback: (payload) {
        log("New ride request inserted");
        fetchAllRideRequests();
      },
    );

    _channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'ride_requests',
      callback: (payload) {
        log("Ride request updated");
        fetchAllRideRequests();
        fetchMyRides();
        fetchMyJoinedRides();
      },
    );

    _channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'rides',
      callback: (payload) {
        log("Ride updated (seats changed)");
        fetchMyRides();
        fetchMyJoinedRides();
      },
    );
    _channel.subscribe();
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchMyRides(),
      fetchMyJoinedRides(),
      fetchAllRideRequests(),
    ]);
  }

  /// Change selected tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  /// Get user's booked seats for a specific ride
  List<String> getMyBookedSeats(Map<String, dynamic> ride) {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final seats = Map<String, dynamic>.from(ride['seats'] ?? {});
    final mySeats = <String>[];

    seats.forEach((seatNumber, seatData) {
      if (seatData['bookedBy'] == user.id) {
        mySeats.add(seatNumber);
      }
    });

    return mySeats;
  }
}
