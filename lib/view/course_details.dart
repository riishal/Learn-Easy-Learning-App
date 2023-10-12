import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

enum ButtonState { download, cancel, pause, resume, reset }

class _CourseDetailsState extends State<CourseDetails>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Future<void>? initializeVideoPlayerFuture;
  TabController? tabController;
  bool isExist = false;

  ButtonState buttonState = ButtonState.download;
  bool downloadWithError = false;
  TaskStatus? downloadTaskStatus;
  DownloadTask? backgroundDownloadTask;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    initPlayer(widget.data[buttonIndex]["videos"].first["videoLink"],
        widget.data[buttonIndex]["videos"].first["videoName"]);
    super.initState();
  }

  initPlayer(url, fileName) {
    videoPlayerController?.dispose();
    chewieController?.dispose();

    String path =
        "/data/user/0/com.example.learn_easy/app_flutter/my/directory/$fileName.mp4";

    isExist = File(path).existsSync();
    print("///////////////////////////////////////////////////$isExist");

    videoPlayerController = isExist
        ? VideoPlayerController.file(File(path))
        : VideoPlayerController.networkUrl(Uri.parse(url));
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

  /// Process center button press (initially 'Download' but the text changes
  /// based on state)
  Future<void> processButtonPress(String url, String fileName) async {
    switch (buttonState) {
      case ButtonState.download:
        // start download
        backgroundDownloadTask = DownloadTask(
          url: url,
          filename: '$fileName.mp4',
          directory: 'my/directory',
          baseDirectory: BaseDirectory.applicationDocuments,
          updates: Updates.statusAndProgress,
          allowPause: true,
        );
        await FileDownloader().enqueue(backgroundDownloadTask!);
        break;
      case ButtonState.cancel:
        // cancel download
        if (backgroundDownloadTask != null) {
          await FileDownloader()
              .cancelTasksWithIds([backgroundDownloadTask!.taskId]);
          // scaffold
        }
        break;
      case ButtonState.reset:
        downloadTaskStatus = null;
        buttonState = ButtonState.download;
        break;
      case ButtonState.pause:
        if (backgroundDownloadTask != null) {
          await FileDownloader().pause(backgroundDownloadTask!);
        }
        break;
      case ButtonState.resume:
        if (backgroundDownloadTask != null) {
          await FileDownloader().resume(backgroundDownloadTask!);
        }
        break;
    }
    String filePath = await backgroundDownloadTask!.filePath();
    debugPrint('////////////////////// filePath: $filePath');
    if (mounted) {
      setState(() {});
    }
  }

  void downLoadVideo(String url, fileName) async {
    processButtonPress(url, fileName);
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
                icon: const Icon(Icons.arrow_back)),
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
                        return const AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Center(child: CircularProgressIndicator()));
                      }
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(controller: chewieController!),
                      );
                    })
                : const Text("Click and paly"),
            const SizedBox(
              height: 5,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              height: size.height / 1.87,
              child: Column(children: [
                SizedBox(
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
                            const SizedBox(
                              height: 9,
                            ),
                            Text(
                              "${widget.data[buttonIndex]["ChapterNo"].toString()} Chaters | ${widget.data[buttonIndex]["Hours"].toString()} Hours",
                              style: GoogleFonts.adamina(
                                  letterSpacing: 1, fontSize: 15),
                            ),
                            const SizedBox(
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
                        GestureDetector(
                          onTap: () {
                            downLoadVideo(
                                widget.data[buttonIndex]["videos"][buttonIndex1]
                                    ["videoLink"],
                                widget.data[buttonIndex]["videos"][buttonIndex1]
                                    ["videoName"]);
                          },
                          child: isExist
                              ? Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.orange,
                                  child: Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 40,
                                  ),
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
                    tabs: const [
                      Tab(
                        text: "Videos",
                      ),
                      Tab(text: "Study Materials"),
                    ],
                  ),
                ),
                const SizedBox(
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
                                    initPlayer(
                                        widget.data[buttonIndex]["videos"]
                                                [index]["videoLink"]
                                            .toString(),
                                        widget.data[buttonIndex]["videos"]
                                                [index]["videoName"]
                                            .toString());
                                    buttonIndex1 = index;
                                  });
                                },
                                child: Row(children: [
                                  const SizedBox(
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
                      separatorBuilder: (context, index) => const SizedBox(
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
                                  const SizedBox(
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
                      separatorBuilder: (context, index) => const SizedBox(
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
