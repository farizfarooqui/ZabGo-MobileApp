import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo/Utils/Utils.dart';
import 'package:demo/Views/NavBar.dart';

class OfferRideController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;

  // Form controllers
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final fareController = TextEditingController();
  final carNameController = TextEditingController();
  final carColorController = TextEditingController();
  final carNumberController = TextEditingController();
  final totalSeatsController = TextEditingController();
  final departureTimeController = TextEditingController();
  final estimatedArrivalController = TextEditingController();
  final pickupNameController = TextEditingController();
  final dropOffNameController = TextEditingController();
  final contactNoController = TextEditingController();

  // Store lat/lng for pickup & drop
  LatLngData? fromLatLng;
  LatLngData? toLatLng;

  @override
  void onClose() {
    fromController.dispose();
    toController.dispose();
    fareController.dispose();
    carNameController.dispose();
    carColorController.dispose();
    carNumberController.dispose();
    totalSeatsController.dispose();
    departureTimeController.dispose();
    estimatedArrivalController.dispose();
    pickupNameController.dispose();
    dropOffNameController.dispose();
    contactNoController.dispose();
    super.onClose();
  }

  Future<void> postRide() async {
    if (fromController.text.isEmpty ||
        toController.text.isEmpty ||
        fareController.text.isEmpty ||
        totalSeatsController.text.isEmpty ||
        departureTimeController.text.isEmpty ||
        estimatedArrivalController.text.isEmpty ||
        carNameController.text.isEmpty ||
        carNumberController.text.isEmpty ||
        carColorController.text.isEmpty ||
        pickupNameController.text.isEmpty ||
        dropOffNameController.text.isEmpty ||
        fromLatLng == null ||
        toLatLng == null) {
      Utils.showError("Missing Fields", "Please fill all ride details.");
      return;
    }

    try {
      isLoading(true);
      final user = supabase.auth.currentUser;
      if (user == null) {
        Utils.showError("Error", "You must be logged in.");
        return;
      }

      int totalSeats = int.parse(totalSeatsController.text);
      Map<String, dynamic> seats = {
        for (int i = 1; i <= totalSeats; i++)
          i.toString(): {"isBooked": false, "bookedBy": null, "gender": null}
      };
      final box = GetStorage();
      final ownUser = box.read('userData') as Map<String, dynamic>;

      final rideData = {
        "car_guy_id": ownUser['id'],
        "name": ownUser['name'],
        "front_id_url": ownUser['front_id_url'],
        "gender": ownUser['gender'],
        "number": ownUser['number'],
        "student_id": ownUser['student_id'],
        "department": ownUser['department'],
        "semester": ownUser['semester'],
        "from_location": fromController.text.trim(),
        "to_location": toController.text.trim(),
        "from_lat": fromLatLng!.lat,
        "from_lng": fromLatLng!.lng,
        "to_lat": toLatLng!.lat,
        "to_lng": toLatLng!.lng,
        "departure_time": departureTimeController.text,
        "estimated_arrival_time": estimatedArrivalController.text,
        "pickup_name": pickupNameController.text.trim(),
        "dropoff_name": dropOffNameController.text.trim(),
        "fare_price": double.parse(fareController.text),
        "ride_name": carNameController.text.trim(),
        "ride_color": carColorController.text.trim(),
        "ride_number": carNumberController.text.trim(),
        "total_seats": totalSeats,
        "seats": seats,
        "status": "active",
        "created_at": DateTime.now().toIso8601String(),
        "number": contactNoController.text.trim(),
      };

      await supabase.from('rides').insert(rideData);
      Utils.showSuccess("Success!", message: "Ride posted successfully.");
      Get.offAll(() => const NavBar());
    } catch (e) {
      log("PostRide Error: $e");
      Utils.showError("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}

class LatLngData {
  final double lat;
  final double lng;
  LatLngData(this.lat, this.lng);
}
