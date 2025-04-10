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
      child: Row(
        children: [
          Icon(Icons.ondemand_video_rounded, color: Color(0xFFF4B942)),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget videoTile(String title, String url) {
    return ListTile(
      leading: Icon(Icons.play_circle_fill, color: Color(0xFFF4B942)),
      title: Text(title),
      onTap: () => _launchURL(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B942),
        title: Text("Self-Care & Wellness"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Hi ${userProfile["name"]}, here are some self-care tips curated for you ❤️",
              style: TextStyle(fontSize: 16),
            ),

            sectionTitle("Skincare Tips for Moms"),
            videoTile("Skincare for Pregnant Women", "https://www.youtube.com/watch?v=ac5IyS4F6m8"),
            videoTile("Postpartum Skincare Routine", "https://www.youtube.com/watch?v=0ue6Zw_2Kzg"),
            videoTile("Healthcare After Miscarriage", "https://www.youtube.com/watch?v=u0Lsdlq5mfo"),

            sectionTitle("Healthy Food Habits"),
            videoTile("Top 10 Foods During Pregnancy", "https://www.youtube.com/watch?v=3GTK6MLPJ9g"),
            videoTile("Nutrition for Breastfeeding Moms", "https://www.youtube.com/watch?v=VyvhWppQnVE"),
            videoTile("Foods to Avoid After Miscarriage", "https://www.youtube.com/watch?v=p3QHTdSxljA"),


          ],
        ),
      ),
    );
  }
}
