import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/geo_place.dart';

abstract final class AppMapDefaults {
  /// Where a map with no point yet opens: Kochi, at city zoom.
  static const fallbackCenter = LatLng(9.9312, 76.2673);
  static const fallbackZoom = 11.0;

  /// Close enough to place a pin on a building.
  static const pinZoom = 17.0;

  /// Street-level view for a read-only preview.
  static const previewZoom = 15.0;

  static const markerColor = Color(0xFF1F7A63);
}

LatLng _latLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

/// A map the user drags under a fixed centre pin to choose a point.
///
/// [point] moves the camera when the parent changes it (a search result, the
/// current location). [onPinMoved] fires once the user lets go of the map —
/// never for those programmatic moves.
class PinPickerMap extends StatefulWidget {
  const PinPickerMap({
    required this.point,
    required this.onPinMoved,
    this.height = 420,
    this.radius = 30,
    this.interactive = true,
    super.key,
  });

  final GeoPoint? point;
  final ValueChanged<GeoPoint> onPinMoved;
  final double height;
  final double radius;

  /// False shows the pin without letting the user move it.
  final bool interactive;

  @override
  State<PinPickerMap> createState() => _PinPickerMapState();
}

class _PinPickerMapState extends State<PinPickerMap> {
  GoogleMapController? _controller;
  LatLng? _center;
  bool _userMoved = false;

  @override
  void didUpdateWidget(PinPickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final point = widget.point;
    if (point != null && point != oldWidget.point) {
      final target = _latLng(point);
      // Already there: this is the point the user just dragged to.
      if (_center != null &&
          (_center!.latitude - target.latitude).abs() < 1e-7 &&
          (_center!.longitude - target.longitude).abs() < 1e-7) {
        return;
      }
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(target, AppMapDefaults.pinZoom),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: point == null
                    ? AppMapDefaults.fallbackCenter
                    : _latLng(point),
                zoom: point == null
                    ? AppMapDefaults.fallbackZoom
                    : AppMapDefaults.pinZoom,
              ),
              onMapCreated: (controller) => _controller = controller,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: widget.interactive,
              zoomGesturesEnabled: widget.interactive,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              // The wizard scrolls; without this the page would steal drags
              // meant for the map.
              gestureRecognizers: widget.interactive
                  ? {
                      Factory<OneSequenceGestureRecognizer>(
                        EagerGestureRecognizer.new,
                      ),
                    }
                  : const {},
              onCameraMoveStarted: () => _userMoved = true,
              onCameraMove: (position) => _center = position.target,
              onCameraIdle: () {
                final center = _center;
                if (!_userMoved || center == null) return;
                _userMoved = false;
                widget.onPinMoved(GeoPoint(center.latitude, center.longitude));
              },
            ),
            // The pin's tip marks the centre, so lift it by half its height.
            const IgnorePointer(
              child: Padding(
                padding: EdgeInsets.only(bottom: 44),
                child: Icon(
                  Icons.location_on,
                  size: 44,
                  color: AppMapDefaults.markerColor,
                  shadows: [Shadow(blurRadius: 6, color: Color(0x55000000))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A read-only map with one marker. Tapping anywhere calls [onTap] (usually
/// "open in Google Maps"); the map itself never takes gestures.
class LocationPreviewMap extends StatelessWidget {
  const LocationPreviewMap({
    required this.point,
    this.onTap,
    this.height = 200,
    this.radius = 20,
    super.key,
  });

  final GeoPoint point;
  final VoidCallback? onTap;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final target = _latLng(point);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: target,
                zoom: AppMapDefaults.previewZoom,
              ),
              // A static bitmap on Android — cheap inside a scrolling page.
              liteModeEnabled: defaultTargetPlatform == TargetPlatform.android,
              markers: {
                Marker(markerId: const MarkerId('place'), position: target),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
            // Catches taps above the platform view.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
