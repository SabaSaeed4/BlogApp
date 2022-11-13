import 'package:blogapp/database.dart';
import 'create_blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Database crudMethods = new Database();

  QuerySnapshot? blogSnapshot;

  @override
  void initState() {
    crudMethods.getData().then((result) {
      blogSnapshot = result;
      setState(() {});
    });
    super.initState();
  }

  Widget blogsList() {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 24),
        itemCount: blogSnapshot?.docs.length,
        itemBuilder: (context, index) {
          return BlogTile(
            author: blogSnapshot?.docs[index].get('author'),
            title: blogSnapshot?.docs[index].get('title'),
            desc: blogSnapshot?.docs[index].get('desc'),
            imgUrl: blogSnapshot?.docs[index].get('imgUrl'),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Blog App")),
        actions: [
          const Tooltip(
            message: 'Add Blog',
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ElevatedButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Blog()));
              },
            ),
          ),
        ],
      ),
      body: Container(
          child: blogSnapshot != null
              ? blogsList()
              : Container(
                  child: const Center(
                  child: CircularProgressIndicator(),
                ))),
    );
  }
}

class BlogTile extends StatelessWidget {
  final String imgUrl, title, desc, author;
  BlogTile(
      {required this.author,
      required this.desc,
      required this.imgUrl,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24, right: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Container(
              margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(19)),
                    child: Image.network(
                      imgUrl,
                      width: MediaQuery.of(context).size.width / 4,
                      fit: BoxFit.cover,
                      height: 90,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                    child: Column(
                      children: [
                        // mainAxisAlignment: MainAxisAlignment.Center,
                        Text(
                          title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$desc',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'By $author'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 20,
            color: Colors.grey,
            thickness: 2,
          )
        ],
      ),
    );
  }
}
