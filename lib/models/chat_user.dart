class ChatUser {
  ChatUser({
    required this.About,
    required this.isOnline,
    required this.Id,
    required this.createdAt,
    required this.lastLogin,
    required this.pushToken,
    required this.Name,
    required this.Image,
    required this.Email,
  });
  late String About;
  late bool isOnline;
  late String Id;
  late String createdAt;
  late String lastLogin;
  late String pushToken;
  late String Name;
  late String Image;
  late String Email;

  ChatUser.fromJson(Map<String, dynamic> json) {
    About = json['About'];
    isOnline = json['is_online'];
    Id = json['Id'];
    createdAt = json['created_at'];
    lastLogin = json['last_login'];
    pushToken = json['push_token'];
    Name = json['Name'];
    Image = json['Image'];
    Email = json['Email'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['About'] = About;
    _data['is_online'] = isOnline;
    _data['Id'] = Id;
    _data['created_at'] = createdAt;
    _data['last_login'] = lastLogin;
    _data['push_token'] = pushToken;
    _data['Name'] = Name;
    _data['Image'] = Image;
    _data['Email'] = Email;
    return _data;
  }
}
