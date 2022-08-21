import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../helper/sqldb.dart';
import '../../models/drop down/drowdowntypes.dart';
import '../../models/offlineData.dart';
import '../../models/market execution/market_execution.dart';
import '../../services/config.dart';
import '../../services/sharedPref.dart';

class MarketExecution extends StatefulWidget {
  const MarketExecution({Key? key}) : super(key: key);

  @override
  State<MarketExecution> createState() => _MarketExecutionState();
}

class _MarketExecutionState extends State<MarketExecution> {
  SharedPref sharedPref = SharedPref();
  SqlDb sqlDbObj = SqlDb();

  //----------------------------------------------------------
  String picPath =
      '/data/user/0/com.example.attendance_app_e01/cache/8c1b1eba-7ee2-4b13-bce1-9e968b815c132491224018646625388.jpg';

  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // txt feild controller
  TextEditingController outletController = TextEditingController();
  TextEditingController remarkdController = TextEditingController();

  // get image
  File? image;
  // variables
  File? image1, image2, image3, image4, image5;

  String? empNo;
  //String empNo = "100";
  String? empName;
  int? rowcount;

  var _latitude = 'current location';
  var _longittude = 'current location';
  var _altitude = 'current location';
  var _address = 'current location';
  //late String image1 = "logo.png";

  late String responseMsg;

  late String outletName;
  late String remarks;

  late String token;

  bool isLoading = false;
  bool isUploading = false;
  bool _200isOk = true;
  late bool hasofflineInfo;

  List<DropDownTypes> listOfDrofDownValues = [];
  var dropdownvalue;
  late String IdOfSelectedDropDownItem;
  String? IndexOfSelectedDropDownItem;

  bool activeInternet = true;
  late StreamSubscription _streamSubscriptionInternetActiviteInMarketScreen;

  @override
  void initState() {
    super.initState();

    // get empNo
    getEmpNo();

    // read token
    getToken();

    //getOfflineDataInfo();

    // get row count
    getRowCount();

    /// call ckeck internet active
    _streamSubscriptionInternetActiviteInMarketScreen =
        InternetConnectionChecker().onStatusChange.listen((event1) {
      final activeInternet = event1 == InternetConnectionStatus.connected;
      print('event1 ---------------- $activeInternet');
      setState(() {
        this.activeInternet = activeInternet;
        //text = activeInternet ? 'Online' : 'Offline';
      });
    });

    getCurrentPosition();
    getCurrentAddress();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionInternetActiviteInMarketScreen.cancel();
  }

  // methods

  getRowCount() async {
    try {
      // checking local db row count
      rowcount = await sqlDbObj.getRowCount();
      setState(() {
        rowcount = rowcount;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // pick img
  pickImage(int index) async {
    try {
      final commonImg = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 30);

      switch (index) {
        case 1:
          if (commonImg == null) {
            print('imgage 1 --> $image1');
          } else {
            image1 = File(commonImg.path);
            print('imgage 1 --> $image1');
            setState(() {});
          }
          break;

        case 2:
          if (commonImg == null) {
            print('imgage2 --> $commonImg');
          } else {
            image2 = File(commonImg.path);
            //print('imgage2 --> $image2');
            setState(() {});
          }
          break;

        case 3:
          if (commonImg == null) {
            print('imgage 3 --> $image3');
          } else {
            image3 = File(commonImg.path);
            print('imgage 3 --> $image3');
            setState(() {});
          }
          break;

        case 4:
          if (commonImg == null) {
            print('imgage 4 --> $image4');
          } else {
            image4 = File(commonImg.path);
            print('imgage 4 --> $image4');
            setState(() {});
          }
          break;

        case 5:
          if (commonImg == null) {
            print('imgage 5 --> $image5');
          } else {
            image5 = File(commonImg.path);
            print('imgage 5 --> $image5');
            setState(() {});
          }
          break;

        default:
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');

      //show toast
      Fluttertoast.showToast(
        msg: 'Failed to pick image: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // get emp no
  getEmpNo() async {
    // get emp no & name
    empNo = (await sharedPref.readEmpId())!;
    empName = (await sharedPref.readEmpName())!;

    setState(() {});
  }

  // get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      try {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        Fluttertoast.showToast(
          msg: 'Turn on location',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        return Future.error('Location services are disabled.');
      } catch (e) {
        print(e.toString());
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      try {
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          Fluttertoast.showToast(
            msg: 'Turn on location',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          return Future.error('Location permissions are denied');
        }
      } catch (e) {
        print(e.toString());
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Fluttertoast.showToast(
        msg: 'Turn on location',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // get current address
  Future<void> getCurrentAddress() async {
    try {
      Position pos = await getCurrentPosition();

      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      List<Location> locations =
          await locationFromAddress(placemarks[0].toString());

      //
      //print(placemarks);
      Placemark place = placemarks[0];

      setState(() {
        _latitude = pos.latitude.toString();
        _longittude = pos.longitude.toString();
        _altitude = pos.altitude.toString();
        // _address = '${place.street},${place.subLocality}${place.locality}${place.postalCode},${place.country}';
        // _address = '${place.street},${place.subLocality}${place.locality}';
         _address = '${place.street} ${place.subLocality}';
        // _address =
        //     '${place.street}${place.subLocality}${place.locality}${place.country}';
        //_address = 'japan';
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // get token
  getToken() async {
    SharedPref sharedPref = SharedPref();
    token = (await sharedPref.readToken())!;

    getDropDownValues(token);
  }

  // img selection part
  Widget _buildImgsSelect() {
    return Container(
      padding: const EdgeInsets.all(3.0),
      child: Wrap(
        spacing: 1.0,
        children: [
          //1st img
          GestureDetector(
            onTap: () {
              pickImage(1);
            },
            child: Container(
              child: image1 != null
                  ? Image.file(
                      image1!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/image/selfie0.png',
                      width: 100,
                      height: 100,
                    ),
            ),
          ),
          //2nd img
          GestureDetector(
            onTap: () {
              pickImage(2);
            },
            child: Container(
              child: image2 != null
                  ? Image.file(
                      image2!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/image/selfie1.png',
                      width: 100,
                      height: 100,
                    ),
            ),
          ),
          //3rd img
          GestureDetector(
            onTap: () {
              pickImage(3);
            },
            child: Container(
              child: image3 != null
                  ? Image.file(
                      image3!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/image/selfie2.png',
                      width: 100,
                      height: 100,
                    ),
            ),
          ),
          //4th img
          GestureDetector(
            onTap: () {
              pickImage(4);
            },
            child: Container(
              child: image4 != null
                  ? Image.file(
                      image4!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/image/selfie3.png',
                      width: 100,
                      height: 100,
                    ),
            ),
          ),
          //5th img
          GestureDetector(
            onTap: () {
              pickImage(5);
            },
            child: Container(
              child: image5 != null
                  ? Image.file(
                      image5!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/image/selfie4.png',
                      width: 100,
                      height: 100,
                    ),
            ),
          )
        ],
      ),
    );
  }

  // get drop down values
  void getDropDownValues(String token) async {
    try {
      final responseType = await http.get(
          Uri.parse("${Config.BACKEND_URL}market-execution/types"),
          headers: {
            'Authorization': 'Bearer $token',
          });

      if (responseType.statusCode == 200) {
        Map decodedMap = jsonDecode(responseType.body);

        List<dynamic> responseListPart = decodedMap['data'];

        if (responseListPart.isNotEmpty) {
          for (var element in responseListPart) {
            var val_id = element['val_id'];
            var val_des = element['val_des'];

            DropDownTypes dropDownTypesObj =
                DropDownTypes(val_id: val_id, val_des: val_des);
            listOfDrofDownValues.add(dropDownTypesObj);
            // print(listOfDrofDownValues[0].val_des);
          }
        } else {
          // drow down values has
          Fluttertoast.showToast(
            msg: 'Sorry ! Execution Types currnently not available',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }

        print(listOfDrofDownValues[0].val_des);

        // // this set State need to refesh drop down
        setState(() {});
      } else {
        print('Request failed with status: ${responseType..statusCode}');

        Fluttertoast.showToast(
          msg: 'Request failed with status: ${responseType.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // entry feild
  Widget _buildEntryField(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(
            height: 2,
          ),
          TextFormField(
            controller: remarkdController,
            //obscureText: isPassword,
            maxLines: 3,
            decoration: const InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),

            validator: (text) {
              // validate
              if (text!.isEmpty) {
                return "Remarks Required !";
              }

              return null;
            },

            onSaved: (value) {
              remarks = value!.trim();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutletField(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(
            height: 2,
          ),
          TextFormField(
            controller: outletController,
            //obscureText: isPassword,
            maxLines: 1,
            decoration: const InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),

            validator: (text) {
              // validate
              if (text!.isEmpty) {
                return "Outlet Name Required !";
              }

              return null;
            },

            onSaved: (value) {
              outletName = value!.trim();
            },
          ),
        ],
      ),
    );
  }

  // submit button
  Widget _buildSubmitBtn(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 50,
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        buttonColor: const Color(0xFFee3a43), //  <-- dark color
        textTheme: ButtonTextTheme.primary,
        child: RaisedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // execution type
              if (IndexOfSelectedDropDownItem == null) {
                // user not selected
                // show toast
                Fluttertoast.showToast(
                  msg: 'Please Select Execution Type',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              } else {
                // user selected
                // submit
                setState(() {
                  isLoading = true;
                });
                punch();
              }
            } else {
              print("Error in validation state");
            }

            //deleteSumittedDataRow(1);
            //punch();
            //pickImage();
            //uploadImage();

            // saveMarketExecutionData1();
          },
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text(
                  'Submit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  // Sized Box
  Widget _buildSizedBox(double h) {
    return SizedBox(
      height: h,
    );
  }

  // // drop down punch status
  Widget _buildDropDownExecutionType(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    // Initial Value
                    value: dropdownvalue,
                    isExpanded: true,

                    hint: const Text(
                      'Select Punch Status',
                      style: TextStyle(fontSize: 20.0, color: Colors.grey),
                    ),

                    // Down Arrow Icon
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,

                    // Array list of items
                    items: listOfDrofDownValues.map(
                      (DropDownModelClzObj) {
                        var dropdownMenuItem = DropdownMenuItem<DropDownTypes>(
                          value: DropDownModelClzObj,
                          child: Text(
                            DropDownModelClzObj.val_des,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                        return dropdownMenuItem;
                      },
                    ).toList(),

                    // After selecting the desired option,it will
                    // change button value to selected value

                    onChanged: (val) {
                      setState(
                        () {
                          dropdownvalue = val;

                          //remarkController.text = listOfDrofDownValues.indexOf(dropdownvalue).toString();

                          int indexOfSelectedItem =
                              listOfDrofDownValues.indexOf(dropdownvalue);
                          //print(ddtypes[l].val_id);
                          IdOfSelectedDropDownItem =
                              listOfDrofDownValues[indexOfSelectedItem].val_id;

                          IndexOfSelectedDropDownItem =
                              indexOfSelectedItem.toString();

                          print(
                              'Id of selected item --> $IdOfSelectedDropDownItem');
                          print(
                              'Index of selected item --> $IndexOfSelectedDropDownItem');

                          // to
                          //pickImage();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   deleteSumittedDataRow(26);
        // }),
        backgroundColor: const Color(0xff043776),
        appBar: AppBar(
          backgroundColor: const Color(0xff043776),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 17, 0, 10),
              child: Text(
                '$rowcount',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                if (rowcount! > 0) {
                  // show arlet box
                  buildCustomDialog();
                } else {
                  Fluttertoast.showToast(
                    msg: 'Currently you haven\'t offline data',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              icon: isUploading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    )
                  : const Icon(Icons.upload_rounded),
            ),
          ],
          title: const Text("Selfie Punch"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: _buildImgsSelect(),
                    //child: _buildSingleImageView(),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 15.0),
                    child: Text(
                      "Emp No : " " $empNo,$empName",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              _buildSizedBox(5),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child: 
                      Text(
                        // "Bus Stop,Embulgama,Sri Lanka",
                        _address,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white),
                      ),
                  ),
                ],
              ),
              _buildSizedBox(5),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child: Text(
                      DateFormat('yyyy-MM-dd  kk:mm:ss a')
                          .format(DateTime.now()),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              Container(
                margin:
                    const EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      //_buildDropDownType('Punch Status *'),
                      _buildSizedBox(5),
                      _buildDropDownExecutionType("Execution Type *"),
                      _buildSizedBox(5),
                      _buildOutletField('Outlet Name'),
                      _buildSizedBox(5),
                      _buildEntryField('Remarks *'),
                      _buildSizedBox(10),
                      _buildSubmitBtn('Punch'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // internet alert dialog
  Future buildCustomDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (newNotification) {
          return AlertDialog(
            title: const Text('Offline Data'),
            content: const Text('Do you need submit offline data ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  //reloadData();
                  isUploading = true;
                  readMarketExecutionData();
                },
                child: const Text('Submit Data'),
              )
            ],
          );
        });
  }

  punch() async {
    print(activeInternet);
    if (activeInternet) {
      // imgs upload
      SelfieImg selfieImg = SelfieImg();
      bool isDone = await selfieImg.Punch(
        token,
        empNo!,
        _address,
        _longittude,
        _latitude,
        outletName,
        IndexOfSelectedDropDownItem.toString(),
        remarks,
        image1: image1,
        image2: image2,
        image3: image3,
        image4: image4,
        image5: image5,
      );

      // if done
      if (isDone) {
        IndexOfSelectedDropDownItem = null;

        // romove shared ref ---------------------------------------------------------------------------------------------------------------------

        setState(() {
          IndexOfSelectedDropDownItem = null;
          // reset drop down
          dropdownvalue = null;
          // clear txt feilds
          remarkdController.text = '';
          outletController.text = '';
          //clear imgs
          image1 = null;
          image2 = null;
          image3 = null;
          image4 = null;
          image5 = null;

          isLoading = false;
        });
      } else {
        saveMarketExecutionData1();
        // not done
        setState(() {
          IndexOfSelectedDropDownItem = null;
          // reset drop down
          dropdownvalue = null;
          // clear txt feilds
          remarkdController.text = '';
          outletController.text = '';
          //clear imgs
          image1 = null;
          image2 = null;
          image3 = null;
          image4 = null;
          image5 = null;

          isLoading = false;
        });
      }
    } else {
      // add shared ref ---------------------------------------------------------------------------------------------------------------------
      //saveMarketExecutionData();
      // add local db -----------------------------------------------------------------------------------------------------------------
      saveMarketExecutionData1();
      //when internet not available
      print('you are offline');
      setState(() {
        IndexOfSelectedDropDownItem = null;
        isLoading = false;
        remarkdController.text = '';
        outletController.text = '';
        dropdownvalue = null;
        //clear imgs
        image1 = null;
        image2 = null;
        image3 = null;
        image4 = null;
        image5 = null;
      });
      Fluttertoast.showToast(
        msg: 'You are Offline',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // // store market execution data in phone Db ------------------------------------------------------- using shared prf
  // Future<void> saveMarketExecutionData() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   pref.setBool('offlineData', true);
  //   pref.setString('Token', token);
  //   pref.setString('Address', _address);
  //   pref.setString('Longittude', _longittude);
  //   pref.setString('Latitude', _latitude);
  //   pref.setString('OutletName', outletName);
  //   pref.setString('Index', IndexOfSelectedDropDownItem.toString());
  //   pref.setString('Remarks', remarks);

  //   // img add
  //   // 1 img
  //   if (image1?.path != null) {
  //     pref.setString('Img1', image1!.path);
  //   }

  //   // 2 img
  //   if (image2?.path != null) {
  //     pref.setString('Img2', image2!.path);
  //   }

  //   // 3 img
  //   if (image3?.path != null) {
  //     pref.setString('Img3', image3!.path);
  //   }

  //   // 4 img
  //   if (image4?.path != null) {
  //     pref.setString('Img4', image4!.path);
  //   }

  //   // 5 img
  //   if (image5?.path != null) {
  //     pref.setString('Img5', image5!.path);
  //   }

  //   print('Market Execution Data In Local Db');
  // }

  // reloadData() async {
  //   //removeReloadData();

  //   // await getOfflineDataInfo();
  //   // print('in reload method-----------------> $hasofflineInfo');

  //   // Fluttertoast.showToast(
  //   //   msg: 'You have offline data',
  //   //   toastLength: Toast.LENGTH_LONG,
  //   //   gravity: ToastGravity.BOTTOM,
  //   // );

  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String? retoken = pref.getString('Token');
  //   String? readdress = pref.getString('Address');
  //   String? relongittude = pref.getString('Longittude');
  //   String? relatitude = pref.getString('Latitude');

  //   String? reoutletName = pref.getString('OutletName');

  //   String? reIndex = pref.getString('Index');
  //   String? reremarks = pref.getString('Remarks');

  //   String? reimage1 = pref.getString('Img1');
  //   String? reimage2 = pref.getString('Img2');
  //   String? reimage3 = pref.getString('Img3');
  //   String? reimage4 = pref.getString('Img4');
  //   String? reimage5 = pref.getString('Img5');

  //   print('re token = $retoken');
  //   print('re address = $readdress');
  //   print('re longittude = $relongittude');
  //   print('re latitude = $relatitude');
  //   print('re outletname = $reoutletName');
  //   print('re index = $reIndex');
  //   print('re remarks = $reremarks');
  //   print('re img1 = $reimage1');
  //   print('re img2 = $reimage2');
  //   print('re img3 = $reimage3');
  //   print('re img4 = $reimage4');
  //   print('re img5 = $reimage5');

  //   print(activeInternet);
  //   if (activeInternet) {
  //     Fluttertoast.showToast(
  //       msg: 'You are online',
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //     // imgs upload
  //     SelfieImg selfieImg = SelfieImg();
  //     bool isDone = await selfieImg.Punch(
  //       retoken!,
  //       empNo!,
  //       readdress!,
  //       relongittude!,
  //       relatitude!,
  //       reoutletName!,
  //       reIndex!,
  //       reremarks!,
  //       image1: image1,
  //       image2: image2,
  //       image3: image3,
  //       image4: image4,
  //       image5: image5,
  //     );

  //     // if done
  //     if (isDone) {
  //       IndexOfSelectedDropDownItem = null;

  //       // romove shared ref ---------------------------------------------------------------------------------------------------------------------
  //       removeReloadData();
  //       setState(() {
  //         IndexOfSelectedDropDownItem = null;
  //         // reset drop down
  //         // clear txt feilds
  //         remarkdController.text = '';
  //         outletController.text = '';
  //         //clear imgs
  //         image1 = null;
  //         image2 = null;
  //         image3 = null;
  //         image4 = null;
  //         image5 = null;

  //         isLoading = false;
  //       });
  //     } else {
  //       // not done
  //       setState(() {
  //         isLoading = false;
  //         IndexOfSelectedDropDownItem == null;
  //       });
  //     }
  //   } else {
  //     // add shared ref ---------------------------------------------------------------------------------------------------------------------
  //     //saveMarketExecutionData();
  //     //when internet not available
  //     print('you are offline.please retry submit offline data');
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Fluttertoast.showToast(
  //       msg: 'You are offline.Please retry submit offline data',
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //   }
  //   // } else {
  //   //   Fluttertoast.showToast(
  //   //     msg: 'You have not offline data to submit',
  //   //     toastLength: Toast.LENGTH_LONG,
  //   //     gravity: ToastGravity.BOTTOM,
  //   //   );
  //   // }
  // }

  // // remove reload data
  // Future<void> removeReloadData() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   // pref.remove('Token');
  //   pref.setBool('offlineData', false);
  //   pref.remove('Address');
  //   pref.remove('Longittude');
  //   pref.remove('Latitude');

  //   pref.remove('OutletName');

  //   pref.remove('Index');
  //   pref.remove('Remarks');

  //   pref.remove('Img1');
  //   pref.remove('Img2');
  //   pref.remove('Img3');
  //   pref.remove('Img4');
  //   pref.remove('Img5');

  //   print('Reload Data Removed');

  //   setState(() {});
  // }

  // store market execution data in phone Db ------------------------------------------------------- using shared prf
  //

  // insert data
  Future<void> saveMarketExecutionData1() async {
    try {
      String table = 'markettbl';
      Map<String, dynamic> userData = {
        "userid": "$empNo",
        "geo_location": _address,
        "longitude": _longittude,
        "latitude": _latitude,
        "outlet_name": outletName,
        "execution_type": IndexOfSelectedDropDownItem,
        "remarks": remarks,
        "image1": image1?.path,
        "image2": image2?.path,
        "image3": image3?.path,
        "image4": image4?.path,
        "image5": image5?.path,
      };

      int responselocalDb = await sqlDbObj.insertData(table, userData);
      print('$responselocalDb');

      getRowCount();

      Fluttertoast.showToast(
        msg: 'Your submitted data has saved as offline data',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  // read data
  readMarketExecutionData() async {
    try {
      String sql = 'SELECT * FROM markettbl';
      //String sql = 'SELECT * FROM markettbl WHERE id = 10';
      List<Map> responselocalDb = await sqlDbObj.readData(sql);
      print('$responselocalDb');
      preparing(responselocalDb);
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      print(e.toString());
    }
  }

  deleteSumittedDataRow(int rowId) async {
    try {
      //String sql = 'DELETE FROM markettbl WHERE id = 2';
      String sql = 'DELETE FROM markettbl WHERE id = $rowId';
      int response = await sqlDbObj.deleteData(sql);
      print('$response');
      getRowCount();
      setState(() {
        isUploading = false;
      });
    } catch (e) {
      print(e.toString());
    }

    setState(() {});
  }
  // Preparing

  void preparing(List responselocalDb) {
    for (var element in responselocalDb) {
      print(element);

      if (_200isOk) {
        if (activeInternet) {
          print(activeInternet);
          // methods run
          // pass offline clz and decode map
          OfflineData offlineDataObj = OfflineData.fromJson(element);
          // pass prepare data to punchofflineData method
          punchOfflineData(
            offlineDataObj.id,
            offlineDataObj.userid,
            offlineDataObj.geo_location,
            offlineDataObj.longitude,
            offlineDataObj.latitude,
            offlineDataObj.outlet_name,
            offlineDataObj.execution_type,
            offlineDataObj.remarks,
            offlineDataObj.image1,
            offlineDataObj.image2,
            offlineDataObj.image3,
            offlineDataObj.image4,
            offlineDataObj.image5,
          );
        } else {
          setState(() {
            isUploading = false;
          });
          Fluttertoast.showToast(
            msg: "Your are offline",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          break;
        }
      } else {
        setState(() {
          isUploading = false;
        });
        Fluttertoast.showToast(
          msg: "Please try again later",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool?> punchOfflineData(
    int rowId,
    String userid,
    String geo_location,
    String longitude,
    String latitude,
    String outlet_name,
    String execution_type,
    String remarks,
    String? image1,
    String? image2,
    String? image3,
    String? image4,
    String? image5,
  ) async {
    // imgs upload
    SelfieImg selfieImg = SelfieImg();
    bool isOfflineDone = await selfieImg.PunchOfflineData(
      token,
      userid,
      geo_location,
      longitude,
      latitude,
      outlet_name,
      execution_type,
      remarks,
      image1: image1,
      image2: image2,
      image3: image3,
      image4: image4,
      image5: image5,
    );
    //if done
    if (isOfflineDone) {
      // done // ------------------------------------------------------------
      // ---------------------------------------------------------------------

      _200isOk = true;
      // delete row data in local db
      deleteSumittedDataRow(rowId);
      // toast data one data sumbitted

      Fluttertoast.showToast(
        msg: 'Punch offline row id -> $rowId',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      // not done // ------------------------------------------------------------
      setState(() {
        isUploading = false;
      });

      _200isOk = false;
    }
  }
}
