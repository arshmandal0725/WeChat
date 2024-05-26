import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message_model.dart';
import 'package:we_chat/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

List<Message> messages = [];
bool _showemoge = false;

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String getTime(String time) {
    final DateTime _time = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(_time).format(context);
  }

  Widget _appBar() {
    return SafeArea(
      child: StreamBuilder(
          stream: API().getUserinfo(widget.user),
          builder: (context, snapshots) {
            final data = snapshots.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Container(
              height: kToolbarHeight,
              child: Center(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 180, 229, 206),
                      radius: 22,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: (list.isNotEmpty)
                              ? list[0].Image
                              : widget.user.Image,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          (list.isNotEmpty) ? list[0].Name : widget.user.Name,
                          style: TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 45),
                          child: Text(
                            (list.isNotEmpty)
                                ? (list[0].isOnline)
                                    ? "Online"
                                    : "last seen at ${getTime(list[0].lastLogin)}"
                                : "last seen at ${getTime(widget.user.lastLogin)}",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      API().sendMessage(widget.user, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 246, 239),
      appBar: AppBar(
        flexibleSpace: _appBar(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: API().getMessages(widget.user),
                  builder: (ctx, snapshots) {
                    if (snapshots.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshots.hasError) {
                      return Center(child: Text('Error: ${snapshots.error}'));
                    } else if (!snapshots.hasData ||
                        snapshots.data!.docs.isEmpty) {
                      return Center(
                          child: Text(
                        'Say Hiii 👋',
                        style: TextStyle(fontSize: 20),
                      ));
                    } else {
                      messages.clear();
                      for (var doc in snapshots.data!.docs) {
                        messages.add(Message.fromJson(doc.data()));
                      }
                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (ctx, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: MessageCard(message: messages[index]),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _showemoge = !_showemoge;
                                });
                              },
                              icon: Icon(Icons.emoji_emotions)),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Type Message...',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.photo)),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.camera_alt_outlined)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      backgroundColor: Color.fromARGB(255, 51, 188, 122),
                      shape: CircleBorder(),
                    ),
                    onPressed: _sendMessage,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: height * 0.04,
                    ),
                  )
                ],
              ),
              if (_showemoge)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.34,
                  child: EmojiPicker(
                    textEditingController:
                        _messageController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: Config(
                        height: 256,
                        bottomActionBarConfig:
                            BottomActionBarConfig(enabled: false)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
