import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message_model.dart';
import 'package:we_chat/screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.userdata});
  final ChatUser userdata;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    Message? _message;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChatScreen(user: widget.userdata)));
      },
      child: StreamBuilder(
          stream: API().getLastMessage(widget.userdata),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }
            return Container(
              height: height * 0.08,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 232, 246, 239),
                  borderRadius: BorderRadius.circular(18)),
              child: Center(
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 180, 229, 206),
                      radius: 25,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          height: 50,
                          child: CachedNetworkImage(
                            imageUrl: widget.userdata.Image,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return Icon(Icons.person);
                            },
                          ),
                        ),
                      )),
                  title: Text(
                    widget.userdata.Name,
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: (_message != null)?Text(_message!.msg):Text(widget.userdata.About),
                  trailing: Text(
                    '12 p.m',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
