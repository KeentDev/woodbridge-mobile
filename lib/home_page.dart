import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'message_services.dart';
import 'notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'woodbridge-ui_components.dart';
import 'services.dart';
import 'notifications.dart';
import 'profile.dart';
import 'grades.dart';
import 'attendance.dart';
import 'activities.dart';
import 'gallery.dart';
import 'payment.dart';
import 'initial_onboard.dart';
import 'login.dart';
import 'message_board.dart';
import 'about_us.dart';
import 'privacy_policy.dart';

double totalBalance = 0.00;
double totalPayments = 0.00;

List<Payment> payments = <Payment>[];
List<Payment> initialPayments = <Payment>[];

bool showStudentSwitcher = false;

Future<Map> getPresentDaysNo(userId) async {
  String url = '$baseApi/att/get-present-days-of-student';

  var response = await http.post(url, body: json.encode({
    'data': userId
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body)[0];
}
Future<Map> getTotalSchoolDays(userId) async {
  String url = '$baseApi/att/get-total-school-days';

  var response = await http.get(url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body)[0];
}
Future<Map> getAbsentDays(userId) async {
  String url = '$baseApi/att/get-absent-days-of-school?data=$userId';

  var response = await http.get(url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body)[0];
}
Future<List> getAttendanceDays(userId) async {
  String url = '$baseApi/att/get-student-attendance';

  var response = await http.post(url, body: json.encode({
    "data": userId
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}
Future<List> getSchoolYearInformation() async {
  String url = '$baseApi/att/get-attendance-setting-information';

  var response = await http.get(url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}
Future<List> getStudentLatestAttendance(userId) async {
  String url = '$baseApi/att/get-student-latest-attendance';

  var response = await http.post(url, body: json.encode({
    "data": userId
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}
Future<List> fetchStudentPayments(userId) async {
  String url = '$baseApi/pay/get-student-payments';

  var response = await http.post(url, body: json.encode({
    'data': userId
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}
Future addNotificationToken(token, topic, studentId) async {
  String url = '$baseApi/account/notif-token-add';

  var response = await http.post(url, body: json.encode({
    'data': {
      'uname': getUsername(),
      'token': token,
      'topic': topic,
      's_id': studentId
    }
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}
Future addNotificationTopic(topic, token, s_id) async {
  String url = '$baseApi/account/add-notif-topic';

  var response = await http.post(url, body: json.encode({
    'data': {
      'topic': topic,
      'token': token,
      's_id': s_id
    }
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}
Future removeNotificationToken(token) async {
  String url = '$baseApi/account/notif-token-remove';

  var response = await http.post(url, body: json.encode({
    'data': {
      'token': token,
    }
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}

class HomePage extends StatefulWidget {
  Widget child;
  String firstName;
  String lastName;
  String heroTag;
  String schoolLevel;
  String classId;
  String gradeLevel;
  String gradeSection;
  String avatarUrl;
  List<String> userIds;

  HomePage({
    this.child,
    this.firstName,
    this.lastName,
    this.heroTag,
    this.schoolLevel,
    this.classId,
    this.gradeLevel,
    this.gradeSection,
    this.userIds,
    this.avatarUrl
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _token;
  StreamController streamController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Color attendanceStatusColor = Colors.redAccent;
  Icon attendanceStatusIcon = Icon(
    Icons.error_outline,
    color: Colors.redAccent,
  );

  Map monthWithYearActivities = {};
  List<String> activityWithYearNames = [];

  String attendanceStatus = '';
  String schoolYearStart;
  String schoolYearEnd;
  String nextEventMonth;
  String nextEventDay;
  String nextPaymentMonth;
  String nextPaymentDay;

  List<DateTime> schoolDays = <DateTime>[];
  List<DateTime> presentDays = <DateTime>[];
  List<DateTime> noSchoolDays = <DateTime>[];
  List<DateTime> specialSchoolDays = <DateTime>[];

  DateTime yearStartDay;
  DateTime yearEndDay;

  double totalSchoolDays = 0;
  int presentDaysNo = 0;
  int pastSchoolDays = 0;
  int absentDays = 0;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  PDFDocument doc;
  List<Widget> guidePages = <Widget>[];

  int notificationPageSize = 8;
  int messagePageSize = 8;

  Future initLoadPdf() async {
    doc = await PDFDocument.fromAsset('files/TWAMobileParentsGuide.pdf');
    int maxPages = doc.count;

    for(int i = 0; i < maxPages; i++){
      guidePages.add(await doc.get(page: i+1));
    }

    return guidePages;
  }

  Map paymentData = {};

  void fetchPdf() async {
    await initLoadPdf();
  }
  void getAttendanceInfo(userId) {
    Future.wait([
      getPresentDaysNo(userId)
        .then((result) {
          setState(() {
            presentDaysNo = result['presentDays'];
          });
        }),
      getTotalSchoolDays(userId)
        .then((result) {
          setState(() {
            totalSchoolDays = result['totalDays'];
          });
        }),
      getAbsentDays(userId)
        .then((result) {
          setState(() {
            pastSchoolDays = result['totalDaysNow'];
          });
        }),
      getAttendanceDays(userId)
        .then((results) {
          results.forEach((result) {
            DateTime attendanceDate = DateTime.parse(result['date_marked']).toLocal();
            DateTime attendanceDay = DateTime(attendanceDate.year, attendanceDate.month, attendanceDate.day);
            presentDays.add(attendanceDay);
          });
        }),
      getStudentLatestAttendance(userId)
        .then((results) {
          try {
            if(results.length > 0 || results != null){
              Map latestAttendance = results[0];
              DateTime attendanceDate = DateTime.parse(latestAttendance['date_marked']).toLocal();
              DateTime today = DateTime.now();
              DateTime attendanceDay = DateTime.utc(attendanceDate.year, attendanceDate.month, attendanceDate.day);
              DateTime thisDay = DateTime.utc(today.year, today.month, today.day);

              if(attendanceDay.isAtSameMomentAs(thisDay)){
                if(latestAttendance['in'] == '1'){
                  attendanceStatus = 'Present';
                  attendanceStatusColor = Colors.green;
                  attendanceStatusIcon = Icon(
                    Icons.check,
                    color: Colors.green,
                  );
                }else if(today.isBefore(attendanceDate)){
                  attendanceStatus = 'Soon';
                  attendanceStatusColor = Theme.of(context).accentColor;
                  attendanceStatusIcon = Icon(
                    Icons.brightness_low,
                    color: Theme.of(context).accentColor,
                    size: 18.0,
                  );
                }else if(today.isAfter(attendanceDate)){
                  attendanceStatus = 'Absent';
                }
              }else{
                attendanceStatus = 'Absent';
              }
            }
          } catch(e) {
            attendanceStatus = 'Absent';
          }

          if(attendanceStatus == 'Absent'){
            attendanceStatusColor = Colors.redAccent;
            attendanceStatusIcon = Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 18.0,
            );
          }
        }),
      getSchoolYearInformation()
        .then((results) {
          Map schoolYearInformation = results[results.length - 1]; // TODO: Verify which row to get, or if changes from year to year or new one will be added.
          DateTime yearStart = DateTime.parse(schoolYearInformation['quarter_start']).toLocal();
          DateTime yearEnd = DateTime.parse(schoolYearInformation['quarter_end']).toLocal();

          yearStartDay = DateTime(yearStart.year, yearStart.month, yearStart.day);
          yearEndDay = DateTime(yearEnd.year, yearEnd.month, yearEnd.day);

          schoolYearStart = yearStartDay.year.toString();
          schoolYearEnd = yearEndDay.year.toString();
        })
    ]);
  }
  void transformActivityList(classId) async {
    await getStudentActivities(classId)
      .then((results) {
        DateTime currTime = DateTime.now().toLocal();
        DateTime currDay = DateTime(currTime.year, currTime.month, currTime.day);
        List<String> weekdayNames = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        Map yearActivities = {};

        monthWithYearActivities = {};
        activityWithYearNames = [];

        for(int i = 0; i < results.length; i++){
          Map activity = results[i];
          DateTime date = DateTime.parse(activity['a_start_date']).toLocal();
          int monthIndex = date.month - 1;
          String month = monthNames[monthIndex];
          int year = date.year;

          date = date.add(Duration(hours: 8));

          if(date.isAfter(currDay) || date.isAtSameMomentAs(currDay)){
            ActivityEvent activityEvent = ActivityEvent(
              title: activity['a_title'],
              venue: activity['a_location'],
              time: activity['a_time_start'],
              day: '${date.day < 10 ? '0' : ''}${date.day.toString()}',
              weekday: weekdayNames[date.weekday - 1]
            );

            if(yearActivities[year] == null){
              yearActivities[year] = {};
              yearActivities[year][month] = [];
            }
            if(yearActivities[year][month] == null){
              yearActivities[year][month] = [];
            }
            yearActivities[year][month].add(activityEvent);
          }
        }

        yearActivities.keys.forEach((year) {
          Map monthActivitiesFromYear = yearActivities[year];
          List monthActivitiesFromYearNames = monthActivitiesFromYear.keys.toList();
          monthActivitiesFromYearNames = sortActivityNames(monthActivitiesFromYearNames);

          for(int i = 0; i < monthActivitiesFromYearNames.length; i++){
            String monthActivitiesFromYearName = monthActivitiesFromYearNames[i];
            String monthYearLabel = '$monthActivitiesFromYearName $year';

            monthWithYearActivities[monthYearLabel] = [];
            monthWithYearActivities[monthYearLabel].addAll(monthActivitiesFromYear[monthActivitiesFromYearName]);
          }
        });
        List iteratableActivityNames = monthWithYearActivities.keys.toList();
        for(int i = 0; i < iteratableActivityNames.length; i++){
          activityWithYearNames.add(iteratableActivityNames[i]);
        }
        try {
          nextEventMonth = activityWithYearNames[0];
          nextEventDay = monthWithYearActivities[activityWithYearNames[0]][0].day;
        } catch(e){}

        setState(() {});
      });
  }
  List<String> sortActivityNames(activityNamesSort) {
    List<int> sortedMonthIndex = <int>[];
    List<String> sortedMonthNames = <String>[];

    for(int i = 0; i < activityNamesSort.length; i++){
      String month = activityNamesSort[i];
      int monthIndex = 0;
      int largestMonthIndex = 0;

      for(monthIndex = 0; monthIndex < monthNames.length; monthIndex++){
        if(monthNames[monthIndex] == month){
          if(monthIndex > largestMonthIndex){
            largestMonthIndex = monthIndex;
          }
          break;
        }
      }

      sortedMonthIndex.add(monthIndex);
      sortedMonthIndex.sort();
    }
    for(int i = 0; i < sortedMonthIndex.length; i++){
      sortedMonthNames.add(monthNames[sortedMonthIndex[i]]);
    }

    return sortedMonthNames;
  }
  void firebaseCloudMessaging_Listeners(String classId) {
    List<Map> topics = getTopics();
    if (Platform.isIOS) iOS_Permission();
    _token = "";
    print(topics);
    _firebaseMessaging.getToken().then((token){
      print(token);
      _token = token;
      for(int i = 0; i < topics.length; i++){
        Map topic = topics[i];
        if(topic['topic'] != null){
          addNotificationToken(_token, topic['topic'],  topic['s_id'])
            .then((result) {
              if(result['code'] == 1){
                _firebaseMessaging.subscribeToTopic(topic['topic']);
                print('subscribed to ${topic['topic']}');
              }else if(result['code'] == 2){
                print('${topic['topic']} already subscribed.');
              }
            });
        }
      }
    });
  }
  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
        {
          print("Settings registered: $settings");
        });
  }

  Future buildStudentPayments(userId) async {
    Completer _completer = Completer();

    await fetchStudentPayments(userId)
      .then((results) {
        payments = [];
        totalBalance = 0.00;
        totalPayments = 0.00;

        nextPaymentMonth = null;
        nextPaymentDay = null;

        results.forEach((payment) {
          var amount;
          DateTime dueDate;
          if(payment['due_date'] != null){
            dueDate = DateTime.parse(payment['due_date']).toLocal();
          }
          String paymentDate = 'Unpaid';
          try {
            amount = payment['amount_paid'] != null ? payment['amount_paid'].toString() : 'N/A';
            if(amount == 'N/A' || amount == null || amount == '0'){
              totalBalance += payment['due_amount'];
              if(nextPaymentMonth == null){
                nextPaymentMonth = monthNames[dueDate.month - 1];
                nextPaymentDay = '${dueDate.day < 10 ? "0" : ""}${dueDate.day}';
              }
            }else {
              if(payment['amount_paid'] != null){
                totalPayments += payment['amount_paid'];
              }
            }
          } catch(e){
            print(e);
          }

          try{
            String paidDate = payment['paid_date'];
            if(paidDate != null){
              paymentDate = timeFormat(DateTime.parse(payment['paid_date']).toLocal().toString(), 'MM/d/y');
            }
          }catch(e){}
          payments.add(
            Payment(
              label: dueDate != null ? timeFormat(dueDate.toString(), 'MM/d/y') : '',
              amount: amount,
              dueAmount: payment['due_amount'] + 0.00 ?? 0,
              rawDate: dueDate,
              paidDate: paymentDate,
              isPaid: amount != 'N/A',
              paymentModes: payment['note'],
              paymentSettingId: payment['pay_setting_id'].split(',')[0],
              amountDesc: payment['due_desc'],
              paymentType: {
                'type': payment['pay_type'],
                'official_receipt': payment['official_receipt'],
                'bank_abbr': payment['pay_bank']
              },
              paymentNote: payment['description']
            )
          );
        });
    });
    streamController.add({
      'totalPayments': totalPayments,
      'totalBalance': totalBalance,
      'payments': payments
    });
    _completer.complete();
    return _completer.future;
  }

  void _saveUserProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('fname', widget.firstName);
    await prefs.setString('lname', widget.lastName);
    await prefs.setString('userId', widget.heroTag);
    await prefs.setString('schoolLevel', widget.schoolLevel);
    await prefs.setString('avatarUrl', widget.avatarUrl);
    await prefs.setString('classId', widget.classId);
    await prefs.setString('gradeLevel', widget.gradeLevel);
    await prefs.setString('gradeSection', widget.gradeSection);
    await prefs.setStringList('userIds', widget.userIds);
    await prefs.setStringList('topics', widget.userIds);
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  void initState(){
    List topics = getTopics();
    int topicIndex = 0;
    super.initState();
    streamController = StreamController();

    monthWithYearActivities = {};
    activityWithYearNames = [];

    fetchPdf();

    payments = [];
    initialPayments = [];

    schoolDays = <DateTime>[];
    presentDays = <DateTime>[];
    noSchoolDays = <DateTime>[];
    specialSchoolDays = <DateTime>[];

    for(int topicIndex = 0; topicIndex < topics.length; topicIndex++){
      Map topic = topics[topicIndex];

      if(topic['topic'] == 'all'){
        break;
      }
    }
    if(topicIndex == topics.length){
      addTopic('all', '');
    }
    firebaseCloudMessaging_Listeners(widget.classId);
    transformActivityList(widget.classId);
    getAttendanceInfo(widget.heroTag);
    buildStudentPayments(widget.heroTag);

    setAvatarUrl(widget.avatarUrl);

    streamController.stream.listen((data){
      setState(() {
        paymentData = data;
      });
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        updateHomeData();
      },
      onResume: (Map<String, dynamic> message) async {
        print('updating');
        updateHomeData();
        routeNotificationPage(message['notif_category']);
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        updateHomeData();
//        routeNotificationPage(message['notif_category']);
        print('on launch $message');
      },
    );

    SystemChannels.lifecycle.setMessageHandler((msg){
      if(msg == 'AppLifecycleState.resumed'){
        updateHomeData();
      }
      debugPrint('SystemChannels> $msg');
    });
  }

  void routeNotificationPage(category) async {
    if((category != null) && (['activity','photos','messages','appointment','progress','attendance'].contains(category))){
      Widget pageBuilder;
      Route route = MaterialPageRoute(builder: (buildContext) => HomePage(
        child: Avatar(
          backgroundColor: Colors.indigo,
          maxRadius: 54.0,
          minRadius: 20.0,
          fontSize: 20.0,
          initial: "${widget.firstName != null ? widget.lastName[0] : ''}${widget.lastName != null ? widget.lastName[0] : ''}",
          avatarUrl: widget.avatarUrl,
        ),
        firstName: widget.firstName ?? '',
        lastName: widget.lastName ?? '',
        heroTag: widget.heroTag,
        schoolLevel: widget.schoolLevel,
        classId: widget.classId,
        gradeLevel: widget.gradeLevel,
        gradeSection: widget.gradeSection,
        userIds: widget.userIds,
        avatarUrl: widget.avatarUrl,
      ));
      Navigator.push(context, route);
      if(category == 'activity'){
        pageBuilder = Activities(
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          classId: this.widget.classId,
          userId: this.widget.heroTag,
          monthActivities: this.monthWithYearActivities,
          activityNames: this.activityWithYearNames,
        );
      }else if(category == 'photos'){
        pageBuilder = ActivityGallery(
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          userId: this.widget.heroTag,
          classId: this.widget.classId,
        );
      }else if(category == 'messages' || category == 'appointment') {
        pageBuilder = await buildMessageList(widget.heroTag, messagePageSize, 1)
          .then((result) {
            return MessageBoard(
              userId: widget.heroTag,
              pageSize: messagePageSize,
              pageNum: 1,
              messageBoardLists: result['messages'],
              firstName: widget.firstName,
              lastName: widget.lastName,
            );
          });
      }else if(category == 'progress'){
        pageBuilder = Grades(
          userId: widget.heroTag,
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          schoolLevel: this.widget.schoolLevel,
        );
      }else if(category == 'attendance'){
        pageBuilder = Attendance(
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          userId: this.widget.heroTag,
          schoolDays: this.schoolDays,
          presentDays: this.presentDays,
          noSchoolDays: this.noSchoolDays,
          specialSchoolDays: this.specialSchoolDays,
          yearStartDay: this.yearStartDay,
          yearEndDay: this.yearEndDay,
          presentDaysNo: this.presentDaysNo,
          pastSchoolDays: this.pastSchoolDays,
          absentDays: this.absentDays,
          totalSchoolDays: this.totalSchoolDays,
        );
      }

      Route routeNew = MaterialPageRoute(builder: (buildContext) => pageBuilder);
      Navigator.push(context, routeNew);
    }
  }

  void updateHomeData() async {
    schoolDays = <DateTime>[];
    presentDays = <DateTime>[];
    noSchoolDays = <DateTime>[];
    specialSchoolDays = <DateTime>[];


    transformActivityList(widget.classId);
    getAttendanceInfo(widget.heroTag);
    buildStudentPayments(widget.heroTag);

    print('All data are up-to-date');
  }

  void userData(lname, fname, schoolLevel, classId, gradeLevel, gradeSection, avatarUrl, userId){
    widget.child = Avatar(
      backgroundColor: Colors.indigo,
      maxRadius: 54.0,
      fontSize: 20.0,
      initial: "${fname != null ? fname[0] : ''}${lname != null ? lname[0] : ''}",
      avatarUrl: avatarUrl,
    );
    widget.avatarUrl = avatarUrl;
    widget.firstName = fname ?? '';
    widget.lastName = lname ?? '';
    widget.heroTag = userId;
    widget.schoolLevel = schoolLevel;
    widget.classId = classId;
    widget.gradeLevel = gradeLevel;
    widget.gradeSection = gradeSection;

    setAvatarUrl(avatarUrl);
    updateHomeData();
  }

  void _setLoggedInStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(status == false){
      await prefs.clear();
    }
    print('settings login status');
    print(status);
    await prefs.setBool('isLoggedIn', status);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    height *= .2;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.black, // Color for Android
      statusBarBrightness: Brightness.dark // Dark == white status bar -- for IOS.
    ));

    if(widget.userIds == null){
      widget.userIds = [];
      widget.userIds.add(widget.heroTag);
    }

    _saveUserProfileData();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Material(
          child: Stack(
            children: <Widget>[
              Positioned(
                child: SafeArea(
                  child: Scaffold(
                    key: _scaffoldKey,
                    drawer: Drawer(
                      child: Flex(
                        direction: Axis.vertical,
                        children: <Widget>[
                          Flexible(
                            flex: 0,
                            child: UserAccountsDrawerHeader(
                              accountEmail: Text(
                                '${widget.gradeLevel} - ${widget.gradeSection}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              accountName: Text(
                                '${this.widget.firstName ?? ""} ${this.widget.lastName ?? ""}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w800
                                ),
                              ),
                              otherAccountsPictures: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.close),
                                  color: Color.fromRGBO(255, 255, 255, .75),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  splashColor: Colors.white,
                                )
                              ],
                              currentAccountPicture: widget.child,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.book),
                                        onTap: (){
                                          Route route = MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return InitialOnboard(
                                                  pages: guidePages,
                                                  userIds: [],
                                                  showAgreementCta: false,
                                                );
                                              });
                                          Navigator.push(context, route);
                                        },
                                        title: Text(
                                          "Parent's Guide",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87
                                          )
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey[400],
                                        height: 16.0,
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.verified_user),
                                        title: Text(
                                          'Privacy Policy',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87
                                          )
                                        ),
                                        onTap: () {
                                          Route route = MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return PrivacyPolicy();
                                              });
                                          Navigator.push(context, route);
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.error),
                                        title: Text(
                                          'About Us',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87
                                          )
                                        ),
                                        onTap: () {
                                          Route route = MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return AboutUs();
                                            });
                                          Navigator.push(context, route);
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Divider(
                                        color: Colors.grey[400],
                                        height: 16.0,
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.exit_to_app),
                                        title: Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87
                                          )
                                        ),
                                        onTap: () {
                                          List topics = getTopics();
                                          _setLoggedInStatus(false);
                                          removeNotificationToken(_token)
                                            .then((resolves) {
                                              for(int i = 0; i < topics.length; i++){
                                                String topic = topics[i]['topic'];

                                                _firebaseMessaging.unsubscribeFromTopic(topic);
                                              }

                                              Route route = MaterialPageRoute(
                                                  builder: (BuildContext context) {
                                                    return LoginPage();
                                                  });
                                              Navigator.push(context, route);
                                            });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: Container(
                      child: Flex(
                        direction: Axis.vertical,
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage('img/home_profile_head_cover.png')
                                )
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                              child: Flex(
                                direction: Axis.vertical,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    flex: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        Route route = MaterialPageRoute(
                                          builder: (buildContext) => Profile(
                                            heroTag: widget.heroTag,
                                            firstName: this.widget.firstName,
                                            lastName: this.widget.lastName,
                                          ));
                                        Navigator.push(context, route);
                                      },
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        child: Hero(
                                          tag: this.widget.heroTag ?? '',
                                          child: this.widget.child
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.0),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Material(
                                          color: Color.fromRGBO(255, 255, 255, 0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                showStudentSwitcher = true;
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '${this.widget.lastName ?? ""}, ${this.widget.firstName ?? ""}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 18.0,
                                                      color: Colors.white
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                                                ),
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 3.0),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'S.Y. ${schoolYearStart ?? ""}-${schoolYearEnd ?? ""}',
                                              style: TextStyle(
                                                  color: Colors.white
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 3.0),
                                            ),
                                            Text(
                                              '${widget.gradeSection}',
                                              style: TextStyle(
                                                  color: Colors.white
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Flex(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Flexible(
                                    flex: 4,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: double.infinity,
                                            maxHeight: 90.0
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [BrandTheme.cardShadow],
                                              borderRadius: BorderRadius.all(Radius.circular(7.0))
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 12.0),
                                            child: Flex(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              direction: Axis.horizontal,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: OverflowBox(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Flex(
                                                          direction: Axis.vertical,
                                                          mainAxisAlignment: nextPaymentDay != null && nextPaymentDay != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                'Next Payment',
                                                                overflow: TextOverflow.fade,
                                                                textAlign: TextAlign.center,
                                                                maxLines: 2,
                                                                softWrap: true,
                                                                style: TextStyle(
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: Colors.black87
                                                                ),
                                                              ),
                                                            ),
                                                            nextPaymentDay != null && nextPaymentDay != null ? Column(
                                                              children: <Widget>[
                                                                Text(
                                                                  nextPaymentMonth ?? "",
                                                                  style: TextStyle(
                                                                      color: Colors.black38,
                                                                      fontSize: 12.0,
                                                                      fontWeight: FontWeight.w600
                                                                  ),
                                                                ),
                                                                Text(
                                                                  nextPaymentDay ?? "",
                                                                  style: TextStyle(
                                                                      color: Theme.of(context).accentColor,
                                                                      fontSize: 20.0,
                                                                      fontWeight: FontWeight.w600
                                                                  ),
                                                                ),
                                                              ],
                                                            ) : Expanded(
                                                              flex: 1,
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Text(
                                                                    'All set!',
                                                                    style: TextStyle(
                                                                      color: Colors.green,
                                                                      fontSize: 16.0,
                                                                      fontWeight: FontWeight.w600
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: double.infinity,
                                                  width: 1.0,
                                                  color: Colors.black12,
                                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(
                                                              'Attendance',
                                                              style: TextStyle(
                                                                  fontSize: 13.0,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.black87
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 5.0),
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      attendanceStatusIcon,
                                                                      Padding(
                                                                        padding: EdgeInsets.only(left: 4.0),
                                                                        child: Text(
                                                                          attendanceStatus,
                                                                          style: TextStyle(
                                                                            color: attendanceStatusColor,
                                                                            fontSize: 16.0,
                                                                            fontWeight: FontWeight.w700
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    '$presentDaysNo/${totalSchoolDays.floor()}',
                                                                    overflow: TextOverflow.fade,
                                                                    style: TextStyle(
                                                                        color: Colors.black38,
                                                                        fontSize: 12.0,
                                                                        fontWeight: FontWeight.w600
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: double.infinity,
                                                  width: 1.0,
                                                  color: Colors.black12,
                                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                            'Next Event',
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight: FontWeight.w700,
                                                                color: Colors.black87
                                                            ),
                                                          ),
                                                          nextEventMonth != null && nextEventDay != null ? Column(
                                                            children: <Widget>[
                                                              Text(
                                                                nextEventMonth ?? '',
                                                                style: TextStyle(
                                                                    color: Colors.black38,
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.w600
                                                                ),
                                                              ),
                                                              Text(
                                                                nextEventDay ?? '',
                                                                style: TextStyle(
                                                                    color: Theme.of(context).accentColor,
                                                                    fontSize: 20.0,
                                                                    fontWeight: FontWeight.w600
                                                                ),
                                                              ),
                                                            ],
                                                          ) : Expanded(
                                                            flex: 1,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: <Widget>[
                                                                Text(
                                                                  'Stay tuned.',
                                                                  style: TextStyle(
                                                                      color: Colors.grey[500],
                                                                      fontSize: 14.0,
                                                                      fontWeight: FontWeight.w600
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12.0,
                                      mainAxisSpacing: 12.0,
                                      shrinkWrap: true,
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                      children: <Widget>[
                                        MenuItem(
                                          iconPath: 'img/Icons/icon_payments_2x.png',
                                          label: 'Payments',
                                          pageBuilder: PaymentHistory(
                                            firstName: this.widget.firstName,
                                            lastName: this.widget.lastName,
                                            userId: this.widget.heroTag,
                                            paymentData: paymentData,
                                          ),
                                          buildContext: context,
                                        ),
                                        MenuItem(
                                          iconPath: 'img/Icons/icon_attendance_2x.png',
                                          label: 'Attendance',
                                          pageBuilder: Attendance(
                                            firstName: this.widget.firstName,
                                            lastName: this.widget.lastName,
                                            userId: this.widget.heroTag,
                                            schoolDays: this.schoolDays,
                                            presentDays: this.presentDays,
                                            noSchoolDays: this.noSchoolDays,
                                            specialSchoolDays: this.specialSchoolDays,
                                            yearStartDay: this.yearStartDay,
                                            yearEndDay: this.yearEndDay,
                                            presentDaysNo: this.presentDaysNo,
                                            pastSchoolDays: this.pastSchoolDays,
                                            absentDays: this.absentDays,
                                            totalSchoolDays: this.totalSchoolDays,
                                          ),
                                          buildContext: context,
                                        ),
                                        MenuItem(
                                          iconPath: 'img/Icons/icon_grades_2x.png',
                                          label: 'Progress',
                                          pageBuilder: Grades(
                                            userId: widget.heroTag,
                                            firstName: this.widget.firstName,
                                            lastName: this.widget.lastName,
                                            schoolLevel: this.widget.schoolLevel,
                                          ),
                                          buildContext: context,
                                        ),
                                        MenuItem(
                                          iconPath: 'img/Icons/icon_activities_2x.png',
                                          label: 'Activities',
                                          pageBuilder: Activities(
                                            firstName: this.widget.firstName,
                                            lastName: this.widget.lastName,
                                            classId: this.widget.classId,
                                            userId: this.widget.heroTag,
                                            monthActivities: this.monthWithYearActivities,
                                            activityNames: this.activityWithYearNames,
                                          ),
                                          buildContext: context,
                                        ),
                                        MenuItem(
                                          iconPath: 'img/Icons/icon_gallery_2x.png',
                                          label: 'Photos',
                                          pageBuilder: ActivityGallery(
                                            firstName: this.widget.firstName,
                                            lastName: this.widget.lastName,
                                            userId: this.widget.heroTag,
                                            classId: this.widget.classId,
                                          ),
                                          buildContext: context,
                                        ),
                                        MenuItem(
                                          iconPath: 'img/Icons/icon_announcements_2x.png',
                                          label: 'Messages',
                                          isCustomOnPressed: true,
                                          customOnPressed: () async {
                                            buildMessageList(widget.heroTag, messagePageSize, 1)
                                              .then((result) {
                                                Route route = MaterialPageRoute(builder: (buildContext) => MessageBoard(
                                                  userId: widget.heroTag,
                                                  pageSize: messagePageSize,
                                                  pageNum: 1,
                                                  messageBoardLists: result['messages'],
                                                  firstName: widget.firstName,
                                                  lastName: widget.lastName,
                                                ));
                                                Navigator.push(context, route);
                                              });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    appBar: AppBar(
                      title: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("img/woodbridge_logo.png")
                          )
                        ),
                      ),
                      leading: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState.openDrawer();
                        },
                        icon: Icon(
                          Icons.menu,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      actions: <Widget>[
                        IconButton(
                          onPressed: () async {
                            buildNotificationList(this.widget.heroTag, notificationPageSize, 1)
                              .then((result) {
                                Route route = MaterialPageRoute(builder: (buildContext) => Notifications(
                                  firstName: this.widget.firstName,
                                  lastName: this.widget.lastName,
                                  userId: this.widget.heroTag,
                                  notificationTiles: result['notifications'],
                                  pageSize: notificationPageSize,
                                ));
                                Navigator.push(context, route);
                              });
                          },
                          icon: Icon(
                            Icons.notifications_none,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
              Positioned(
                child: SafeArea(
                  child: showStudentSwitcher ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(22, 86, 135, .88)
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        margin: EdgeInsets.only(top: height),
                        child: Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                'Select Student',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 360.00
                                ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                                  child: GridView.count(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    primary: false,
                                    childAspectRatio: .9,
                                    crossAxisCount: 2,
                                    physics: BouncingScrollPhysics(),
                                    children: widget.userIds.map((userId) {
                                      return StudentAvatarPicker(
                                        userId: '${userId}',
                                        isActive: userId == widget.heroTag,
                                        onTap: (lname, fname, schoolLevel, classId, gradeLevel, gradeSection, avatarUrl) {
                                          showStudentSwitcher = false;

                                          userData(lname, fname, schoolLevel, classId, gradeLevel, gradeSection, avatarUrl, userId);
                                        }
                                      );
                                    }).toList()
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ) : Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  MenuItem({
    Key key,
    this.child,
    this.label,
    this.iconPath,
    this.pageBuilder,
    this.buildContext,
    this.isCustomOnPressed,
    this.customOnPressed
  }) : super(key: key);

  final Widget child;
  final String iconPath;
  final String label;
  final Widget pageBuilder;
  final BuildContext buildContext;
  var customOnPressed;
  bool isCustomOnPressed;

  @override
  Widget build(BuildContext context) {
    if(isCustomOnPressed == null){
      isCustomOnPressed = false;
    }

    return Material(
      child: InkWell(
        onTap: () {
          if(isCustomOnPressed){
            customOnPressed();
          }else{
            Route route = MaterialPageRoute(builder: (buildContext) => pageBuilder);
            Navigator.push(buildContext, route);
          }
        },
        child: Material(
          child: InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                boxShadow: [BrandTheme.cardShadow],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(7.0))
              ),
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(iconPath)
                        )
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}