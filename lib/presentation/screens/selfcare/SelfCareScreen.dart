import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SelfCareScreen extends StatelessWidget {
  final dynamic userProfile;

  const SelfCareScreen({Key? key, required this.userProfile}) : super(key: key);

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget videoTile(String title, String url) {
    return ListTile(
      leading: Icon(Icons.play_circle_fill, color: Colors.pinkAccent),
      title: Text(title),
      onTap: () => _launchURL(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Self-Care & Wellness"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Hi ${userProfile["name"]}, here are some self-care tips curated for you ❤️"),

            sectionTitle("🌿 Skincare Tips for Moms"),
            videoTile("Skincare for Pregnant Women", "https://www.youtube.com/watch?v=VIDEO_ID_1"),
            videoTile("Postpartum Skincare Routine", "https://www.youtube.com/watch?v=VIDEO_ID_2"),
            videoTile("Skincare After Miscarriage", "https://www.youtube.com/watch?v=VIDEO_ID_3"),

            sectionTitle("🥗 Healthy Food Habits"),
            videoTile("Top 10 Foods During Pregnancy", "https://www.youtube.com/watch?v=VIDEO_ID_4"),
            videoTile("Nutrition for Breastfeeding Moms", "https://www.youtube.com/watch?v=VIDEO_ID_5"),
            videoTile("Foods to Avoid After Miscarriage", "https://www.youtube.com/watch?v=VIDEO_ID_6"),

            sectionTitle("🧘 Self-Care Tips"),
            videoTile("Mindfulness for Mothers", "https://www.youtube.com/watch?v=VIDEO_ID_7"),
            videoTile("Gentle Yoga for Healing", "https://www.youtube.com/watch?v=VIDEO_ID_8"),
          ],
        ),
      ),
    );
  }
}
