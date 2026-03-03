import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../models/listing_model.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';
import 'create_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  Future<void> _confirmDelete(
      BuildContext context, ListingModel listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Delete "${listing.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final success = await context
          .read<ListingsProvider>()
          .deleteListing(listing.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '${listing.name} deleted.'
                : 'Failed to delete listing.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final userListings = context.watch<ListingsProvider>().userListings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: user == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateEditListingScreen(userId: user.uid),
                  ),
                ),
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: userListings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No listings yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('Tap + to add your first listing.',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: userListings.length,
              itemBuilder: (context, i) {
                final listing = userListings[i];
                return ListingCard(
                  listing: listing,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  ),
                  onEdit: user == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateEditListingScreen(
                                userId: user.uid,
                                existingListing: listing,
                              ),
                            ),
                          ),
                  onDelete: () => _confirmDelete(context, listing),
                );
              },
            ),
    );
  }
}
