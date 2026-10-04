import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ProfileScreen()));

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isFollowing = false;
  bool isLiked = false;
  int likes = 999;

  void reset() {
    setState(() {
      isFollowing = false;
      isLiked = false;
      likes = 999;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Card')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const Text('Bekzhan Developer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('$likes Likes'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => isFollowing = !isFollowing),
                  child: Text(isFollowing ? 'Following' : 'Follow'),
                ),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () => setState(() {
                    likes--;
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () => setState(() {
                    likes++;
                  }),
                ),
              ],
            ),
            TextButton(onPressed: reset, child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}