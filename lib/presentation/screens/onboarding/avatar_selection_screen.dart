import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarSelectionScreen extends StatefulWidget {
  @override
  _AvatarSelectionScreenState createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String? selectedAvatar;

  Future<void> _saveAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_avatar', avatarPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Avatar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 9, // Assuming 9 avatars in assets
          itemBuilder: (context, index) {
            final avatarPath = 'assets/avatars/avatar${index + 1}.png';
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAvatar = avatarPath;
                });
                _saveAvatar(avatarPath);
              },
              child: Image.asset(avatarPath),
            );
          },
        ),
      ),
    );
  }
}