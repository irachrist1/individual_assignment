import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/listing_model.dart';
import '../../widgets/listing_card.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  LatLng get _position =>
      LatLng(widget.listing.latitude, widget.listing.longitude);

  Future<void> _launchNavigation() async {
    final lat = widget.listing.latitude;
    final lng = widget.listing.longitude;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  Future<void> _callNumber() async {
    final uri = Uri.parse('tel:${widget.listing.contactNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final color = categoryColors[listing.category] ?? Colors.blue;
    final icon = categoryIcons[listing.category] ?? Icons.place;
    final dateStr = listing.createdAt != null
        ? DateFormat('MMM d, yyyy').format(listing.createdAt!)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Embedded Google Map
            SizedBox(
              height: 240,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _position,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(listing.id ?? 'marker'),
                    position: _position,
                    infoWindow: InfoWindow(
                      title: listing.name,
                      snippet: listing.category,
                    ),
                  ),
                },
                onMapCreated: (_) {},
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
            // Navigate button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _launchNavigation,
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            // Detail cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & category header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.name,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(listing.category,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: listing.address,
                  ),
                  _DetailRow(
                    icon: Icons.phone,
                    label: 'Contact',
                    value: listing.contactNumber,
                    onTap: listing.contactNumber.isNotEmpty
                        ? _callNumber
                        : null,
                    valueColor: Colors.blue,
                  ),
                  _DetailRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: listing.description,
                  ),
                  _DetailRow(
                    icon: Icons.my_location,
                    label: 'Coordinates',
                    value:
                        '${listing.latitude.toStringAsFixed(5)}, ${listing.longitude.toStringAsFixed(5)}',
                  ),
                  if (dateStr.isNotEmpty)
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Added',
                      value: dateStr,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value.isNotEmpty ? value : '—',
                    style: TextStyle(
                      fontSize: 15,
                      color: valueColor ?? Colors.black87,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
