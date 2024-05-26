import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/message_model.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    String getTime(String time) {
      final DateTime _time =
          DateTime.fromMillisecondsSinceEpoch(int.parse(time));
      return TimeOfDay.fromDateTime(_time).format(context);
    }

    Widget blueMessage() {
      if (widget.message.read.isEmpty) {
        API().updateMessageReadStatus(widget.message);
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 123, 177, 221),
                  border: Border.all(),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14))),
              padding: EdgeInsets.all(10),
              child: Text(widget.message.msg),
            ),
          ),
          Text(
            getTime(widget.message.sent),
            style: TextStyle(fontSize: 13),
          ),
        ],
      );
    }

    Widget greenMessage() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              (widget.message.read.isNotEmpty)
                  ? Icon(
                      Icons.done_all_rounded,
                      color: Colors.blue,
                    )
                  : Icon(
                      Icons.done_all_rounded,
                      color: Colors.grey,
                    ),
              SizedBox(
                width: 5,
              ),
              Text(
                getTime(widget.message.sent),
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(),
                  color: Color.fromARGB(255, 172, 238, 174),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14))),
              padding: EdgeInsets.all(10),
              child: Text(widget.message.msg),
            ),
          ),
        ],
      );
    }

    return API().firebaseAuth.currentUser!.uid == widget.message.fromId
        ? greenMessage()
        : blueMessage();
  }
}
