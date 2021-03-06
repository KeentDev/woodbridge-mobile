import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myWoodbridge/payment_guide.dart';
import 'model.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
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
import 'i18n.dart';

double totalBalance = 0.00;
double totalPayments = 0.00;

List<Payment> payments = <Payment>[];
List<Payment> initialPayments = <Payment>[];

bool showStudentSwitcher = false;

Future<Map> getPresentDaysNo(userId) async {
  String url = '$baseApi/att/get-present-days-of-student';

  var response = await http.post(
    url,
    body: json.encode({'data': userId}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body)[0];
}

Future fetchHolidayList() async {
  String url = '$baseApi/sett/get-holidays';

  var response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future<Map> getTotalSchoolDays(userId) async {
  String url = '$baseApi/att/get-total-school-days';

  var response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body)[0];
}

Future<Map> getAbsentDays(userId) async {
  String url = '$baseApi/att/get-absent-days-of-school?data=$userId';

  var response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body)[0];
}

Future<List> getAttendanceDays(userId) async {
  String url = '$baseApi/att/get-student-attendance';

  var response = await http.post(
    url,
    body: json.encode({"data": userId}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future<List> getSchoolYearInformation() async {
  String url = '$baseApi/att/get-attendance-setting-information';

  var response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future<List> getStudentLatestAttendance(userId) async {
  String url = '$baseApi/att/get-student-latest-attendance';

  var response = await http.post(
    url,
    body: json.encode({"data": userId}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future<List> fetchStudentPayments(userId) async {
  String url = '$baseApi/pay/get-student-payments-mobile';

  var response = await http.post(
    url,
    body: json.encode({'data': userId}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future<Map> getStudentUnseenNotifications(userId) async {
  String url = '$baseApi/notif/get-student-unseen-notifs';

  var response = await http.post(
    url,
    body: json.encode({"data": userId}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future<Map> getStudentNotificationInfo(notifId) async {
  String url = '$baseApi/notif/get-student-notification-info';

  var response = await http.post(
    url,
    body: json.encode({"data": notifId}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future getClassDetails(classId) async {
  String url = '$baseApi/classroom/get-class-details';

  var response = await http.post(
    url,
    body: json.encode({'data': classId}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future addNotificationToken(token, topic, studentId) async {
  String url = '$baseApi/account/notif-token-add';

  var response = await http.post(
    url,
    body: json.encode({
      'data': {
        'uname': getUsername(),
        'token': token,
        'topic': topic,
        's_id': studentId
      }
    }),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future addNotificationTopic(topic, token, _sId) async {
  String url = '$baseApi/account/add-notif-topic';

  var response = await http.post(
    url,
    body: json.encode({
      'data': {'topic': topic, 'token': token, 's_id': _sId}
    }),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future removeNotificationToken(token) async {
  String url = '$baseApi/account/notif-token-remove';

  var response = await http.post(
    url,
    body: json.encode({
      'data': {
        'token': token,
      }
    }),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

Future seenNotification(notifId) async {
  String url = '$baseApi/notif/seen-student-notif';

  var response = await http.post(
    url,
    body: json.encode({
      'data': {'notif_id': notifId}
    }),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(response.body);
}

class HomePage extends StatefulWidget {
  HomePage(
      {this.child,
      this.firstName,
      this.lastName,
      this.heroTag,
      this.schoolLevel,
      this.classId,
      this.gradeLevel,
      this.gradeSection,
      this.userIds,
      this.avatarUrl});

  String avatarUrl;
  Widget child;
  String classId;
  String firstName;
  String gradeLevel;
  String gradeSection;
  String heroTag;
  String lastName;
  String schoolLevel;
  List<String> userIds;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int absentDays = 0;
  List<String> activityWithYearNames = [];
  String attendanceStatus = '';
  Color attendanceStatusColor = Colors.redAccent;
  Icon attendanceStatusIcon = Icon(
    Icons.error_outline,
    color: Colors.redAccent,
    size: 18.0,
  );

  // PDFDocument doc;
  // List<Widget> guidePages = <Widget>[];
  Map<DateTime, List> holidayDays = {};
  int messagePageSize = 8;
  Map monthWithYearActivities = {};
  String nextEventDay;
  String nextEventMonth;
  List<DateTime> noSchoolDays = <DateTime>[];
  int notificationPageSize = 8;
  bool otherChildHasUnreadNotif = false;
  int pastSchoolDays = 0;
  Map paymentData = {};
  List<DateTime> presentDays = <DateTime>[];
  int presentDaysNo = 0;
  List<DateTime> schoolDays = <DateTime>[];
  String schoolYearEnd;
  String schoolYearStart;
  List<DateTime> specialSchoolDays = <DateTime>[];
  StreamController streamController;
  double totalSchoolDays = 0;
  Map userIdUnreadStatus = {};
  DateTime yearEndDay;
  DateTime yearStartDay;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _token;

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    List topics = getTopics();
    int topicIndex = 0;
    super.initState();

    _setLoggedInStatus(true);

    streamController = StreamController();

    monthWithYearActivities = {};
    activityWithYearNames = [];
    holidayDays = {};

    payments = [];
    initialPayments = [];

    schoolDays = <DateTime>[];
    presentDays = <DateTime>[];
    noSchoolDays = <DateTime>[];
    specialSchoolDays = <DateTime>[];
    userIdUnreadStatus = {};

    for (topicIndex = 0; topicIndex < topics.length; topicIndex++) {
      Map topic = topics[topicIndex];

      if (topic['topic'] == 'all') {
        break;
      }
    }

    if (topicIndex == topics.length) {
      addTopic('all', '');
    }

    firebaseCloudMessagingListeners(widget.classId);
    transformActivityList(widget.classId);

    fetchAttendanceInfo(widget.heroTag);
    buildStudentPayments(widget.heroTag);
    setStudentsUnreadNotif(widget.userIds);
    _saveUserProfileData();
    setAvatarUrl(widget.avatarUrl);
    if (!streamController.isClosed) {
      streamController.stream.listen((data) {
        setState(() {
          paymentData = data;
        });
      });
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        updateHomeData();
      },
      onResume: (Map<String, dynamic> message) async {
        updateHomeData();
        setStudentsUnreadNotif(widget.userIds);
      },
      onLaunch: (Map<String, dynamic> message) async {
        updateHomeData();
      },
    );

    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == 'AppLifecycleState.resumed') {
        updateHomeData();
      }

      return null;
    });

    setUnreadNotif(widget.heroTag);
  }

  Future getHolidayList() async {
    return await fetchHolidayList().then((resolve) {
      for (int i = 0; i < resolve.length; i++) {
        Map holiday = resolve[i];
        String holidayTitle = holiday['title'];
        DateTime startHoliday =
            DateTime.parse(holiday['holiday_start_date']).toLocal();
        DateTime endHoliday =
            DateTime.parse(holiday['holiday_end_date']).toLocal();
        DateTime holidayIndexDate = startHoliday;

        for (;
            !(holidayIndexDate.isAtSameMomentAs(endHoliday));
            holidayIndexDate = holidayIndexDate.add(Duration(days: 1))) {
          if (holidayDays[holidayIndexDate] == null) {
            holidayDays[holidayIndexDate] = [];
          }
          holidayDays[holidayIndexDate].add(holidayTitle);
        }

        if (holidayDays[holidayIndexDate] == null) {
          holidayDays[holidayIndexDate] = [];
        }
        holidayDays[holidayIndexDate].add(holidayTitle);
      }
      return Future.value(holidayDays);
    });
  }

  Future setUnreadNotif(String userId) async {
    return await getStudentUnseenNotifications(userId).then((results) {
      if (results['success']) {
        setAllUnreadCount(results['data']);
        if (mounted) setState(() {});
      }
    });
  }

  Future buildStudentPayments(userId) async {
    Completer _completer = Completer();

    await fetchStudentPayments(userId).then((results) {
      String nextPaymentMonth;
      String nextPaymentDay;
      payments = [];
      totalBalance = 0.00;
      totalPayments = 0.00;

      results.forEach((payment) {
        var amount;
        DateTime dueDate;
        String paymentDate = 'Unpaid';
        double dueAmount =
            payment['due_amount'] != null ? payment['due_amount'] + 0.00 : 0.00;

        if (payment['due_date'] != null) {
          dueDate = DateTime.parse(payment['due_date']).toLocal();
        }
        try {
          amount = payment['amount_paid'] != null
              ? payment['amount_paid'].toString()
              : 'N/A';
          if (amount == 'N/A' || amount == null || amount == '0') {
            totalBalance += payment['due_amount'];
            if (nextPaymentMonth == null) {
              nextPaymentMonth = monthNames[dueDate.month - 1];
              nextPaymentDay = '${dueDate.day < 10 ? "0" : ""}${dueDate.day}';
              String nextPaymentpackageNum;

              if (payment['note'] != null) {
                nextPaymentpackageNum = payment['note'].split(',')[0];
              }

              setNextPayment(
                nextPaymentDay,
                nextPaymentMonth,
                nextPaymentpackageNum,
              );
            }
          } else {
            if (payment['amount_paid'] != null) {
              totalPayments += payment['amount_paid'];
            }
          }
        } catch (e) {
          print(e);
        }

        try {
          String paidDate = payment['paid_date'];
          if (paidDate != null) {
            paymentDate = timeFormat(
                DateTime.parse(payment['paid_date']).toLocal().toString(),
                'MMM dd y');
          }
        } catch (e) {}
        payments.add(Payment(
            label: dueDate != null
                ? timeFormat(dueDate.toString(), 'MMM dd y')
                : '',
            amount: amount,
            dueAmount: dueAmount,
            rawDate: dueDate,
            paidDate: paymentDate,
            isPaid: amount != 'N/A',
            paymentModes: payment['note'],
            paymentSettingId: payment['pay_setting_id'].split(',')[0],
            amountDesc: payment['due_desc'],
            checkNo: payment['check_no'],
            paymentType: {
              'type': payment['pay_type'],
              'official_receipt': payment['official_receipt'],
              'bank_abbr': payment['pay_bank']
            },
            paymentNote: payment['description']));
      });
    });
    if (!streamController.isClosed) {
      streamController.add({
        'totalPayments': totalPayments,
        'totalBalance': totalBalance,
        'payments': payments
      });
    }
    _completer.complete();
    return _completer.future;
  }

  List<String> sortActivityNames(activityNamesSort) {
    List<int> sortedMonthIndex = <int>[];
    List<String> sortedMonthNames = <String>[];

    for (int i = 0; i < activityNamesSort.length; i++) {
      String month = activityNamesSort[i];
      int monthIndex = 0;
      int largestMonthIndex = 0;

      for (monthIndex = 0; monthIndex < monthNames.length; monthIndex++) {
        if (monthNames[monthIndex] == month) {
          if (monthIndex > largestMonthIndex) {
            largestMonthIndex = monthIndex;
          }
          break;
        }
      }

      sortedMonthIndex.add(monthIndex);
      sortedMonthIndex.sort();
    }
    for (int i = 0; i < sortedMonthIndex.length; i++) {
      sortedMonthNames.add(monthNames[sortedMonthIndex[i]]);
    }

    return sortedMonthNames;
  }

  Future getAttendanceInfo(userId) async {
    return await Future.wait([
      getHolidayList().then((resolve) async {
        return await getStudentLatestAttendance(userId).then((results) async {
          DateTime today = DateTime.now();
          DateTime thisDay = DateTime(today.year, today.month, today.day);
          try {
            if (results.length > 0 || results != null) {
              Map latestAttendance = results[0];
              DateTime attendanceDate =
                  DateTime.parse(latestAttendance['attendance_date']).toLocal();
              DateTime attendanceDay = DateTime(
                attendanceDate.year,
                attendanceDate.month,
                attendanceDate.day,
              );
              DateTime thisTime = DateTime(
                today.year,
                today.month,
                today.day,
                today.hour,
                today.minute,
              );

              getClassDetails(widget.classId).then((classDetails) {
                Map classDetail = classDetails[0];
                List startTime = classDetail['class_start_schedule'].split(':');
                DateTime classStart = DateTime(
                  today.year,
                  today.month,
                  today.day,
                  int.parse(startTime[0]),
                  int.parse(
                    startTime[1],
                  ),
                );
                if (resolve[thisDay] != null) {
                  attendanceStatus = 'No Class';
                  attendanceStatusColor = Colors.deepPurple[400];
                  attendanceStatusIcon = Icon(
                    Icons.home,
                    color: Colors.deepPurple[600],
                    size: 18.0,
                  );
                } else {
                  if (attendanceDay.isAtSameMomentAs(thisDay)) {
                    if (latestAttendance['in'] == '1') {
                      attendanceStatus = 'Present';
                      attendanceStatusColor = Colors.green;
                      attendanceStatusIcon = Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 18.0,
                      );
                    }
                  } else if (thisTime.isBefore(classStart)) {
                    attendanceStatus =
                        formatMilitaryTime(classDetail['class_start_schedule']);
                    attendanceStatusColor = Theme.of(context).accentColor;
                    attendanceStatusIcon = Icon(
                      Icons.group,
                      color: Colors.orangeAccent,
                      size: 18.0,
                    );
                  } else {
                    attendanceStatus = 'Absent';
                  }
                }
              });
            }
          } catch (e) {
            attendanceStatus = 'Absent';
          }

          if (attendanceStatus == 'Absent') {
            attendanceStatusColor = Colors.redAccent;
            attendanceStatusIcon = Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 18.0,
            );
          }

          await getTotalSchoolDays(userId).then((result) async {
            await getAttendanceDays(userId).then((presents) {
              presents.forEach((result) {
                DateTime attendanceDate =
                    DateTime.parse(result['attendance_date']).toLocal();
                DateTime attendanceDay = DateTime(
                  attendanceDate.year,
                  attendanceDate.month,
                  attendanceDate.day,
                );
                presentDays.add(attendanceDay);
              });
              absentDays = pastSchoolDays - presentDaysNo;
              totalSchoolDays = result['totalDays'] + 0.0;
              resolve.forEach((key, value) {
                DateTime holidayDay = key;
                if (holidayDay.weekday <= 5) {
                  totalSchoolDays--;
                  if ((holidayDay.isBefore(thisDay) ||
                          holidayDay.isAtSameMomentAs(thisDay)) &&
                      !presentDays.contains(holidayDay)) {
                    absentDays--;
                  }
                }
              });
              presentDays.sort((a, b) => a.compareTo(b));
              if (absentDays < 0) absentDays = 0;

              if (mounted) setState(() {});
            });
          });

          return;
        });
      }),
      getPresentDaysNo(userId).then((result) {
        if (mounted)
          setState(() {
            presentDaysNo = result['presentDays'];
          });
      }),
      getAbsentDays(userId).then((result) {
        if (mounted)
          setState(() {
            pastSchoolDays = result['totalDaysNow'];
          });
      }),
      getSchoolYearInformation().then((results) {
        // TODO: Verify which row to get, or if changes from year to year or new one will be added.
        Map schoolYearInformation = results[results.length - 1];
        DateTime yearStart =
            DateTime.parse(schoolYearInformation['quarter_start']).toLocal();
        DateTime yearEnd =
            DateTime.parse(schoolYearInformation['quarter_end']).toLocal();
        yearStartDay = DateTime(yearStart.year, yearStart.month, yearStart.day);
        yearEndDay = DateTime(yearEnd.year, yearEnd.month, yearEnd.day);

        schoolYearStart = yearStartDay.year.toString();
        schoolYearEnd = yearEndDay.year.toString();
      })
    ]);
  }

  Future setStudentsUnreadNotif(List<String> userIds) async {
    otherChildHasUnreadNotif = false;
    userIdUnreadStatus = {};
    for (int i = 0; i < userIds.length; i++) {
      String userId = userIds[i];
      await getStudentUnseenNotifications(userId).then((results) {
        if (results['success']) {
          if (userIdUnreadStatus[userId] == null) {
            userIdUnreadStatus[userId] = false;
          }

          if (results['data'].length > 0) {
            userIdUnreadStatus[userId] = true;
            if (userId != widget.heroTag) {
              otherChildHasUnreadNotif = true;
            }
          }
        }
      });
    }

    if (mounted) setState(() {});

    return Future.value(otherChildHasUnreadNotif);
  }

  void transformActivityList(classId) async {
    await getStudentActivities(classId).then((results) {
      DateTime currTime = DateTime.now().toLocal();
      DateTime currDay = DateTime(currTime.year, currTime.month, currTime.day);
      List<String> weekdayNames = <String>[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ];
      Map yearActivities = {};

      monthWithYearActivities = {};
      activityWithYearNames = [];
      holidayDays = {};

      for (int i = 0; i < results.length; i++) {
        Map activity = results[i];
        DateTime date = DateTime.parse(activity['a_start_date']).toLocal();
        int monthIndex = date.month - 1;
        String month = monthNames[monthIndex];
        int year = date.year;

        date = date.add(Duration(hours: 8));

        if (date.isAfter(currDay) || date.isAtSameMomentAs(currDay)) {
          ActivityEvent activityEvent = ActivityEvent(
            title: activity['a_title'],
            venue: activity['a_location'],
            time: activity['a_time_start'],
            desc: activity['a_desc'],
            day: '${date.day < 10 ? '0' : ''}${date.day.toString()}',
            weekday: weekdayNames[date.weekday - 1],
          );

          if (yearActivities[year] == null) {
            yearActivities[year] = {};
            yearActivities[year][month] = [];
          }
          if (yearActivities[year][month] == null) {
            yearActivities[year][month] = [];
          }
          yearActivities[year][month].add(activityEvent);
        }
      }

      yearActivities.keys.forEach((year) {
        Map monthActivitiesFromYear = yearActivities[year];
        List monthActivitiesFromYearNames =
            monthActivitiesFromYear.keys.toList();
        monthActivitiesFromYearNames =
            sortActivityNames(monthActivitiesFromYearNames);

        for (int i = 0; i < monthActivitiesFromYearNames.length; i++) {
          String monthActivitiesFromYearName = monthActivitiesFromYearNames[i];
          String monthYearLabel = '$monthActivitiesFromYearName $year';

          monthWithYearActivities[monthYearLabel] = [];
          monthWithYearActivities[monthYearLabel]
              .addAll(monthActivitiesFromYear[monthActivitiesFromYearName]);
        }
      });
      List iteratableActivityNames = monthWithYearActivities.keys.toList();
      for (int i = 0; i < iteratableActivityNames.length; i++) {
        activityWithYearNames.add(iteratableActivityNames[i]);
      }
      try {
        nextEventMonth = activityWithYearNames[0];
        nextEventDay = monthWithYearActivities[activityWithYearNames[0]][0].day;
      } catch (e) {}

      if (mounted) setState(() {});
    });
  }

  void firebaseCloudMessagingListeners(String classId) {
    List<Map> topics = getTopics();
    if (Platform.isIOS) iOSPermission();
    _token = "";
    _firebaseMessaging.getToken().then((token) {
      _token = token;
      for (int i = 0; i < topics.length; i++) {
        Map topic = topics[i];
        if (topic['topic'] != null) {
          addNotificationToken(_token, topic['topic'], topic['s_id'])
              .then((result) {
            if (result['code'] == 1) {
              _firebaseMessaging.subscribeToTopic(topic['topic']);
              print('subscribed to $topic');
            }
          });
        }
      }
    });
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
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

  void fetchAttendanceInfo(userId) async {
    await getAttendanceInfo(userId);
  }

  void routeNotificationPage(category) async {
    String _unreadName;
    List unreadNotifIds = [];

    setUnreadNotif(widget.heroTag).then((resolve) {
      if (category == 'progress') {
        _unreadName = 'grade_update';
      }
      if (category == 'Activities') {
        _unreadName = 'activities';
      }
      if (category == 'photos') {
        _unreadName = 'photo_update';
      }
      if (category == 'attendance') {
        _unreadName = 'student_present';
      }
      if (category == 'Payments') {
        _unreadName = 'payment_due';
      }

      if (category == 'messages' || category == 'appointment') {
        unreadNotifIds.addAll(getModuleUnreadNotifIds('announcement'));
        unreadNotifIds.addAll(getModuleUnreadNotifIds('appointment'));
        setCategorySeen('appointment');
        setCategorySeen('announcement');
      } else {
        unreadNotifIds.addAll(getModuleUnreadNotifIds(_unreadName));
        setCategorySeen(_unreadName);
      }

      for (int i = 0; i < unreadNotifIds.length; i++) {
        int id = unreadNotifIds[i];
        seenNotification(id);
      }
    });

    if ((category != null) &&
        ([
          'activity',
          'photos',
          'messages',
          'appointment',
          'progress',
          'attendance',
          'payment',
        ].contains(category))) {
      Widget pageBuilder;
      Route route = MaterialPageRoute(
        builder: (buildContext) => HomePage(
          child: Avatar(
            backgroundColor: Colors.indigo,
            maxRadius: 54.0,
            minRadius: 20.0,
            fontSize: 20.0,
            initial:
                "${widget.firstName != null ? widget.firstName[0] : ''}${widget.lastName != null ? widget.lastName[0] : ''}",
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
        ),
      );
      Navigator.push(context, route);
      if (category == 'activity') {
        pageBuilder = Activities(
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          classId: this.widget.classId,
          userId: this.widget.heroTag,
          monthActivities: this.monthWithYearActivities,
          activityNames: this.activityWithYearNames,
        );
      } else if (category == 'photos') {
        pageBuilder = ActivityGallery(
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          userId: this.widget.heroTag,
          classId: this.widget.classId,
        );
      } else if (category == 'messages' || category == 'appointment') {
        pageBuilder = MessageBoard(
          userId: widget.heroTag,
          firstName: widget.firstName,
          lastName: widget.lastName,
        );
      } else if (category == 'progress') {
        pageBuilder = Grades(
          userId: widget.heroTag,
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          schoolLevel: this.widget.schoolLevel,
        );
      } else if (category == 'attendance') {
        pageBuilder = Attendance(
          firstName: this.widget.firstName,
          lastName: this.widget.lastName,
          userId: this.widget.heroTag,
          schoolDays: this.schoolDays,
          presentDays: this.presentDays,
          noSchoolDays: this.noSchoolDays ?? <DateTime>[],
          specialSchoolDays: this.specialSchoolDays,
          yearStartDay: this.yearStartDay,
          yearEndDay: this.yearEndDay,
          presentDaysNo: this.presentDaysNo,
          pastSchoolDays: this.pastSchoolDays,
          absentDays: this.absentDays,
          totalSchoolDays: this.totalSchoolDays,
        );
      }

      Route routeNew =
          MaterialPageRoute(builder: (buildContext) => pageBuilder);
      Navigator.push(context, routeNew);
    }
  }

  void updateHomeData() async {
    schoolDays = <DateTime>[];
    presentDays = <DateTime>[];
    noSchoolDays = <DateTime>[];
    specialSchoolDays = <DateTime>[];
    userIdUnreadStatus = {};

    transformActivityList(widget.classId);
    fetchAttendanceInfo(widget.heroTag);
    buildStudentPayments(widget.heroTag);
    setUnreadNotif(widget.heroTag);
    setStudentsUnreadNotif(widget.userIds);
  }

  void userData(lname, fname, schoolLevel, classId, gradeLevel, gradeSection,
      avatarUrl, userId) {
    widget.child = Avatar(
      backgroundColor: Colors.indigo,
      maxRadius: 54.0,
      fontSize: 20.0,
      initial:
          "${fname != null ? fname[0] : ''}${lname != null ? lname[0] : ''}",
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
    _saveUserProfileData();
  }

  void _setLoggedInStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (status == false) {
      await prefs.clear();
    }
    await prefs.setBool('isLoggedIn', status);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    Map nextPayment = getNextPayment();
    String nextPaymentDay = nextPayment['nextPaymentDay'];
    String nextPaymentMonth = nextPayment['nextPaymentMonth'];
    String nextPaymentPackageNum = nextPayment['nextPaymentPackageNum'];
    height *= .2;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.black, // Color for Android
          statusBarBrightness:
              Brightness.dark // Dark == white status bar -- for IOS.
          ),
    );

    if (widget.userIds == null) {
      widget.userIds = [];
      widget.userIds.add(widget.heroTag);
    }

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
                  drawer: _Drawer(
                    name:
                        '${this.widget.firstName ?? ""} ${this.widget.lastName ?? ""}',
                    picture: widget.child,
                    onLogout: () {
                      List topics = getTopics();
                      _setLoggedInStatus(false);
                      removeNotificationToken(_token).then((resolves) {
                        for (int i = 0; i < topics.length; i++) {
                          String topic = topics[i]['topic'];

                          _firebaseMessaging.unsubscribeFromTopic(topic);
                        }

                        Route route =
                            MaterialPageRoute(builder: (BuildContext context) {
                          return LoginPage();
                        });
                        Navigator.push(context, route);
                      });
                    },
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
                                image: AssetImage(
                                  'img/home_profile_head_cover.png',
                                ),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 20.0),
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
                                                firstName:
                                                    this.widget.firstName,
                                                lastName: this.widget.lastName,
                                              ));
                                      Navigator.push(context, route);
                                    },
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Hero(
                                          tag: this.widget.heroTag ?? '',
                                          child: this.widget.child),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.0),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Material(
                                        color: Color.fromRGBO(255, 255, 255, 0),
                                        child: InkWell(
                                          onTap: () {
                                            setStudentsUnreadNotif(
                                                widget.userIds);
                                            setState(() {
                                              showStudentSwitcher = true;
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '${this.widget.lastName ?? ""}, ${this.widget.firstName ?? ""}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              otherChildHasUnreadNotif
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 6.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.red[600],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      24.0),
                                                        ),
                                                        constraints:
                                                            BoxConstraints(
                                                          minWidth: 9,
                                                          minHeight: 9,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.0),
                                              ),
                                              Text(
                                                '􀄥',
                                                style: TextStyle(
                                                  fontFamily: 'SFPro',
                                                  color: Colors.white,
                                                  fontSize: 9.0,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 1.0),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'S.Y. ${schoolYearStart ?? ""}-${schoolYearEnd ?? ""}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3.0),
                                          ),
                                          Text(
                                            '${widget.gradeSection}',
                                            style:
                                                TextStyle(color: Colors.white),
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
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.0),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: double.infinity,
                                          maxHeight: 90.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [BrandTheme.cardShadow],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(7.0),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          child: Flex(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            direction: Axis.horizontal,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: OverflowBox(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Flex(
                                                        direction:
                                                            Axis.vertical,
                                                        mainAxisAlignment:
                                                            nextPaymentDay !=
                                                                        null &&
                                                                    nextPaymentDay !=
                                                                        null
                                                                ? MainAxisAlignment
                                                                    .spaceBetween
                                                                : MainAxisAlignment
                                                                    .start,
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              'Next Payment',
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ),
                                                          nextPaymentDay !=
                                                                      null &&
                                                                  nextPaymentDay !=
                                                                      null
                                                              ? nextPaymentPackageNum ==
                                                                          '3.1' ||
                                                                      nextPaymentPackageNum ==
                                                                          '3'
                                                                  ? Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(vertical: 20.0),
                                                                          child:
                                                                              Row(
                                                                            children: <Widget>[
                                                                              Container(
                                                                                width: 8.0,
                                                                                height: 1.0,
                                                                                decoration: BoxDecoration(color: Colors.grey[300]),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                                              ),
                                                                              Container(
                                                                                width: 8.0,
                                                                                height: 1.0,
                                                                                decoration: BoxDecoration(color: Colors.grey[300]),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                                              ),
                                                                              Container(
                                                                                width: 8.0,
                                                                                height: 1.0,
                                                                                decoration: BoxDecoration(color: Colors.grey[300]),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          nextPaymentMonth ??
                                                                              "",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black38,
                                                                            fontSize:
                                                                                12.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          nextPaymentDay ??
                                                                              "",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Theme.of(context).accentColor,
                                                                            fontSize:
                                                                                20.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                              : Expanded(
                                                                  flex: 1,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        'Fully paid!',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.green,
                                                                          fontSize:
                                                                              15.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
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
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: OverflowBox(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: <Widget>[
                                                      Flex(
                                                        direction:
                                                            Axis.vertical,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Text(
                                                              'Attendance',
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 2),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: <
                                                                  Widget>[
                                                                attendanceStatus ==
                                                                        'No Class'
                                                                    ? Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                                Flex(
                                                                  direction: Axis
                                                                      .horizontal,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: <
                                                                      Widget>[
                                                                    Flexible(
                                                                      flex: 0,
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            attendanceStatusIcon,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 0,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: 2.0),
                                                                        child:
                                                                            Text(
                                                                          attendanceStatus,
                                                                          overflow:
                                                                              TextOverflow.fade,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                attendanceStatusColor,
                                                                            fontSize:
                                                                                15.0,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                attendanceStatus !=
                                                                        'No Class'
                                                                    ? Text(
                                                                        '$presentDaysNo/${totalSchoolDays.floor()}',
                                                                        overflow:
                                                                            TextOverflow.fade,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black38,
                                                                          fontSize:
                                                                              12.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      )
                                                                    : Container(),
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
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                              ),
                                              Flexible(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          'Next Event',
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        nextEventMonth !=
                                                                    null &&
                                                                nextEventDay !=
                                                                    null
                                                            ? Column(
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    nextEventMonth ??
                                                                        '',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black38,
                                                                      fontSize:
                                                                          12.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    nextEventDay ??
                                                                        '',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .accentColor,
                                                                      fontSize:
                                                                          20.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Expanded(
                                                                flex: 1,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'Stay tuned.',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey[500],
                                                                        fontSize:
                                                                            14.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 10.0,
                                    ),
                                    children: <Widget>[
                                      MenuItem(
                                        iconPath: 'img/Icons/icon_payments.png',
                                        label: 'Payments',
                                        cardShadow: dynamicCardShadow(
                                          Color.fromRGBO(83, 162, 193, .35),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 10.0,
                                        ),
                                        pageBuilder: PaymentHistory(
                                          firstName: this.widget.firstName,
                                          lastName: this.widget.lastName,
                                          userId: this.widget.heroTag,
                                        ),
                                        buildContext: context,
                                      ),
                                      MenuItem(
                                        iconPath:
                                            'img/Icons/icon_attendance.png',
                                        label: 'Attendance',
                                        cardShadow: dynamicCardShadow(
                                          Color.fromRGBO(6, 140, 92, .35),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
                                        ),
                                        pageBuilder: Attendance(
                                          firstName: this.widget.firstName,
                                          lastName: this.widget.lastName,
                                          userId: this.widget.heroTag,
                                          schoolDays: this.schoolDays,
                                          presentDays: this.presentDays,
                                          noSchoolDays:
                                              this.noSchoolDays ?? <DateTime>[],
                                          specialSchoolDays:
                                              this.specialSchoolDays,
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
                                        iconPath: 'img/Icons/icon_grades.png',
                                        label: 'Progress',
                                        cardShadow: dynamicCardShadow(
                                          Color.fromRGBO(242, 197, 54, .35),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
                                        ),
                                        pageBuilder: Grades(
                                          userId: widget.heroTag,
                                          firstName: this.widget.firstName,
                                          lastName: this.widget.lastName,
                                          schoolLevel: this.widget.schoolLevel,
                                        ),
                                        buildContext: context,
                                      ),
                                      MenuItem(
                                        iconPath:
                                            'img/Icons/icon_activities.png',
                                        label: 'Activities',
                                        cardShadow: dynamicCardShadow(
                                          Color.fromRGBO(123, 76, 167, .35),
                                        ),
                                        pageBuilder: Activities(
                                          firstName: this.widget.firstName,
                                          lastName: this.widget.lastName,
                                          classId: this.widget.classId,
                                          userId: this.widget.heroTag,
                                          monthActivities:
                                              this.monthWithYearActivities,
                                          activityNames:
                                              this.activityWithYearNames,
                                        ),
                                        buildContext: context,
                                      ),
                                      MenuItem(
                                        iconPath: 'img/Icons/icon_gallery.png',
                                        label: 'Classroom',
                                        cardShadow: dynamicCardShadow(
                                            Color.fromRGBO(219, 69, 58, .35)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        pageBuilder: ActivityGallery(
                                          firstName: this.widget.firstName,
                                          lastName: this.widget.lastName,
                                          userId: this.widget.heroTag,
                                          classId: this.widget.classId,
                                        ),
                                        buildContext: context,
                                      ),
                                      MenuItem(
                                        iconPath:
                                            'img/Icons/icon_announcements.png',
                                        label: 'Messages',
                                        cardShadow: dynamicCardShadow(
                                            Color.fromRGBO(252, 142, 43, .35)),
                                        pageBuilder: MessageBoard(
                                          userId: widget.heroTag,
                                          firstName: widget.firstName,
                                          lastName: widget.lastName,
                                        ),
                                        buildContext: context,
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
                      height: 46,
                      margin:
                          EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("img/mywoodbridge.png"),
                          fit: BoxFit.fitWidth,
                        ),
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
                          Route route = MaterialPageRoute(
                            builder: (buildContext) => Notifications(
                              firstName: this.widget.firstName,
                              lastName: this.widget.lastName,
                              userId: this.widget.heroTag,
                            ),
                          );
                          Navigator.push(context, route);
                        },
                        icon: Icon(
                          Icons.notifications_none,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              Positioned.fill(
                child: SafeArea(
                  child: showStudentSwitcher
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(0, 0, 0, .88)),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              margin: EdgeInsets.only(top: height),
                              child: Flex(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: Text(
                                      'Select Student',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 360.00),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: GridView.count(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            primary: false,
                                            childAspectRatio: .9,
                                            crossAxisCount: 2,
                                            physics: BouncingScrollPhysics(),
                                            children:
                                                widget.userIds.map((userId) {
                                              return StudentAvatarPicker(
                                                userId: '$userId',
                                                isActive:
                                                    userId == widget.heroTag,
                                                hasUnreadNotif:
                                                    userIdUnreadStatus[
                                                            userId] ??
                                                        false,
                                                onTap: (
                                                  lname,
                                                  fname,
                                                  schoolLevel,
                                                  classId,
                                                  gradeLevel,
                                                  gradeSection,
                                                  avatarUrl,
                                                ) {
                                                  showStudentSwitcher = false;

                                                  userData(
                                                    lname,
                                                    fname,
                                                    schoolLevel,
                                                    classId,
                                                    gradeLevel,
                                                    gradeSection,
                                                    avatarUrl,
                                                    userId,
                                                  );
                                                },
                                              );
                                            }).toList()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      : Container(),
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
    this.customOnPressed,
    this.cardShadow,
    this.padding,
  }) : super(key: key);

  final BuildContext buildContext;
  final Widget child;
  final String iconPath;
  var customOnPressed;
  final String label;
  final Widget pageBuilder;
  bool isCustomOnPressed;
  EdgeInsetsGeometry padding;
  BoxShadow cardShadow;
  String _unreadName;
  int unreadCount = 0;
  List unreadNotifIds = [];

  @override
  Widget build(BuildContext context) {
    label == 'Progress' ? _unreadName = 'grade_update' : null;
    label == 'Activities' ? _unreadName = 'activity_new' : null;
    label == 'Photos' ? _unreadName = 'photo_update' : null;
    label == 'Attendance' ? _unreadName = 'student_present' : null;
    label == 'Payments' ? _unreadName = 'payment_due' : null;

    if (label == 'Messages') {
      unreadCount = getModuleUnreadCount('appointment') +
          getModuleUnreadCount('announcement') +
          getModuleUnreadCount('pdf');
      unreadNotifIds.addAll(getModuleUnreadNotifIds('appointment'));
      unreadNotifIds.addAll(getModuleUnreadNotifIds('announcement'));
      unreadNotifIds.addAll(getModuleUnreadNotifIds('pdf'));
    } else {
      unreadCount = getModuleUnreadCount(_unreadName);
      unreadNotifIds.addAll(getModuleUnreadNotifIds(_unreadName));
    }

    if (isCustomOnPressed == null) {
      isCustomOnPressed = false;
    }

    if (label == 'Payments' || label == 'Activities') {
      if (unreadCount > 0) {
        unreadCount = -1;
      }
    }

    return Material(
      child: InkWell(
        onTap: () {
          for (int i = 0; i < unreadNotifIds.length; i++) {
            int id = unreadNotifIds[i];
            seenNotification(id);
          }
          if (label == 'Messages') {
            setCategorySeen('appointment');
            setCategorySeen('announcement');
          } else {
            setCategorySeen(_unreadName);
          }
          if (isCustomOnPressed) {
            customOnPressed();
          } else {
            Route route =
                MaterialPageRoute(builder: (buildContext) => pageBuilder);
            Navigator.push(buildContext, route);
          }
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                boxShadow: [cardShadow],
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(7.0),
                ),
              ),
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: padding ??
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(iconPath),
                          ),
                        ),
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
                        color: Color.fromRGBO(0, 0, 0, .55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            unreadCount > 0 || unreadCount < 0
                ? Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: unreadCount < 0 ? Colors.blueAccent : Colors.red,
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 17,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${unreadCount < 0 ? '' : unreadCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  final String name;
  final Widget picture;
  final onLogout;

  const _Drawer({
    Key key,
    this.name,
    this.picture,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Flexible(
            flex: 0,
            child: UserAccountsDrawerHeader(
              accountName: Text(
                name ?? 'N/A',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
              ),
              otherAccountsPictures: <Widget>[
                IconButton(
                  icon: Icon(Icons.close),
                  color: Color.fromRGBO(255, 255, 255, .35),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashColor: Colors.white,
                )
              ],
              currentAccountPicture: picture,
              accountEmail: null,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.book),
                          onTap: () {
                            Route route = MaterialPageRoute(
                                builder: (BuildContext context) {
                              return InitialOnboard(
                                userIds: [],
                                showAgreementCta: false,
                              );
                            });
                            Navigator.push(context, route);
                          },
                          title: Text(
                            "Parents' Guide",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.payment),
                          onTap: () {
                            Route route = MaterialPageRoute(
                                builder: (BuildContext context) {
                              return PaymentGuide();
                            });
                            Navigator.push(context, route);
                          },
                          title: Text(
                            "Payment Guide",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
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
                              color: Colors.black87,
                            ),
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
                          leading: Icon(Icons.info),
                          title: Text(
                            'About Us',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          onTap: () {
                            Route route = MaterialPageRoute(
                                builder: (BuildContext context) {
                              return AboutUs();
                            });
                            Navigator.push(context, route);
                          },
                        ),
                        Flexible(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: ExpansionTile(
                              leading: Icon(Icons.phone),
                              initiallyExpanded: false,
                              onExpansionChanged: (_isExpanded) {},
                              title: Text(
                                'Contact Us',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              children: <Widget>[
                                Flex(
                                  direction: Axis.vertical,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          left: 20.0,
                                          right: 18.0,
                                          bottom: 12.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Icon(Icons.location_on,
                                                    color: Colors.grey[600],
                                                    size: 16.0),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "#5 23rd Street, Capitol Subdivision",
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Bacolod City, Negros Occidental",
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      "6100 Philippines",
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 6.0)),
                                            Flex(
                                              direction: Axis.vertical,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(Icons.phone,
                                                        color: Colors.grey[600],
                                                        size: 16.0),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                    ),
                                                    Text(
                                                      Labels.phoneNum,
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(Icons.email,
                                                        color: Colors.grey[600],
                                                        size: 16.0),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                    ),
                                                    Text(
                                                      "hello@thewoodbridgeacademy.com",
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                            color: Colors.black87,
                          ),
                        ),
                        onTap: onLogout,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
