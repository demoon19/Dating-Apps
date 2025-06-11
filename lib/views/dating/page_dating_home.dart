import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../model/dating_profile_model.dart';
import '../../widgets/profile_card.dart';
import 'page_nearby.dart';
import 'page_liked.dart';
import '../../services/notification_service.dart'; // <-- Import service notifikasi

class DatingHomeScreen extends StatefulWidget {
  const DatingHomeScreen({Key? key}) : super(key: key);

  @override
  _DatingHomeScreenState createState() => _DatingHomeScreenState();
}

class _DatingHomeScreenState extends State<DatingHomeScreen> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isShakeCooldown = false;

  final List<DatingProfile> _originalProfiles = [
    DatingProfile(
      name: 'Rina',
      age: 24,
      bio: 'Suka kopi, musik indie, dan jalan-jalan sore.',
      imageUrl: 'assets/profil/1.jpeg',
      distance: '500 m',
    ),
    DatingProfile(
      name: 'Dewi',
      age: 27,
      bio: 'Software engineer yang hobi memasak dan nonton film sci-fi.',
      imageUrl: 'assets/profil/2.jpg',
      distance: '1.2 km',
    ),
    DatingProfile(
      name: 'Sari',
      age: 22,
      bio: 'Mahasiswi desain grafis. Mencari teman untuk diskusi kreatif.',
      imageUrl: 'assets/profil/3.jpeg',
      distance: '3 km',
    ),
  ];

  List<DatingProfile> _profiles = [];
  List<DatingProfile> _likedProfiles = [];

  @override
  void initState() {
    super.initState();
    _profiles = List<DatingProfile>.from(_originalProfiles);

    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_isShakeCooldown || _profiles.isEmpty) return;

      const double shakeThreshold = 12.0;

      if (event.x > shakeThreshold) {
        _like();
        _startShakeCooldown();
      } else if (event.x < -shakeThreshold) {
        _dislike();
        _startShakeCooldown();
      }
    });
  }

  void _startShakeCooldown() {
    setState(() {
      _isShakeCooldown = true;
    });
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isShakeCooldown = false;
        });
      }
    });
  }
  
  void _unlikeProfile(DatingProfile profile) {
    setState(() {
      _likedProfiles.remove(profile);
    });
  }

  void _refreshProfiles() {
    setState(() {
      _profiles = List<DatingProfile>.from(_originalProfiles);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daftar profil telah dimuat ulang!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _dismissProfile() {
    setState(() {
      if (_profiles.isNotEmpty) {
        _profiles.removeAt(0);
      }
    });
  }

  void _dislike() {
    if (_profiles.isEmpty) return;
    
    // Tampilkan notifikasi
    NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Profil Dilewati',
        body: 'Anda telah melewati profil ${_profiles.first.name}.');
        
    _dismissProfile();
  }

  void _like() {
    if (_profiles.isEmpty) return;
    final likedProfile = _profiles[0];

    if (!_likedProfiles.any((p) => p.name == likedProfile.name)) {
      setState(() {
        _likedProfiles.add(likedProfile);
      });
    }

    // Tampilkan notifikasi
    NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Anda Menyukai Seseorang!',
        body: 'Anda baru saja menyukai ${likedProfile.name}.');
        
    _dismissProfile();
  }

  void _superLike() {
    if (_profiles.isEmpty) return;
    final likedProfile = _profiles[0];

    if (!_likedProfiles.any((p) => p.name == likedProfile.name)) {
      setState(() {
        _likedProfiles.add(likedProfile);
      });
    }
    
    // Tampilkan notifikasi untuk Super Like
    NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Super Like!',
        body: 'Anda memberi Super Like pada ${likedProfile.name}!');
        
    _dismissProfile();
  }
  
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... sisa kode build widget tidak berubah
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datting Apps',
            style: TextStyle(
                color: Color(0xFFF0F1DA), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF585752),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Profil Disukai',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedProfilesScreen(
                    likedProfiles: _likedProfiles,
                    onUnlike: _unlikeProfile,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Profil',
            onPressed: _refreshProfiles,
          ),
          IconButton(
            icon: const Icon(Icons.near_me),
            tooltip: 'Pengguna Terdekat',
            onPressed: () {
              final profileListCopy = List<DatingProfile>.from(_profiles);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NearbyUsersScreen(profiles: profileListCopy),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildProfileCard(),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    if (_profiles.isEmpty) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Tidak ada profil lagi.",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 10),
          Text("Tekan tombol refresh untuk memuat ulang.",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ));
    }

    final currentProfile = _profiles[0];

    return Draggable(
      key: ValueKey(currentProfile.name),
      feedback: ProfileCard(profile: currentProfile),
      childWhenDragging: Container(),
      onDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx.abs() > 200) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            _like();
          } else {
            _dislike();
          }
        }
      },
      child: ProfileCard(profile: currentProfile),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
            icon: Icons.close, color: Colors.red, onPressed: _dislike),
        _buildActionButton(
            icon: Icons.star,
            color: Colors.blue,
            size: 40,
            onPressed: _superLike),
        _buildActionButton(
            icon: Icons.favorite, color: Colors.green, onPressed: _like),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      double size = 50,
      required VoidCallback onPressed}) {
    final bool isEnabled = _profiles.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled ? Colors.white : Colors.grey.shade800,
        boxShadow: isEnabled
            ? [
                const BoxShadow(
                    color: Colors.black26, blurRadius: 5, spreadRadius: 1),
              ]
            : [],
      ),
      child: IconButton(
        icon: Icon(icon, color: isEnabled ? color : Colors.grey),
        iconSize: size / 1.5,
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }
}