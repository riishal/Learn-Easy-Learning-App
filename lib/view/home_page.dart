import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:learn_easy/models/user_model.dart';
import 'package:learn_easy/view/course_details.dart';
import 'package:learn_easy/view/user_profile.dart';

int buttonIndex = 0;
int currentIndex = 0;

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    List color = [Colors.amber, Colors.green, Colors.red];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.grey[800],
          title: Text(
            "Learn Easy",
            style: GoogleFonts.adamina(
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            SizedBox(
              width: 60,
              child: PopupMenuButton(
                onSelected: (value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(
                          firebaseUser: widget.firebaseUser,
                          userModel: widget.userModel,
                        ),
                      ));
                },
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(widget.userModel.profilepic!),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text(
                      "View Your Profile",
                      style: GoogleFonts.adamina(
                        letterSpacing: 1,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 0,
            ),
          ]),
      backgroundColor: const Color.fromARGB(255, 250, 242, 237),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot<Map<String, dynamic>> data =
                  snapshot.data!.docs[index];
              return SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CarouselSlider(
                    items: <Widget>[
                      for (int i = 0; i < color.length; i++)
                        Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                      data["Banners"][i].toString()),
                                  fit: BoxFit.fill),
                              borderRadius: BorderRadius.circular(20)),
                        )
                    ],
                    options: CarouselOptions(
                      aspectRatio: 3 / 4,
                      height: 190,
                      viewportFraction: 0.8,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 1000),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index, reason) {
                        currentIndex = index;
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < color.length; i++)
                        Container(
                          height: 13,
                          width: 13,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: currentIndex == i
                                  ? Colors.blue
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(2, 2))
                              ]),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Suggested Courses",
                      style: GoogleFonts.adamina(
                          letterSpacing: 1,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    height: 17,
                  ),
                  Container(
                    decoration: const BoxDecoration(),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: size.height * 0.45,
                    width: double.infinity,
                    child: ListView.separated(
                        itemBuilder: (context, index) => Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 3,
                                        offset: Offset(2, 2))
                                  ],
                                  borderRadius: BorderRadius.circular(20)),
                              height: size.height * 0.20,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    buttonIndex = index;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CourseDetails(
                                              data: data["Chapters"],
                                              index: index,
                                              firebaseUser: widget.firebaseUser,
                                              userModel: widget.userModel),
                                        ));
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 13),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    data["Chapters"][index]
                                                            ["Image"]
                                                        .toString()),
                                                fit: BoxFit.fill),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        height: size.height * 0.17,
                                        width: size.width * 0.35,
                                      ),
                                      const SizedBox(
                                        width: 13,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        height: size.height * 0.17,
                                        width: size.width * 0.47,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data["Chapters"][index]
                                                      ["ChapterName"]
                                                  .toString(),
                                              style: GoogleFonts.adamina(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(
                                              height: 7,
                                            ),
                                            Text(
                                              "${data["Chapters"][index]["ChapterNo"]} Chapters",
                                              style: GoogleFonts.adamina(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "${data["Chapters"][index]["Hours"]} Hours",
                                              style: GoogleFonts.adamina(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(
                                              height: 9,
                                            ),
                                            Text(
                                              "Mentor: ${data["Chapters"][index]["tutor"]}",
                                              style: GoogleFonts.adamina(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 14,
                            ),
                        itemCount: data["Chapters"].length),
                  )
                ],
              ));
            },
          );
        },
      ),
    );
  }
}
