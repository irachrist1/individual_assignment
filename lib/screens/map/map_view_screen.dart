import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';

// Default map centre: Kigali city centre
const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  ListingModel? _selectedListing;

  Set<Marker> _buildMarkers(
      List<ListingModel> listings, BuildContext context) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id ?? listing.name),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          ),
        ),
        onTap: () => setState(() => _selectedListing = listing),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().allListings;
    final markers = _buildMarkers(listings, context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centre on Kigali',
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(target: _kigaliCenter, zoom: 13),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: 13,
            ),
            markers: markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationButtonEnabled: false,
            onTap: (_) => setState(() => _selectedListing = null),
          ),
          // Bottom peek card for selected listing
          if (_selectedListing != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ListingCard(
                listing: _selectedListing!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ListingDetailScreen(listing: _selectedListing!),
                  ),
                ),
              ),
            ),
          // Listings count badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6)
                ],
              ),
              child: Text(
                '${listings.length} place${listings.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
