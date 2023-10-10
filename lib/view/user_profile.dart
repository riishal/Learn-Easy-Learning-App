import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_easy/models/user_model.dart';
import 'package:learn_easy/service/ui_helper.dart';

class UserProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const UserProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 242, 237),
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[800])),
          backgroundColor: const Color.fromARGB(255, 250, 242, 237),
          elevation: 0,
          title: Text(
            "Your Profile",
            style: GoogleFonts.adamina(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          centerTitle: true),
      body: SafeArea(
          child: Container(
        color: const Color.fromARGB(255, 250, 242, 237),
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        height: size.height / 0,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 70,
              backgroundImage: NetworkImage(widget.userModel.profilepic!),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.userModel.fullName!,
              style: GoogleFonts.adamina(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            SizedBox(
              height: 10,
            ),
            container1("Email", widget.userModel.email),
            SizedBox(
              height: 10,
            ),
            container1("Class", widget.userModel.class0),
            SizedBox(
              height: 10,
            ),
            container1("Location", widget.userModel.location),
            SizedBox(
              height: 10,
            ),
            container1("Age", widget.userModel.age),
            SizedBox(
              height: 17,
            ),
            SizedBox(
              height: 50,
              width: 300,
              child: ElevatedButton(
                child: Text(
                  "Log Out",
                  style: GoogleFonts.adamina(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  UIHelper.showLogOut(context);
                },
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget container1(title, subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
        // boxShadow: [
        //   BoxShadow(color: Colors.grey, blurRadius: 2, offset: Offset(1, 2))
        // ]
      ),
      width: double.infinity,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(
              width: 20,
            ),
            Text(
              "$title :  $subtitle",
              style: GoogleFonts.adamina(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[800]),
            )
          ]),
        ],
      ),
    );
  }
}
