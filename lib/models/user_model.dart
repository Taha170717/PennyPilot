class UserModel {
  final String id;
  final String username; // used as login id (could be email)
  final String displayName;
  final String passwordHash;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.passwordHash,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'passwordHash': passwordHash,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        passwordHash: json['passwordHash'] as String,
      );
}
