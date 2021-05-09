class User {
  final String username;
  final bool online;

  User(this.username, this.online);

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        online = json['online'];

  Map<String, dynamic> toJson() => {
    'username': username,
    'online': online,
  };
}