import 'package:flutter/material.dart';
import '../../model/dating_profile_model.dart';

// 1. Ubah menjadi StatefulWidget
class LikedProfilesScreen extends StatefulWidget {
  final List<DatingProfile> likedProfiles;
  // 2. Tambahkan parameter untuk fungsi callback 'onUnlike'
  final Function(DatingProfile) onUnlike;

  const LikedProfilesScreen({
    Key? key,
    required this.likedProfiles,
    required this.onUnlike, // Tambahkan di constructor
  }) : super(key: key);

  @override
  State<LikedProfilesScreen> createState() => _LikedProfilesScreenState();
}

class _LikedProfilesScreenState extends State<LikedProfilesScreen> {
  // Buat daftar lokal untuk mengelola tampilan UI secara langsung
  late List<DatingProfile> _currentLikedProfiles;

  @override
  void initState() {
    super.initState();
    // Salin daftar dari widget ke state lokal
    _currentLikedProfiles = List.from(widget.likedProfiles);
  }

  void _unlike(DatingProfile profile) {
    // Panggil fungsi callback dari parent untuk mengubah state utama
    widget.onUnlike(profile);
    // Ubah state lokal untuk memberikan feedback visual instan
    setState(() {
      _currentLikedProfiles.remove(profile);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${profile.name} dihapus dari daftar suka.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Disukai'),
        backgroundColor: Color(0xFF585752),
      ),
      body: _currentLikedProfiles.isEmpty
          ? Center(
              child: Text(
                'Anda belum menyukai profil siapapun.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _currentLikedProfiles.length,
              itemBuilder: (context, index) {
                final profile = _currentLikedProfiles[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(profile.imageUrl),
                      radius: 30,
                    ),
                    title: Text('${profile.name}, ${profile.age}'),
                    subtitle: Text(profile.bio),
                    // 3. Tambahkan tombol unlike
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red[400]),
                      tooltip: 'Unlike',
                      onPressed: () {
                        _unlike(profile);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}