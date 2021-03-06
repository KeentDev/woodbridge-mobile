import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

import 'package:flutter/material.dart';
import 'woodbridge-ui_components.dart';

class Grade {
  Grade({this.subject, this.first, this.second, this.third, this.fourth, this.ave});

  String ave;
  String first;
  String fourth;
  String second;
  String subject;
  String third;
}

class Areas {
  String location;
  String number;
}

Future<List> fetchMarkingCodes(schoolLevel) async {
  String url = '$baseApi/grade/get-all-marking-code';

  var response = await http.post(url, body: json.encode({
    'data': schoolLevel
  }),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    });

  return jsonDecode(response.body);
}
Future<List> fetchGrades(userId) async {
  String url = '$baseApi/grade/get-grades';

  var response = await http.post(url, body: json.encode({
    'data': userId
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}
Future<List> fetchPsychSkills(userId, schoolLevel) async {
  String url = '$baseApi/grade/get-skills-mobile';

  var response = await http.post(url, body: json.encode({
    'data': {
      's_id': userId,
      'school_level': schoolLevel
    }
  }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      });

  return jsonDecode(response.body);
}

class Grades extends StatefulWidget {
  Grades({
    this.firstName,
    this.lastName,
    this.userId,
    this.schoolLevel,
  });

  final String firstName;
  final String lastName;
  final String schoolLevel;
  final String userId;

  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  @override
  Widget build(BuildContext context) {

    Future buildGrades(userId) async {
      List<Widget> gradeWidgets = <Widget>[];

      await fetchGrades(userId)
        .then((result) {
          List resultGrades = result;
          for(var i = 0; i < resultGrades.length; i++){
            Map subject = resultGrades[i];

            gradeWidgets.add(GradeCard(
              grade: Grade(
                subject: subject['subjects'],
                first: subject['first'],
                second: subject['second'],
                third: subject['third'],
                fourth: subject['fourth'],
                ave: subject['ave']
              ),
            ));
          }
        });

      return gradeWidgets;
    }

    Future buildPsychSkills(userId, schoolLevel) async {
      List<Widget> skillWidgets = <Widget>[];

      await fetchPsychSkills(userId, schoolLevel)
        .then((result) {
          List resultGrades = result;

          for(var i = 0; i < resultGrades.length; i++){
            Map subject = resultGrades[i];

            skillWidgets.add(GradeCard(
              includeAve: false,
              grade: Grade(
                subject: subject['skill_desc'],
                first: subject['first'],
                second: subject['second'],
                third: subject['third'],
                fourth: subject['fourth'],
              ),
            ));
          }
        });

      return skillWidgets;
    }

    Future buildMarkingCodes(schoolLevel) async {
      List<Widget> markingCodes = <Widget>[];

      await fetchMarkingCodes(schoolLevel)
        .then((results) {
          for(int i = 0; i < results.length; i++){
            Map markingCode = results[i];

            markingCodes.add(
              Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              markingCode['code_abb'],
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).accentColor
                              ),
                            ),
                            Text(
                              markingCode['code_title'].toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700]
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Text(
                          markingCode['code_desc'],
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87
                          ),
                        )
                    )
                  ],
                )
            );
            if(i != results.length - 1){
              markingCodes.add(
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  child: Divider(
                    height: 16.0,
                    color: Colors.grey[400]
                  ),
                )
              );
            }
          }
      });

      return markingCodes;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Progress'),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              ProfileHeader(
                firstName: this.widget.firstName,
                lastName: this.widget.lastName,
                heroTag: this.widget.userId,
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(7.0))
                      ),
                      margin: EdgeInsets.only(top: 40.0, bottom: 20.0, left: 20.0, right: 20.0),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Marking Code',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(
                                height: 16.0,
                                color: Colors.grey[300],
                              ),
                            ),
                            FutureBuilder(
                              future: buildMarkingCodes(widget.schoolLevel),
                              builder: (BuildContext context, AsyncSnapshot snapshot){
                                if(snapshot.connectionState == ConnectionState.done){
                                  return Column(
                                    children: snapshot.data ?? <Widget>[Container()],
                                  );
                                }else{
                                  return Text('Fetching marking codes...');
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Academic Performance',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: FutureBuilder(
                        future: buildGrades(widget.userId),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if(snapshot.connectionState == ConnectionState.done){
                            return Column(
                              children: snapshot.data ?? <Widget>[Container()]
                            );
                          }else{
                            return Text('fetching grade information...');
                          }
                        },
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Psychosocial Skills',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: FutureBuilder(
                        future: buildPsychSkills(widget.userId, widget.schoolLevel),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if(snapshot.connectionState == ConnectionState.done){
                            return Column(
                              children: snapshot.data ?? <Widget>[Container()]
                            );
                          }else{
                            return Text('fetching grade information...');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

class GradeCard extends StatelessWidget {
  GradeCard({
    this.grade,
    this.includeAve
  });

  final Grade grade;
  bool includeAve = true;

  @override
  Widget build(BuildContext context) {

    if(includeAve == null){
      includeAve = true;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(7.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Text(
              grade.subject,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16.0,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          Container(
            height: 54.0,
            margin: EdgeInsets.symmetric(vertical: 12.0),
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                QuarterGrade(
                  label: '1st',
                  value: grade.first,
                ),
                Container(
                  height: double.infinity,
                  width: 1.0,
                  color: Colors.black12,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                QuarterGrade(
                  label: '2nd',
                  value: grade.second,
                ),
                Container(
                  height: double.infinity,
                  width: 1.0,
                  color: Colors.black12,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                QuarterGrade(
                  label: '3rd',
                  value: grade.third,
                ),
                Container(
                  height: double.infinity,
                  width: 1.0,
                  color: Colors.black12,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                QuarterGrade(
                  label: '4th',
                  value: grade.fourth,
                ),
                includeAve ? Container(
                  height: double.infinity,
                  width: 1.0,
                  color: Colors.black12,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                ) : Container(),
                includeAve ? QuarterGrade(
                  label: 'Ave',
                  value: grade.ave,
                ) : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuarterGrade extends StatelessWidget {
  QuarterGrade({
    this.label,
    this.value
  });

  final String label;
  String value;

  @override
  Widget build(BuildContext context) {
    if(value != null){
      value = value.toUpperCase();
    }
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.0),
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500
              ),
            ),
            Text(
              value ?? '-',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: value == null ? FontWeight.w400 : FontWeight.w700,
                color: value == null ? Colors.black38 : Theme.of(context).accentColor
              ),
            )
          ],
        ),
      ),
    );
  }
}
