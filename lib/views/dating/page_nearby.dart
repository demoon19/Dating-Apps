import 'package:flutter/material.dart';
import '../../model/dating_profile_model.dart';

class NearbyUsersScreen extends StatelessWidget {
  final List<DatingProfile> profiles;

  const NearbyUsersScreen({Key? key, required this.profiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengguna di Sekitar'),
        backgroundColor: Color(0xFF585752),
      ),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(profile.imageUrl),
                radius: 30,
              ),
              title: Text('${profile.name}, ${profile.age}'),
              subtitle: Text(profile.bio),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.white70),
                  Text(profile.distance, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}