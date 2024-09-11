// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frca/model_and_service/frca_service.dart';
import 'package:frca/pages/login_page.dart';
import 'package:frca/pages/not_registered.dart';
import 'package:frca/pages/notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  //Location service
  LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best, distanceFilter: 0);
  void userPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    //just listening to get accurate location early
    // StreamSubscription<Position> positionStream =
    //     Geolocator.getPositionStream(locationSettings: locationSettings)
    //         .listen((Position? position) {
    //   //Just listening to get the coordinates faster
    // });
  }

  bool initRecognition = false;
  String recognitionStatus = "waiting";
  bool checkSend = false;

  //camera variables
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  bool _isCameraInitialized = false;

  Future<void> startCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[1],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await cameraController.initialize();
        cameraController.setZoomLevel(1.4);

        if (!mounted) return;

        _isCameraInitialized = true;
      }
    } catch (e) {
      // print('Error initializing camera: $e');
    }
  }

  Future<void> setlocalStore(String type) async {
    switch (type) {
      case "bio":
        var localStorage = await SharedPreferences.getInstance();
        await localStorage.setString("verify_status", "false");
        break;
      default:
        var localStorage = await SharedPreferences.getInstance();
        await localStorage.setString("access_token", "");
    }
  }

  @override
  void initState() {
    userPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        strokeWidth: 2.5,
        color: const Color.fromARGB(255, 114, 189, 255),
        child: FutureBuilder(
          future: getStudentProfile(),
          builder: (context, snapshot) {
            try {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child:
                      Image.asset('lib/images/cloudloading.gif', height: 220),
                );
              } else if (snapshot.hasData) {
                //checking if stored koken is valid
                if (snapshot.data
                    .containsValue("Could not validate credentials")) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setlocalStore("token");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                  "Session has expired, please re-authenticate",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 16)),
                            )
                          ],
                        ),
                        backgroundColor: Color.fromARGB(255, 255, 119, 110),
                        padding: EdgeInsets.all(25),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  });
                  return Container();
                } else {
                  final data = snapshot.data["profile"];
                  final notifications = List.from(
                      snapshot.data?["profile"]["notifications"].reversed ??
                          [].reversed);
                  final upcomingClasses = snapshot.data["upcoming_classes"];
                  if (data == null || !data.containsKey("is_face_enrolled")) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('lib/images/Warning.gif', height: 300),
                          const Text(
                            "Oops! Something went wrong",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              color: Color.fromARGB(177, 158, 158, 158),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              setState(() {});
                            },
                            child: const Text(
                              "Tap here to refresh",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                color: Color.fromARGB(177, 158, 158, 158),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  //checking bio status
                  if (data["is_face_enrolled"] != true) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setlocalStore("bio");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotRegistered(),
                        ),
                      );
                    });
                    return Container(); // Return an empty container to avoid UI issues.
                  }

                  final currentSemesterAttendances =
                      (data["student_current_semester"] == 1)
                          ? data["allowed_courses"]
                                  [(data["student_current_level"] ~/ 100) - 1]
                              ["first_semester_courses"]
                          : data["allowed_courses"]
                                  [(data["student_current_level"] ~/ 100) - 1]
                              ["second_semester_courses"];

                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          children: [
                            _buildGreeting(data["student_name"], notifications),
                            const SizedBox(height: 20),
                            _buildStudentInfo(
                              data["student_current_level"],
                              data["student_current_semester"],
                              data["student_college"],
                              data["student_department"],
                            ),
                            const SizedBox(height: 20),
                            _buildSectionHeader("All course attendances"),
                            const SizedBox(height: 10),
                            _buildAllCourseAttendances(data["allowed_courses"]),
                            const SizedBox(height: 20),
                            _buildSectionHeader("Current attendances"),
                            _buildCurrentAttendances(
                                currentSemesterAttendances),
                            const SizedBox(height: 20),
                            _buildSectionHeader("Upcoming Classes"),
                            _buildUpcomingClasses(
                                upcomingClasses, data["student_name"]),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
              return Container();
            } catch (e) {
              // Handle any other unexpected state.
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('lib/images/Warning.gif', height: 300),
                    const Text(
                      "Oops! Something went wrong",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        color: Color.fromARGB(177, 158, 158, 158),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {});
                      },
                      child: const Text(
                        "Tap here to refresh",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          color: Color.fromARGB(177, 158, 158, 158),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  //widget builds
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 117, 117, 117)),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(name, notifications) {
    int notifyCount = 0;
    bool notify = false;
    for (int i = 0; i < notifications.length; i++) {
      if (notifications[i]["details"]["is_read"] == false) {
        notifyCount++;
        notify = true;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hi, $name',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()),
                ),
            child: notify
                // ignore: dead_code
                ? badges.Badge(
                    badgeContent: Text(
                      notifyCount.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      padding: EdgeInsets.all(8),
                    ),
                    child: const Icon(
                      Icons.circle_notifications_rounded,
                      size: 40,
                      color: Color.fromARGB(255, 114, 189, 255),
                    ))
                : const Icon(
                    Icons.circle_notifications_rounded,
                    size: 40,
                    color: Color.fromARGB(255, 114, 189, 255),
                  )),
      ],
    );
  }

  Widget _buildStudentInfo(level, semester, college, department) {
    return Container(
      height: 215,
      width: 400,
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage('lib/images/Classroom-rafiki.png'),
            alignment: Alignment.centerRight,
            opacity: 0.8),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(201, 202, 202, 202),
              blurRadius: 1,
              blurStyle: BlurStyle.outer)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
              leading: const Icon(
                Icons.label_outlined,
                color: Colors.blueAccent,
              ),
              title: Text(
                "Level $level",
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15),
              ),
              dense: true,
            ),
            ListTile(
              leading: const Icon(
                Icons.assessment_outlined,
                color: Colors.red,
              ),
              title: Text("Semester $semester",
                  style:
                      const TextStyle(fontFamily: 'Montserrat', fontSize: 15)),
              dense: true,
            ),
            ListTile(
              leading: const Icon(
                Icons.class_outlined,
                color: Colors.yellow,
              ),
              title: Text(college,
                  style:
                      const TextStyle(fontFamily: 'Montserrat', fontSize: 15)),
              dense: true,
            ),
            Expanded(
              child: ListTile(
                leading: const Icon(
                  Icons.school_outlined,
                  color: Colors.orange,
                ),
                title: Text(department,
                    style: const TextStyle(
                        fontFamily: 'Montserrat', fontSize: 15)),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCourseAttendances(data) {
    //custom widget builder
    List customWidgets = [];
    for (var i = 0; i < data.length; i++) {
      customWidgets.add(
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                showDragHandle: true,
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Level ${data[i]["level"]}',
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),

                        //Show first semester courses
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                showDragHandle: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: 510,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: ListView.builder(
                                        itemCount: data[i]
                                                ["first_semester_courses"]
                                            .length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 7),
                                            child: ListTile(
                                              leading: const Icon(
                                                Icons.bookmark_outline,
                                                color: Color.fromARGB(
                                                    255, 114, 189, 255),
                                              ),
                                              title: Text(
                                                data[i]["first_semester_courses"]
                                                    [index]["course_title"],
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              subtitle: Text(
                                                "Attendance: ${data[i]["first_semester_courses"][index]["no_of_attendance"]}",
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              shape: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          95, 158, 158, 158),
                                                      width: 1)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.assessment_outlined,
                                color: Colors.red,
                              ),
                              title: const Text(
                                "First Semester",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              subtitle: const Text(
                                "Click to view courses and attendances",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(95, 158, 158, 158),
                                      width: 1)),
                            ),
                          ),
                        ),

                        //Second semester courses
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                showDragHandle: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: 510,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: ListView.builder(
                                        itemCount: data[i]
                                                ["second_semester_courses"]
                                            .length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 7),
                                            child: ListTile(
                                              leading: const Icon(
                                                Icons.bookmark_outline,
                                                color: Color.fromARGB(
                                                    255, 114, 189, 255),
                                              ),
                                              title: Text(
                                                data[i]["second_semester_courses"]
                                                    [index]["course_title"],
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              subtitle: Text(
                                                "Attendance: ${data[i]["second_semester_courses"][index]["no_of_attendance"]}",
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              shape: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          95, 158, 158, 158),
                                                      width: 1)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.assessment_outlined,
                                color: Colors.red,
                              ),
                              title: const Text(
                                "Second  Semester",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              subtitle: const Text(
                                "Click to view courses and attendances",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(95, 158, 158, 158),
                                      width: 1)),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                });
          },
          child: Container(
            height: 60,
            width: 170,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromARGB(201, 202, 202, 202),
                      blurRadius: 1,
                      blurStyle: BlurStyle.outer)
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.view_agenda_rounded,
                  color: Color.fromARGB(255, 114, 189, 255),
                ),
                Text(
                  'Level ${data[i]["level"]}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 30,
      runSpacing: 10,
      children: [...customWidgets],
    );
  }

  Widget _buildCurrentAttendances(data) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
          itemCount: data.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 178,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(201, 202, 202, 202),
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer)
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.bookmark_outline,
                        color: Color.fromARGB(255, 114, 189, 255),
                      ),
                      Text(
                        data[index]["course_title"],
                        style: const TextStyle(fontFamily: 'Montserrat'),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Attendance: ${data[index]["no_of_attendance"]}",
                        style: const TextStyle(fontFamily: 'Montserrat'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildUpcomingClasses(classes, studentName) {
    if (classes == "No Upcoming Classes") {
      return const SizedBox(
        height: 200,
        child: Center(
            child: Text(
          "No Upcoming Classes",
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              color: Color.fromARGB(255, 117, 117, 117)),
        )),
      );
    } else {
      return SizedBox(
        height: 300,
        child: ListView.builder(
            itemCount: classes.length,
            itemBuilder: (BuildContext context, index) {
              //date breakdown
              var startDate = classes[index]["start_time"].split("T")[0];
              var startTime = classes[index]["start_time"].split("T")[1];
              startTime = startTime.split(".")[0];
              var endDate = classes[index]["end_time"].split("T")[0];
              var endTime = classes[index]["end_time"].split("T")[1];
              endTime = endTime.split(".")[0];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    //checking if student has already marked attendance
                    if (classes[index]["attendee_names"]
                        .contains(studentName)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(
                                    "Attendance has already been marked",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16)),
                              )
                            ],
                          ),
                          backgroundColor: Color.fromARGB(255, 255, 119, 110),
                          padding: EdgeInsets.all(25),
                        ),
                      );
                    } else {
                      startCamera();
                      showModalBottomSheet(
                          isScrollControlled: true,
                          showDragHandle: true,
                          context: context,
                          builder: (context) {
                            //checking time contraints
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              //cheking time constrainsts
                              DateTime startTime =
                                  DateTime.parse(classes[index]["start_time"]);
                              DateTime endTime =
                                  DateTime.parse(classes[index]["end_time"]);
                              DateTime currentTime =
                                  DateTime.parse(DateTime.now().toString());
                              //conditions
                              if (!(currentTime.isBefore(startTime)) &&
                                  !(currentTime.isAfter(endTime))) {
                                //Mark attendance

                                //location stream
                                double classLong =
                                    classes[index]["location"]["longitude"];
                                double classLat =
                                    classes[index]["location"]["latitude"];

                                StreamSubscription<Position> positionStream =
                                    Geolocator.getPositionStream(
                                            locationSettings: locationSettings)
                                        .listen((Position? position) {
                                  // print(
                                  //     '${position?.latitude.toString()}, ${position?.longitude.toString()}');

                                  //Setting gps range
                                  if (((position!.latitude - classLat)
                                                  .abs()
                                                  .toStringAsFixed(7) ==
                                              "0.0000000" ||
                                          (position.latitude - classLat)
                                              .abs()
                                              .toStringAsFixed(7)
                                              .contains('0.0000') ||
                                          (position.latitude - classLat)
                                              .abs()
                                              .toStringAsFixed(7)
                                              .contains('0.00000')) &&
                                      ((position.longitude - classLat)
                                                  .abs()
                                                  .toStringAsFixed(7) ==
                                              "0.0000000" ||
                                          (position.longitude - classLong)
                                              .abs()
                                              .toStringAsFixed(7)
                                              .contains('0.0000') ||
                                          (position.longitude - classLong)
                                              .abs()
                                              .toStringAsFixed(7)
                                              .contains('0.00000'))) {
                                    if (checkSend == false) {
                                      // setting states requires the send func to be called several times resulting in 400
                                      setState(() {
                                        initRecognition = true;
                                      });
                                    }
                                  }
                                });

                                //Initialization of facial recognition when location is in range
                                if (!initRecognition) {
                                  //vales changes when location is in range
                                  return SizedBox(
                                      height: 350,
                                      child: Center(
                                          child: Column(
                                        children: [
                                          //Ilustration
                                          Image.asset(
                                            'lib/images/map.gif',
                                            height: 250,
                                            alignment: Alignment.centerLeft,
                                          ),
                                          //message
                                          const Text(
                                            "Making sure you are in class...",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat',
                                              color: Color.fromARGB(
                                                  255, 95, 95, 95),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          //sub message
                                          const Text(
                                            "Stand by for facial recognition",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat',
                                              color: Color.fromARGB(
                                                  255, 95, 95, 95),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )));
                                } else {
                                  switch (recognitionStatus) {
                                    case "success":
                                      return buildStatusWidget(
                                          Icons.verified_rounded,
                                          const Color.fromARGB(
                                              255, 114, 189, 255),
                                          "Attendance marked successfully");
                                    case "failure":
                                      return buildStatusWidget(
                                          Icons.error_outline,
                                          const Color.fromARGB(
                                              255, 255, 68, 68),
                                          "Recognition failed");
                                    default:
                                      //camera view
                                      if (_isCameraInitialized) {
                                        void send() async {
                                          await cameraController
                                              .takePicture()
                                              .then((XFile? file) async {
                                            if (mounted && file != null) {
                                              final File image =
                                                  File(file.path);
                                              //send the image for recognition
                                              recognitionStatus =
                                                  await markAttendance(image,
                                                      classes[index]["_id"]);
                                              setState(() => recognitionStatus =
                                                  recognitionStatus);
                                            }
                                          });
                                        }

                                        if (checkSend == false) {
                                          setState(() => checkSend = true);
                                          send();
                                        }
                                      }
                                      return buildCameraWidget();
                                  }
                                }
                                //----------------------------------------------------------------
                              } else if (currentTime.isBefore(startTime)) {
                                //Not time yet
                                return SizedBox(
                                    height: 350,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        //Ilustration
                                        Image.asset(
                                          'lib/images/time-management-bg.gif',
                                          height: 200,
                                        ),
                                        //message
                                        const Text(
                                          "Class hasn't started yet!!",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Montserrat',
                                            color:
                                                Color.fromARGB(255, 95, 95, 95),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )));
                              } else {
                                //Class over
                                return const SizedBox(
                                    height: 350,
                                    child: Center(
                                        child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          //Icon
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 100,
                                          ),
                                          //message
                                          Text(
                                            "Class session is over!!",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat',
                                              color: Colors.red,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )));
                              }
                            });
                          }).whenComplete(() {
                        if (_isCameraInitialized) {
                          cameraController.dispose();
                          setState(() {
                            _isCameraInitialized = false;
                            initRecognition = false;
                            recognitionStatus = "waiting";
                            checkSend = false;
                          });
                        }
                      });
                    }
                  },
                  child: Container(
                    height: 73,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(201, 202, 202, 202),
                              blurRadius: 1,
                              blurStyle: BlurStyle.outer)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              width: 5,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 114, 189, 255),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              width: 280,
                              child: Column(
                                children: [
                                  Text(
                                    classes[index]["class_name"],
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: Color.fromARGB(146, 0, 0, 0),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    classes[index]["course_title"],
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromARGB(165, 0, 0, 0)),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Start: $startDate   $startTime \nEnd: $endDate  $endTime',
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(165, 0, 0, 0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Image.asset(
                            'lib/images/facial-recognition-icon.png',
                            height: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      );
    }
  }

  Widget buildStatusWidget(IconData icon, Color color, String message) {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 150, color: color),
            const SizedBox(height: 30),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCameraWidget() {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Please standby for scanning',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 200,
              height: 230,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 4,
                  color: const Color.fromRGBO(156, 188, 255, 1),
                ),
              ),
              child: _isCameraInitialized
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      child: SizedBox(
                        height: 230,
                        child: AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: CameraPreview(cameraController),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
