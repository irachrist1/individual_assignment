import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'listings';

  // Real-time stream of all listings, ordered by newest first
  Stream<List<ListingModel>> getListingsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  // Real-time stream of listings belonging to a specific user.
  // Sorted client-side to avoid requiring a composite Firestore index.
  Stream<List<ListingModel>> getUserListingsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final listings = snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
        listings.sort((a, b) {
          final aTime = a.createdAt ?? DateTime(0);
          final bTime = b.createdAt ?? DateTime(0);
          return bTime.compareTo(aTime);
        });
      return listings;
    });
  }

  // Add a new listing to Firestore
  Future<void> createListing(ListingModel listing) async {
    await _firestore.collection(_collection).add(listing.toMap());
  }

  // Update an existing listing (preserves original createdAt)
  Future<void> updateListing(String id, ListingModel listing) async {
    final data = listing.toMap();
    data.remove('createdAt'); // keep original timestamp
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).doc(id).update(data);
  }

  // Remove a listing from Firestore
  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
