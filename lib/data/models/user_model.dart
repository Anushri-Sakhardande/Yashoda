class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String location;
  final double latitude;
  final double longitude;
  final int? pregnancyWeeks; // Only for pregnant mothers
  final int? babyMonths; // Only for new mothers
  final List<String>? assignedAdmin; // List of admin UIDs
  final List<String>? assignedUsers; // List of user UIDs

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.pregnancyWeeks,
    this.babyMonths,
    this.assignedAdmin,
    this.assignedUsers,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "pregnancyWeeks": pregnancyWeeks,
      "babyMonths": babyMonths,
      "assignedAdmin": assignedAdmin,
      "assignedUsers": assignedUsers,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map["name"],
      email: map["email"],
      role: map["role"],
      location: map["location"],
      latitude: map["latitude"],
      longitude: map["longitude"],
      pregnancyWeeks: map["pregnancyWeeks"],
      babyMonths: map["babyMonths"],
      assignedAdmin: List<String>.from(map["assignedAdmin"] ?? []),
      assignedUsers: List<String>.from(map["assignedUsers"] ?? []),
    );
  }
}
