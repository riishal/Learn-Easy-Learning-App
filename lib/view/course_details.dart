import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_easy/models/user_model.dart';
import 'package:learn_easy/view/home_page.dart';
import 'package:learn_easy/view/user_profile.dart';
import 'package:learn_easy/service/ui_helper.dart';

import 'package:video_player/video_player.dart';

int buttonIndex1 = 0;
int pdfIndex = -1;

class CourseDetails extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final int index;
  final List<dynamic> data;
  const CourseDetails(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.index,
      required this.data});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Future<void>? initializeVideoPlayerFuture;
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    initPlayer(widget.data[buttonIndex]["videos"].first["videoLink"]);
    super.initState();
  }

  initPlayer(url) {
    videoPlayerController?.dispose();
    chewieController?.dispose();

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    initializeVideoPlayerFuture =
        videoPlayerController?.initialize().then((value) {});
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoInitialize: false,
      autoPlay: true,
      aspectRatio: 16 / 9,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 242, 237),
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  buttonIndex1 = 0;
                },
                icon: Icon(Icons.arrow_back)),
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
              SizedBox(
                width: 7,
              ),
            ]),
        body: Column(
          children: [
            videoPlayerController != null
                ? FutureBuilder(
                    future: initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Center(child: CircularProgressIndicator()));
                      }
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(controller: chewieController!),
                      );
                    })
                : Text("Click and paly"),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14),
              height: size.height * 0.53,
              child: Column(children: [
                Container(
                  height: size.height * 0.15,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.data[buttonIndex]["ChapterName"]
                                  .toString(),
                              style: GoogleFonts.adamina(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19),
                            ),
                            SizedBox(
                              height: 9,
                            ),
                            Text(
                              "${widget.data[buttonIndex]["ChapterNo"].toString()} Chaters | ${widget.data[buttonIndex]["Hours"].toString()} Hours",
                              style: GoogleFonts.adamina(
                                  letterSpacing: 1, fontSize: 15),
                            ),
                            SizedBox(
                              height: 9,
                            ),
                            Text(
                              "Mentor: ${widget.data[buttonIndex]["tutor"].toString()}",
                              style: GoogleFonts.adamina(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange,
                          child: Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 40,
                          ),
                        )
                      ]),
                ),
                SizedBox(
                  height: 30,
                  child: TabBar(
                    labelStyle: GoogleFonts.adamina(
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: const Color.fromARGB(255, 246, 116, 61),
                    labelColor: const Color.fromARGB(255, 246, 116, 61),
                    unselectedLabelColor: Colors.grey,
                    controller: tabController,
                    tabs: [
                      Tab(
                        text: "Videos",
                      ),
                      Tab(text: "Study Materials"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: TabBarView(controller: tabController, children: [
                  //tab 1

                  ListView.separated(
                      itemBuilder: (context, index) => Container(
                            height: size.height * 0.11,
                            decoration: BoxDecoration(
                                color: buttonIndex1 == index
                                    ? Colors.blue
                                    : Colors.white,
                                border: Border.all(
                                    color: buttonIndex1 == index
                                        ? Colors.white
                                        : Colors.blue),
                                borderRadius: BorderRadius.circular(10)),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    initPlayer(widget.data[buttonIndex]
                                            ["videos"][index]["videoLink"]
                                        .toString());
                                    buttonIndex1 = index;
                                  });
                                },
                                child: Row(children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 18,
                                    child: Text(
                                      widget.data[buttonIndex]["videos"][index]
                                          ["videoName"],
                                      style: GoogleFonts.adamina(
                                          color: buttonIndex1 == index
                                              ? Colors.white
                                              : Colors.black,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: buttonIndex1 == index
                                          ? Colors.white
                                          : Colors.blue,
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: buttonIndex1 == index
                                            ? Colors.blue
                                            : Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                ]),
                              ),
                            ),
                          ),
                      separatorBuilder: (context, index) => SizedBox(
                            height: 8,
                          ),
                      itemCount: widget.data[buttonIndex]["videos"].length),
                  //tab 2
                  ListView.separated(
                      itemBuilder: (context, index) => Container(
                            height: size.height * 0.11,
                            decoration: BoxDecoration(
                                color: pdfIndex == index
                                    ? Colors.blue
                                    : Colors.white,
                                border: Border.all(
                                    color: pdfIndex == index
                                        ? Colors.white
                                        : Colors.blue),
                                borderRadius: BorderRadius.circular(10)),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  UIHelper.showPdfDialog(
                                      context,
                                      "${widget.data[buttonIndex]["pdf"][index]["pdfName"]}",
                                      "Do you want to open the pdf",
                                      widget.data,
                                      index);

                                  setState(() {
                                    // initPlayer(widget.data[buttonIndex]
                                    //         ["videos"][index]["videoLink"]
                                    //     .toString());
                                    pdfIndex = index;
                                  });
                                },
                                child: Row(children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 18,
                                    child: Text(
                                      widget.data[buttonIndex]["pdf"][index]
                                          ["pdfName"],
                                      style: GoogleFonts.adamina(
                                          color: pdfIndex == index
                                              ? Colors.white
                                              : Colors.black,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 4,
                                      child: Icon(
                                        Icons.picture_as_pdf_sharp,
                                        size: 50,
                                        color: pdfIndex == index
                                            ? Colors.white
                                            : Colors.red,
                                      ))
                                ]),
                              ),
                            ),
                          ),
                      separatorBuilder: (context, index) => SizedBox(
                            height: 8,
                          ),
                      itemCount: widget.data[buttonIndex]["pdf"].length),
                ]))
              ]),
            )
          ],
        ));
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    chewieController!.dispose();
    tabController!.dispose();
    super.dispose();
  }
}
