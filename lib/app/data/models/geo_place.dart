/// A point on the map, in plain latitude/longitude.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// "9.99520, 76.32010" — five decimals is about a metre.
  String get label =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  /// Both or neither must be numbers; anything else is no point at all.
  static GeoPoint? tryParse(dynamic latitude, dynamic longitude) {
    if (latitude is! num || longitude is! num) return null;
    if (latitude == 0 && longitude == 0) return null;
    return GeoPoint(latitude.toDouble(), longitude.toDouble());
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// One "as you type" match from `GET /api/geo/autocomplete`.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    this.secondaryText = '',
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: '${json['placeId'] ?? ''}',
      primaryText: '${json['primaryText'] ?? ''}',
      secondaryText: '${json['secondaryText'] ?? ''}',
    );
  }

  final String placeId;
  final String primaryText;
  final String secondaryText;
}

/// A point and its postal address, split like the partner's address form.
class ResolvedPlace {
  const ResolvedPlace({
    required this.point,
    this.formattedAddress = '',
    this.addressLine = '',
    this.locality = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
  });

  factory ResolvedPlace.fromJson(Map<String, dynamic> json) {
    return ResolvedPlace(
      point: GeoPoint.tryParse(json['latitude'], json['longitude']) ??
          const GeoPoint(0, 0),
      formattedAddress: '${json['formattedAddress'] ?? ''}',
      addressLine: '${json['addressLine'] ?? ''}',
      locality: '${json['locality'] ?? ''}',
      city: '${json['city'] ?? ''}',
      state: '${json['state'] ?? ''}',
      pincode: '${json['pincode'] ?? ''}',
    );
  }

  final GeoPoint point;
  final String formattedAddress;
  final String addressLine;
  final String locality;
  final String city;
  final String state;
  final String pincode;
}
