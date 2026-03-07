import 'package:flutter/material.dart';
import 'dart:async';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';

enum ListingsStatus { initial, loading, loaded, error }

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<ListingModel> _allListings = [];
  List<ListingModel> _userListings = [];
  List<ListingModel> _filteredListings = [];

  ListingsStatus _status = ListingsStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  StreamSubscription<List<ListingModel>>? _allSub;
  StreamSubscription<List<ListingModel>>? _userSub;

  // Public getters
  List<ListingModel> get filteredListings => _filteredListings;
  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get userListings => _userListings;
  ListingsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  static const List<String> categories = [
    'All',
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Utility Office',
    'Other',
  ];

  /// Start streaming all listings from Firestore
  void startListening() {
    _allSub?.cancel();
    _status = ListingsStatus.loading;
    notifyListeners();

    _allSub = _service.getListingsStream().listen(
      (listings) {
        _allListings = listings;
        _applyFilters();
        _status = ListingsStatus.loaded;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load listings.';
        _status = ListingsStatus.error;
        notifyListeners();
      },
    );
  }

  /// Start streaming listings owned by [userId]
  void startListeningUserListings(String userId) {
    _userSub?.cancel();
    // Clear stale data immediately so the previous user's listings
    // are never shown while the new subscription loads.
    _userListings = [];
    notifyListeners();

    _userSub = _service.getUserListingsStream(userId).listen(
      (listings) {
        _userListings = listings;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load your listings.';
        notifyListeners();
      },
    );
  }

  /// Cancel the user-specific subscription and clear its data.
  /// Call this when the current user signs out.
  void clearUserListings() {
    _userSub?.cancel();
    _userSub = null;
    _userListings = [];
    notifyListeners();
  }

  void stopListening() {
    _allSub?.cancel();
    _userSub?.cancel();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredListings = _allListings.where((listing) {
      final matchesSearch = _searchQuery.isEmpty ||
          listing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<bool> createListing(ListingModel listing) async {
    try {
      await _service.createListing(listing);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create listing.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(String id, ListingModel listing) async {
    try {
      await _service.updateListing(id, listing);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete listing.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
