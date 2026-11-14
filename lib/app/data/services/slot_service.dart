import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Date & slot booking page — `Slot Booking` sheet (Page 6).
///
/// Note the 5-minute freeze flow: [freezeSlot] returns a `freezeId` that
/// [getFreezeStatus] polls and [releaseFreeze] cancels.
class SlotService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Monthly availability calendar for [month] (`YYYY-MM`): `{days: [{date,
  /// tag, isAvailable, availableUnits, price}]}`, each day tagged available /
  /// unavailable / offer / seasonal.
  Future<dynamic> getAvailability(String listingId, {String? month}) =>
      _api.getRequest(
        SlotEndpoints.availability(listingId),
        query: {'month': ?month},
      );

  /// The sessions on a date (`YYYY-MM-DD`): `{slots: [{slotId, startTime,
  /// endTime, price, isAvailable, availableUnits}]}`. Empty for stays sold
  /// by the night.
  Future<dynamic> getSlots(String listingId, String date) =>
      _api.getRequest(SlotEndpoints.slots(listingId), query: {'date': date});

  Future<dynamic> freezeSlot({
    required String listingId,
    required String date,
    required String slotId,
  }) =>
      _api.postRequest(
        SlotEndpoints.freeze,
        body: {'listingId': listingId, 'date': date, 'slotId': slotId},
      );

  Future<dynamic> getFreezeStatus(String freezeId) =>
      _api.getRequest(SlotEndpoints.freezeStatus(freezeId));

  Future<dynamic> releaseFreeze(String freezeId) =>
      _api.deleteRequest(SlotEndpoints.freezeStatus(freezeId));
}
