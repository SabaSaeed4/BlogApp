import 'dart:io';
import 'package:blogapp/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class Blog extends StatefulWidget {
  @override
  _BlogState createState() => _BlogState();
}

class _BlogState extends State<Blog> {
  //
  File? selectedImage;
  final picker = ImagePicker();

  bool isLoading = false;

  Database crudMethods = new Database();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final imagetemp = File(pickedFile.path);
    setState(() {
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadBlog() async {
    if (selectedImage != null) {
      // upload the image

      setState(() {
        isLoading = true;
      });
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(9)}.jpg");

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var imageUrl;
      await task.whenComplete(() async {
        try {
          imageUrl = await firebaseStorageRef.getDownloadURL();
        } catch (onError) {
          print("Error");
        }

        print(imageUrl);
      });

      // print(downloadUrl);

      Map<String, dynamic> blogData = {
        "imgUrl": imageUrl,
        "author": authorTextEditingController.text,
        "title": titleTextEditingController.text,
        "desc": descTextEditingController.text
      };

      crudMethods.addData(blogData).then((value) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      });

      // upload the blog info
    }
  }

  //
  TextEditingController titleTextEditingController =
      new TextEditingController();
  TextEditingController descTextEditingController = new TextEditingController();
  TextEditingController authorTextEditingController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Create Blog")),
        actions: [
          GestureDetector(
            onTap: () {
              uploadBlog();
            },
            child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.file_upload)),
          )
        ],
      ),
      body: isLoading
          ? Container(
              child: Center(
              child: CircularProgressIndicator(),
            ))
          : SingleChildScrollView(
              child: Center(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: selectedImage != null
                              ? Container(
                                  height: 300,
                                  margin: EdgeInsets.symmetric(vertical: 24),
                                  width: MediaQuery.of(context).size.width,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 300,
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 24),
                                  width: MediaQuery.of(context).size.width,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        TextField(
                          controller: titleTextEditingController,
                          decoration: const InputDecoration(
                            hintText: "Enter Title",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: descTextEditingController,
                          decoration: const InputDecoration(
                              hintText: "Enter description",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ))),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: authorTextEditingController,
                          decoration: const InputDecoration(
                              hintText: "Author name",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ))),
                        ),
                      ],
                    )),
              ),
            ),
    );
  }
}
