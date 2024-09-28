import "dart:async";
import "dart:io";

import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:frca/model_and_service/frca_service.dart";
import "package:frca/pages/dashboard.dart";
import "package:geolocator/geolocator.dart";
import "package:webview_flutter/webview_flutter.dart";

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  bool notifyStatus = false;

  // Lifecycle management variables
  bool _isModalOpen = false;

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

  @override
  void initState() {
    userPosition();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      if (_isModalOpen) {
        Navigator.pop(context);
        _isModalOpen = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashBoard()),
            );
          },
          child: const Icon(Icons.arrow_back_rounded),
        ),
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 99, 99, 99),
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
              } else if (snapshot.hasError) {
                return _buildErrorState();
              } else if (snapshot.hasData) {
                final studentname = snapshot.data["profile"]["student_name"];
                final data = List.from(
                    snapshot.data?["profile"]["notifications"].reversed ??
                        [].reversed);
                final classes = snapshot.data["upcoming_classes"];
                if (data.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      _buildNotificationTiles(studentname, data, classes),
                    ],
                  );
                }
              }
              return Container();
            } catch (e) {
              return _buildErrorState();
            }
          },
        ),
      ),
    );
  }

  Widget _buildNotificationTiles(String name, List<dynamic> data, classes) {
    return Column(
      children: List.generate(data.length, (index) {
        final notification = data[index];
        bool isRead = notification["details"]["is_read"];
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ListTile(
              onTap: () async {
                if (!(notification["details"]["is_read"])) {
                  markAsRead(notification["_id"]);
                  setState(() {
                    isRead = true;
                  });
                  if (notification["details"].containsKey("link")) {
                    _buildwebView(context, name, data, classes, notification);
                  }
                } else {
                  if (notification["details"].containsKey("link")) {
                    _buildwebView(context, name, data, classes, notification);
                  }
                }
              },
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: isRead
                      ? const Color.fromARGB(68, 208, 208, 208)
                      : const Color.fromARGB(255, 114, 189, 255),
                  width: 1,
                ),
              ),
              leading: const Icon(
                Icons.circle_notifications_rounded,
                color: Color.fromARGB(255, 114, 189, 255),
                size: 35,
              ),
              title: Text(
                notification["title"]?.toString() ?? 'No Title',
                style: const TextStyle(
                  fontFamily: 'Montserrat Bold',
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                notification["details"]["description"]?.toString() ??
                    'No description',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                ),
              ),
              dense: true,
            ),
          );
        });
      }),
    );
  }

  Widget _buildErrorState() {
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

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('lib/images/notifications.gif', height: 240),
              const Text(
                "No new notifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Your notifications will appear here",
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 99, 99, 99),
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCameraWidget() {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          children: [
            const Text(
              'Please standby for scanning...',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: Color.fromARGB(255, 255, 82, 82),
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: 300,
              height: 410,
              child: _isCameraInitialized
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30.0)),
                      child: SizedBox(
                        height: 410,
                        child: AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: CameraPreview(cameraController),
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                      strokeWidth: 5,
                    )),
            ),
          ],
        ),
      ),
    );
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

  void _buildPageModal(BuildContext context, String link) {
    bool isLoading = true;
    bool stopBuild = false;

    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {},
          onPageFinished: (url) {
            if (!stopBuild) {
              setState(() {
                isLoading = false;
                stopBuild = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(link));

    // Method to reload the WebView
    reloadWebView() {
      webViewController.loadRequest(Uri.parse(link));
      setState(() {
        isLoading = true;
        stopBuild = false;
      });
    }

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      showDragHandle: true,
      context: context,
      builder: (context) {
        _isModalOpen = true; // Set the flag to true when modal is shown

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            Future.delayed(const Duration(seconds: 1), () {
              //This is just to rebuild the modal when the page has finished loading
              setState(() {});
            });
            return SizedBox(
                height: 780,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                        backgroundColor: Colors.white12,
                        strokeWidth: 5,
                      ))
                    : Stack(
                        children: [
                          WebViewWidget(controller: webViewController),
                          Positioned(
                            top:
                                12.0, // Position the button 16 pixels from the left
                            right:
                                16.0, // Position the button 16 pixels from the bottom
                            child: FloatingActionButton.small(
                              backgroundColor: Colors.blueAccent[100],
                              onPressed: reloadWebView,
                              child: const Icon(Icons.refresh_rounded,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ));
          },
        );
      },
    ).whenComplete(() {
      // When the modal is closed, reset the flag
      _isModalOpen = false;
    });
  }

  void _buildwebView(BuildContext context, String name, List<dynamic> data,
      classes, notification) {
    //getting current class details
    var currClass;
    if (classes != "No Upcoming Classes") {
      for (int i = 0; i < classes.length; i++) {
        if (classes[i].containsValue(notification["details"]["class_id"])) {
          currClass = classes[i];
          //mark attendance
          //checking if student has already marked attendance
          if (currClass["test_attendee_names"].contains(name)) {
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
                      child: Text("Attendance has already been marked",
                          style: TextStyle(
                              fontFamily: 'Montserrat', fontSize: 16)),
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
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    //cheking time constrainsts
                    DateTime startTime =
                        DateTime.parse(currClass["start_time"]);
                    DateTime endTime = DateTime.parse(currClass["end_time"]);
                    DateTime currentTime =
                        DateTime.parse(DateTime.now().toString());
                    //conditions
                    if (!(currentTime.isBefore(startTime)) &&
                        !(currentTime.isAfter(endTime))) {
                      //Mark attendance

                      //location stream
                      double classLong = currClass["location"]["longitude"];
                      double classLat = currClass["location"]["latitude"];

                      // ignore: unused_local_variable
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
                                    color: Color.fromARGB(255, 95, 95, 95),
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
                                    color: Color.fromARGB(255, 95, 95, 95),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )));
                      } else {
                        switch (recognitionStatus) {
                          case "success":
                            Navigator.of(context).pop();
                            return Container();
                          case "failure":
                            return buildStatusWidget(
                                Icons.error_outline,
                                const Color.fromARGB(255, 255, 68, 68),
                                "Recognition failed");
                          default:
                            //camera view
                            if (_isCameraInitialized) {
                              void send() async {
                                await cameraController
                                    .takePicture()
                                    .then((XFile? file) async {
                                  if (mounted && file != null) {
                                    final File image = File(file.path);
                                    //send the image for recognition
                                    recognitionStatus =
                                        await markTestAttendance(
                                            image,
                                            notification["details"]
                                                ["class_id"]);
                                    setState(() =>
                                        recognitionStatus = recognitionStatus);
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  color: Color.fromARGB(255, 95, 95, 95),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                if (recognitionStatus == "success") {
                  _buildPageModal(context, notification["details"]["link"]);
                }
                setState(() {
                  _isCameraInitialized = false;
                  initRecognition = false;
                  recognitionStatus = "waiting";
                  checkSend = false;
                });
              }
            });
          }
        }
      }
    }
  }
}
