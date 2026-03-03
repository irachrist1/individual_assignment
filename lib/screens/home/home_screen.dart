import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../directory/directory_screen.dart';
import '../my_listings/my_listings_screen.dart';
import '../map/map_view_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DirectoryScreen(),
    MyListingsScreen(),
    MapViewScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Start listening to Firestore streams after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listingsProvider = context.read<ListingsProvider>();
      final user = context.read<AuthProvider>().user;
      listingsProvider.startListening();
      if (user != null) {
        listingsProvider.startListeningUserListings(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
