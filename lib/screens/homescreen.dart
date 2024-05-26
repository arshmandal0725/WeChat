import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:we_chat/widgets/chatusercard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> users = [];
  List<ChatUser> filteredUsers = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      filterUsers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterUsers() {
    List<ChatUser> results = [];
    if (searchController.text.isEmpty) {
      results = users;
    } else {
      results = users
          .where((user) => user.Name.toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 196, 250, 225),
        centerTitle: true,
        leading: IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.home)),
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              )
            : Text(
                'We Chat',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  filteredUsers = users;
                  searchController.clear();
                }
              });
            },
            icon: Icon(isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () {
              final currentUser = API().firebaseAuth.currentUser;
              if (currentUser != null) {
                final user = users.firstWhere(
                  (user) => user.Id == currentUser.uid,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => ProfileScreen(currentUser: user)),
                );
              }
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        child: StreamBuilder(
          stream: API().firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Something went wrong!'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No users found.'));
            } else {
              final data = snapshot.data!.docs;
              users = data.map((doc) {
                final userData = doc.data() as Map<String, dynamic>;
                return ChatUser.fromJson(userData);
              }).toList();

              if (!isSearching) {
                filteredUsers = users;
              }

              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (ctx, index) {
                  return Column(
                    children: [
                      (filteredUsers[index].Id !=
                              API().firebaseAuth.currentUser!.uid)
                          ? ChatUserCard(userdata: filteredUsers[index])
                          : Container(),
                      SizedBox(height: 10),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
