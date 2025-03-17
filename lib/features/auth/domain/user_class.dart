class User {
  late int id;
  late String username;
  late String password;
  late String canvas_web_id;
  late String user_web_id;

  User({required this.id, required this.username, required this.password, required this.canvas_web_id, required this.user_web_id});

  Map<String, dynamic> toJson() =>
      {
        '"id"': '$id',
        '"username"': '"$username"',
        '"password"': '"$password"',
        '"canvas_web_id"': '"$canvas_web_id"',
        '"user_web_id"': '"$user_web_id"',
      };

  static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    password: json['password'],
    canvas_web_id: json['canvas_web_id'],
    user_web_id: json['user_web_id'],
  );
}
