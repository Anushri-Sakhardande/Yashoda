import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MentalHealthScreen extends StatelessWidget {
  const MentalHealthScreen({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    const logoYellow = Color(0xFFF4B942); // Rich yellow from logo

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mental Health & Wellness"),
        backgroundColor: logoYellow,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Helpful Articles",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.article, color: logoYellow),
            title: const Text("Understanding Mental Health During Pregnancy"),
            onTap: () => _launchURL("https://pmc.ncbi.nlm.nih.gov/articles/PMC9681705/"),
          ),
          ListTile(
            leading: const Icon(Icons.article, color: logoYellow),
            title: const Text("Coping with Miscarriage"),
            onTap: () => _launchURL("https://pmc.ncbi.nlm.nih.gov/articles/PMC10098777/"),
          ),
          ListTile(
            leading: const Icon(Icons.article, color: logoYellow),
            title: const Text("Postpartum Depression: What You Need to Know"),
            onTap: () => _launchURL("https://pmc.ncbi.nlm.nih.gov/articles/PMC9851410/"),
          ),

          const Divider(thickness: 1, height: 30),

          const Text(
            "Guided Meditations & Breathing Exercises",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.play_circle_fill, color: logoYellow),
            title: const Text("10-Minute Guided Meditation for Moms"),
            onTap: () => _launchURL("https://www.youtube.com/watch?v=inpok4MKVLM"),
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_fill, color: logoYellow),
            title: const Text("5-Minute Deep Breathing Exercise"),
            onTap: () => _launchURL("https://www.youtube.com/watch?v=EYQsRBNYdPk"),
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_fill, color: logoYellow),
            title: const Text("Mindfulness Meditation for Stress & Anxiety"),
            onTap: () => _launchURL("https://www.youtube.com/watch?v=ZToicYcHIOU"),
          ),
        ],
      ),
    );
  }
}
