import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/api_endpoints.dart';
import '../models/geo_place.dart';
import '../providers/api_client.dart';

/// Why the device location couldn't be read, worded for the user.
class LocationUnavailable implements Exception {
  const LocationUnavailable(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Address search (through the backend), the device's own location, and
/// handing a point to the Google Maps app.
class GeoService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Groups one search's keystrokes and the final pick into a single billed
  /// Places session. Start a new one after each pick.
  static String newSessionToken() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'[random.nextInt(36)],
    ).join();
  }

  Future<List<PlaceSuggestion>> autocomplete(
    String query, {
    required String sessionToken,
    GeoPoint? near,
  }) async {
    final data = await _api.getRequest(
      GeoEndpoints.autocomplete,
      query: {
        'q': query,
        'session': sessionToken,
        'lat': ?near?.latitude,
        'lng': ?near?.longitude,
      },
    );
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PlaceSuggestion.fromJson)
        .toList();
  }

  Future<ResolvedPlace> place(
    String placeId, {
    required String sessionToken,
  }) async {
    final data = await _api.getRequest(
      GeoEndpoints.place(placeId),
      query: {'session': sessionToken},
    );
    return ResolvedPlace.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<ResolvedPlace> reverse(GeoPoint point) async {
    final data = await _api.getRequest(
      GeoEndpoints.reverse,
      query: {'lat': point.latitude, 'lng': point.longitude},
    );
    return ResolvedPlace.fromJson((data as Map).cast<String, dynamic>());
  }

  /// The device's current position, asking for permission if needed.
  /// Throws [LocationUnavailable] with a message to show.
  Future<GeoPoint> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailable(
        'Turn on location services to use your current location.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationUnavailable(
        'Allow location access to use your current location.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationUnavailable(
        'Location access is off for TRIPTRIVA. Turn it on in Settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return GeoPoint(position.latitude, position.longitude);
  }

  /// The device's position when location is already allowed, else null.
  /// Never prompts — for screens that only use location to rank results.
  Future<GeoPoint?> locationIfAllowed() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }
      final position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 8),
            ),
          );
      return GeoPoint(position.latitude, position.longitude);
    } catch (error) {
      Get.log('Location unavailable: $error');
      return null;
    }
  }

  /// Opens Google Maps (app if installed, else the website) on a point, or
  /// on an address search when the point isn't known.
  static Future<bool> openInMaps({GeoPoint? point, String address = ''}) {
    final query = point?.label.replaceAll(' ', '') ?? address.trim();
    if (query.isEmpty) return Future.value(false);
    return launchUrl(
      Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}),
      mode: LaunchMode.externalApplication,
    );
  }

  /// Opens turn-by-turn directions from wherever the user is.
  static Future<bool> openDirections({GeoPoint? point, String address = ''}) {
    final destination = point?.label.replaceAll(' ', '') ?? address.trim();
    if (destination.isEmpty) return Future.value(false);
    return launchUrl(
      Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': destination,
      }),
      mode: LaunchMode.externalApplication,
    );
  }
}
