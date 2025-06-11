import 'package:flutter/material.dart';
import '../model/dating_profile_model.dart';
// Hapus import initializer dan ganti dengan page_notes
import '../views/page_notes.dart';

class ProfileCard extends StatelessWidget {
  final DatingProfile profile;

  const ProfileCard({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(profile.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient untuk membuat teks lebih mudah dibaca
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
          // Informasi Profil
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris untuk Nama, Umur, dan Tombol Kelola Keuangan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nama dan Umur
                    Expanded(
                      child: Text(
                        '${profile.name}, ${profile.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black54,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Beri sedikit jarak
                    // Tombol Kelola Keuangan dengan Teks
                    ElevatedButton.icon(
                      onPressed: () {
                        // <<< PERUBAHAN DI SINI >>>
                        // Arahkan langsung ke halaman catatan keuangan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PageNotes()),
                        );
                      },
                      icon: const Icon(Icons.account_balance_wallet, size: 18),
                      label: const Text('Kelola Keuangan'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // Warna ikon dan teks
                        backgroundColor:
                            const Color(0xFFb2855d), // Warna latar tombol
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Bio
                Text(
                  profile.bio,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Jarak
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      profile.distance,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}