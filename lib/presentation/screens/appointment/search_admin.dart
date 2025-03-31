import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchAdminScreen extends StatefulWidget {
  final String userUID;

  SearchAdminScreen({required this.userUID});

  @override
  _SearchAdminScreenState createState() => _SearchAdminScreenState();
}

class _SearchAdminScreenState extends State<SearchAdminScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  void _searchAdmins(String query) async {
    if (query.isEmpty) return;

    setState(() => isLoading = true);

    QuerySnapshot adminsSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "Health Administrator")
        .get();

    List<Map<String, dynamic>> results = [];
    for (var doc in adminsSnapshot.docs) {
      Map<String, dynamic> adminData = doc.data() as Map<String, dynamic>;
      if (adminData["name"].toLowerCase().contains(query.toLowerCase())) {
        results.add({
          "uid": doc.id,
          "name": adminData["name"],
          "location": adminData["location"]
        });
      }
    }

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void _assignAdmin(String adminUID, String adminName) async {
    await FirebaseFirestore.instance.collection("users").doc(widget.userUID).update({
      "assignedAdmin": adminUID
    });

    Navigator.pop(context, {"uid": adminUID, "name": adminName});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Health Admin")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Admin by Name",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchAdmins(searchController.text),
                ),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  var admin = searchResults[index];
                  return ListTile(
                    title: Text(admin["name"]),
                    subtitle: Text("Location: ${admin["location"]}"),
                    trailing: ElevatedButton(
                      onPressed: () => _assignAdmin(admin["uid"], admin["name"]),
                      child: Text("Select"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
