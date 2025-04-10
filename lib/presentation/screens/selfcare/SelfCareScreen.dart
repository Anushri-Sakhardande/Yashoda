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
    final String role = userProfile["role"];
    final String userName = userProfile["name"];

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
              "Hi $userName, here are some self-care tips curated for you ❤️",
              style: TextStyle(fontSize: 16),
            ),

            if (role == "Pregnant") ...[
              sectionTitle("Skincare Tips for Moms"),
              videoTile("Skincare for Pregnant Women", "https://www.youtube.com/watch?v=ac5IyS4F6m8"),
              videoTile("Dermatologist Updated Skincare", "https://www.youtube.com/watch?v=NJ46tKkNTbQ"),
              videoTile("Skincare Ingredients to Avoid During Pregnancy", "https://www.youtube.com/watch?v=v24FJjvIaow"),


              sectionTitle("Healthy Food Habits"),
              videoTile("Top 10 Foods During Pregnancy", "https://www.youtube.com/watch?v=3GTK6MLPJ9g"),
              videoTile("Complete Pregnancy Guide", "https://www.youtube.com/watch?v=_dVuHFdUN0c"),
            ],

            if (role == "Mother") ...[
              sectionTitle("Post-Pregnancy Skincare"),
              videoTile("Postpartum Skincare Routine", "https://www.youtube.com/watch?v=0ue6Zw_2Kzg"),
              videoTile("Skincare for Moms", "https://www.youtube.com/watch?v=UfIMSJmopM8"),


              sectionTitle("Healthy Food Habits"),
              videoTile("Nutrition for Breastfeeding Moms", "https://www.youtube.com/watch?v=VyvhWppQnVE"),
              videoTile("11 Healthy Eating Habits", "https://www.youtube.com/watch?v=4DcEFPayB-Q"),
            ],

            if (role == "Miscarriage") ...[
              sectionTitle("Healing After Miscarriage"),
              videoTile("Common Questions About Miscarriage", "https://www.youtube.com/watch?v=hbYy562ue2w&t=80s"),
              videoTile("Treating Miscarriage", "https://www.youtube.com/watch?v=ugyjaAFsykQ"),
              videoTile("Healthcare After Miscarriage", "https://www.youtube.com/watch?v=u0Lsdlq5mfo"),

              sectionTitle("Food & Wellness Tips"),
              videoTile("Foods to Avoid After Miscarriage", "https://www.youtube.com/watch?v=p3QHTdSxljA"),
              videoTile("Foods that can avoid Miscarriage", "https://www.youtube.com/watch?v=zq6cNVZqZYA&t=106s"),
              videoTile("20 Foods that can cause Miscarriage", "https://www.youtube.com/watch?v=vf7FccpjBg4"),
            ],
          ],
        ),
      ),
    );
  }
}
