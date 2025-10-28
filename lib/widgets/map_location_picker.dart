import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;
  final LatLng? initialLocation;

  const MapLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(-29.3167, 27.4833); // Maseru center
  Set<Marker> _markers = {};
  String _addressText = 'Select a location on the map';
  bool _isLoading = false;
  String? _nearestArea;

  // Maseru neighborhoods with approximate coordinates
  final Map<String, LatLng> _maseruAreas = {
    'Thetsane': LatLng(-29.2833, 27.4667),
    'Lithabaneng': LatLng(-29.3500, 27.4500),
    'Katlehong': LatLng(-29.3167, 27.5000),
    'Ha Tšosane': LatLng(-29.3000, 27.4700),
    'Maseru West': LatLng(-29.3200, 27.4600),
    'Ha Matala': LatLng(-29.3100, 27.4900),
    'Masowe': LatLng(-29.3300, 27.4800),
    'Ha Thetsane': LatLng(-29.2900, 27.4650),
    'Pioneer Mall': LatLng(-29.3095, 27.4786),
    'Maseru Mall': LatLng(-29.3158, 27.4872),
    'Kick4Life Centre': LatLng(-29.3123, 27.4901),
    'NRH Mall': LatLng(-29.3200, 27.4850),
    'Setsoto Stadium': LatLng(-29.3089, 27.4912),
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
      _updateMarker(_selectedLocation);
    }
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get current location if permission granted
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Only use current location if it's within Maseru bounds
      if (_isInMaseru(position.latitude, position.longitude)) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation, 15),
        );
        _updateMarker(_selectedLocation);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  bool _isInMaseru(double lat, double lon) {
    // Maseru rough bounds
    const double minLat = -29.45;
    const double maxLat = -29.20;
    const double minLon = 27.35;
    const double maxLon = 27.60;
    
    return lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon;
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _onLocationSelected(newPosition);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      };
    });
  }

  Future<void> _onLocationSelected(LatLng location) async {
    if (!_isInMaseru(location.latitude, location.longitude)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location within Maseru'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedLocation = location;
      _isLoading = true;
    });

    _updateMarker(location);

    // Get address from coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _addressText = '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? 'Maseru'}'
              .replaceAll(', ,', ',')
              .trim();
        });
      }
    } catch (e) {
      print('Geocoding error: $e');
      setState(() {
        _addressText = 'Location selected: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      });
    }

    // Find nearest predefined area
    _nearestArea = _findNearestArea(location);

    setState(() {
      _isLoading = false;
    });
  }

  String? _findNearestArea(LatLng location) {
    String? nearest;
    double minDistance = double.infinity;

    _maseruAreas.forEach((areaName, areaLocation) {
      double distance = Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        areaLocation.latitude,
        areaLocation.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = areaName;
      }
    });

    // Only return if within 2km
    return minDistance < 2000 ? nearest : null;
  }

  void _confirmLocation() {
    final locationData = {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'address': _addressText,
      'nearest_area': _nearestArea,
      'formatted': _addressText,
    };

    widget.onLocationSelected(locationData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location on Map'),
        backgroundColor: const Color(0xFF88844D),
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _checkLocationPermission,
              tooltip: 'My Location',
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onLocationSelected,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            // Restrict to Maseru bounds
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: const LatLng(-29.45, 27.35),
                northeast: const LatLng(-29.20, 27.60),
              ),
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(12, 20),
          ),
          
          // Address display card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF88844D)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLoading ? 'Getting address...' : _addressText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_nearestArea != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Nearest area: $_nearestArea',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Card(
              color: const Color(0xFFBEC092).withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Color(0xFF88844D)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap on the map or drag the marker to select your location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}