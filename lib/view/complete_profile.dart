import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:learn_easy/models/user_model.dart';
import 'package:learn_easy/service/ui_helper.dart';
import 'package:learn_easy/view/home_page.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? cropedImage = await ImageCropper.platform.cropImage(
      sourcePath: file.path,
      // aspectRatio: CropAspectRatio(
      //   ratioX: 1,
      //   ratioY: 1,
      // ),
      // compressQuality: 20
    );
    if (cropedImage != null) {
      setState(() {
        imageFile = File(cropedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Profile Picture'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            onTap: () {
              selectImage(ImageSource.gallery);
              // pickImageFromGallery();
              Navigator.pop(context);
            },
            leading: Icon(Icons.photo_album),
            title: Text('Select from gallery'),
          ),
          ListTile(
            onTap: () {
              selectImage(ImageSource.camera);
              // selectImageFromCamera();
              Navigator.pop(context);
            },
            leading: Icon(Icons.camera),
            title: Text('Take a Photo'),
          )
        ]),
      ),
    );
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    String class0 = classController.text.trim();
    String age = ageController.text.trim();
    String location = locationController.text.trim();
    if (fullname == "" ||
        imageFile == null ||
        class0 == "" ||
        age == "" ||
        location == "") {
      UIHelper.showAlertDialog(context, "Incomplite Data",
          "Please fill all the fields and upload a profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Loading...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullNameController.text.trim();
    String class0 = classController.text.trim();
    String age = ageController.text.trim();
    String location = locationController.text.trim();
    widget.userModel.fullName = fullname;
    widget.userModel.profilepic = imageUrl;
    widget.userModel.class0 = class0;
    widget.userModel.age = age;
    widget.userModel.location = location;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print('Data Uploaded');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/image/c_profile.png"))),
                ),
                Text(
                  "Complete Your Profile",
                  style: GoogleFonts.adamina(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                ),
                SizedBox(
                  height: 7,
                ),
                Stack(
                  children: [
                    CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        backgroundImage:
                            imageFile != null ? FileImage(imageFile!) : null,
                        radius: 70,
                        child: imageFile == null
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 90,
                              )
                            : null),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: IconButton(
                            onPressed: () {
                              showPhotoOptions();
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.grey,
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    height: size.height * 0.074,
                    width: size.width * 0.89,
                    child: TextFormField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                          hintText: "Full Name",
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ))),
                SizedBox(
                  height: 19,
                ),
                Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.grey,
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    height: size.height * 0.074,
                    width: size.width * 0.89,
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: classController,
                        decoration: InputDecoration(
                          hintText: "Class",
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ))),
                SizedBox(
                  height: 19,
                ),
                Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.grey,
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    height: size.height * 0.074,
                    width: size.width * 0.89,
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: ageController,
                        decoration: InputDecoration(
                          hintText: "Age",
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ))),
                const SizedBox(
                  height: 19,
                ),
                Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.grey,
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    height: size.height * 0.074,
                    width: size.width * 0.89,
                    child: TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: "Location",
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ))),
                const SizedBox(
                  height: 22,
                ),
                SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        checkValues();
                      },
                      child: Text(
                        "Submit",
                        style: GoogleFonts.adamina(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
