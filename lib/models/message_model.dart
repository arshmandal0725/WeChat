class Message {
  Message({
    required this.toId,
    required this.type,
    required this.msg,
    required this.read,
    required this.fromId,
    required this.sent,
  });
  late final String toId;
  late final String type;
  late final String msg;
  late final String read;
  late final String fromId;
  late final String sent;
  
  Message.fromJson(Map<String, dynamic> json){
    toId = json['toId'];
    type = json['type'];
    msg = json['msg'];
    read = json['read'];
    fromId = json['fromId'];
    sent = json['sent'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['toId'] = toId;
    _data['type'] = type;
    _data['msg'] = msg;
    _data['read'] = read;
    _data['fromId'] = fromId;
    _data['sent'] = sent;
    return _data;
  }
}