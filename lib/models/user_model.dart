class UserModel {
  String id;
  String name;
  String email;
  String? profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'],
      email: data['email'],
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }
}
