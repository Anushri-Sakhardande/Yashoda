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
  List<Map<String, dynamic>> allAdmins = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllAdmins();
  }

  Future<void> _fetchAllAdmins() async {
    setState(() => isLoading = true);

    QuerySnapshot adminsSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "Health Administrator")
        .get();

    List<Map<String, dynamic>> results = adminsSnapshot.docs.map((doc) {
      Map<String, dynamic> adminData = doc.data() as Map<String, dynamic>;
      return {
        "uid": doc.id,
        "name": adminData["name"] ?? "Unknown",
        "location": adminData["location"] ?? "No location"
      };
    }).toList();

    setState(() {
      allAdmins = results;
      searchResults = results; // Show all initially
      isLoading = false;
    });
  }

  void _searchAdmins(String query) {
    if (query.isEmpty) {
      setState(() => searchResults = allAdmins);
      return;
    }

    List<Map<String, dynamic>> filtered = allAdmins.where((admin) {
      return admin["name"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => searchResults = filtered);
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
              onChanged: _searchAdmins, // Filter as user types
              decoration: InputDecoration(
                labelText: "Search Admin by Name",
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
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
