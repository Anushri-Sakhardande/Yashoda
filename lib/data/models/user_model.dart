class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String location;
  final int? pregnancyWeeks; // Only for pregnant mothers
  final int? babyMonths; // Only for new mothers

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.location,
    this.pregnancyWeeks,
    this.babyMonths,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      "location": location,
      "pregnancyWeeks": pregnancyWeeks,
      "babyMonths": babyMonths,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map["name"],
      email: map["email"],
      role: map["role"],
      location: map["location"],
      pregnancyWeeks: map["pregnancyWeeks"],
      babyMonths: map["babyMonths"],
    );
  }
}
