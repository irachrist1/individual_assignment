import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali Directory'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                // Search field
                TextField(
                  onChanged: (v) =>
                      context.read<ListingsProvider>().setSearchQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or address...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Category filter chips
                _CategoryFilterBar(),
              ],
            ),
          ),
          // Listings list
          Expanded(child: _ListingsBody()),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ListingsProvider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final cat = ListingsProvider.categories[i];
          final selected = provider.selectedCategory == cat;
          return FilterChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => provider.setCategory(cat),
            backgroundColor: Colors.white,
            selectedColor: Colors.blue.shade700,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}

class _ListingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();

    if (provider.status == ListingsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == ListingsStatus.error) {
      return Center(
        child: Text(provider.errorMessage ?? 'An error occurred',
            style: const TextStyle(color: Colors.red)),
      );
    }

    final listings = provider.filteredListings;

    if (listings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No listings found.',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: listings.length,
      itemBuilder: (context, i) {
        final listing = listings[i];
        return ListingCard(
          listing: listing,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          ),
        );
      },
    );
  }
}
