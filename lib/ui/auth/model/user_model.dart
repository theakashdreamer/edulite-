class UserModel {
  final String userId;
  final String name;
  final String mobile;

  UserModel({
    required this.userId,
    required this.name,
    required this.mobile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      name: json['name'],
      mobile: json['mobile'],
    );
  }
}
