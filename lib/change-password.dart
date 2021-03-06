import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

import 'woodbridge-ui_components.dart';
import 'package:flutter/material.dart';

import 'initial_onboard.dart';
import 'student_picker.dart';

Future changePassword(userId, password) async {
  String url = '$baseApi/account/change-pass';

  var response = await http.post(url,
      body: json.encode({
        'data': {
          'user_id': userId,
          'pass': password,
        }
      }),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'});

  return jsonDecode(response.body);
}

class ChangePassword extends StatelessWidget {
  ChangePassword({this.userId, this.userIds, this.hasAgreed, this.maxPageCount});

  final bool hasAgreed;
  final int maxPageCount;
  final String userId;
  final List<String> userIds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Update Password'),
        ),
        body: ChangePasswordPage(
          userId: userId,
          userIds: userIds,
          hasAgreed: hasAgreed,
          // guidePages: guidePages,
          maxPageCount: maxPageCount,
        ));
  }
}

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({this.userId, this.userIds, this.hasAgreed, this.maxPageCount});

  final bool hasAgreed;
  final int maxPageCount;
  final String userId;
  final List<String> userIds;

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String noticeText;
  bool hasFinishedLoading = false;
  bool updateInitialTapped = false;

  final _formKey = GlobalKey<FormState>();
  var _passwordAgainController = TextEditingController();
  var _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkAgreement();
  }

  void checkAgreement() async {
    if (widget.hasAgreed) {
      noticeText = "Looks like you've forgotten your password, please change it here.";
    } else {
      noticeText = "To activate your account, update to a new password.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SingleChildScrollView(
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Flexible(
                  flex: 0,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 248, 225, 1),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(color: Colors.amber[300])),
                    child: Text(
                      noticeText ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(0, 0, 0, .6),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 0,
                  child: SizedBox(
                    width: 300.0,
                    child: Container(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                autofocus: true,
                                controller: _passwordController,
                                obscureText: true,
                                validator: (value) {
                                  final validCharacters = RegExp(r'^[a-zA-Z0-9_\-=@,\.;]+$');

                                  if (value.isEmpty) {
                                    return 'Enter a password';
                                  }
                                  if (value == 'woodbridge') {
                                    return 'Please set a new password';
                                  }
                                  if (!validCharacters.hasMatch(value)) {
                                    return 'Avoid using special characters';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: false,
                                  labelText: 'New Password',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                controller: _passwordAgainController,
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter password again';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: false,
                                  labelText: 'Re-type password',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: accentCtaButton(
              label: !updateInitialTapped || hasFinishedLoading
                  ? 'Update password'
                  : updateInitialTapped && hasFinishedLoading ? 'Updated!' : 'Updating...',
              isDisabled: updateInitialTapped && !hasFinishedLoading,
              onPressed: (() {
                final errorSnackBar = SnackBar(
                  content: Text(
                    'Password does not match. Please try again.',
                    style: TextStyle(color: Colors.amberAccent),
                  ),
                  action: SnackBarAction(
                    label: 'Okay',
                    textColor: Colors.white,
                    onPressed: () {
                      // Some code to undo the change.
                    },
                  ),
                );
                final processingSnackBar = SnackBar(
                  content: Text(
                    'Updating your password...',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                );
                final handbookSnackbar = SnackBar(
                  content: Text(
                    "Fetching parent's guide...",
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                );
                final successSnackBar = SnackBar(
                  content: Text(
                    'Successfully updated your password!',
                    style: TextStyle(
                      color: Colors.greenAccent,
                    ),
                  ),
                  action: SnackBarAction(
                    label: 'Okay',
                    textColor: Colors.white,
                    onPressed: () {
                      // Some code to undo the change.
                    },
                  ),
                );

                if (_formKey.currentState.validate()) {
                  if (_passwordController.text == _passwordAgainController.text) {
                    Scaffold.of(context).showSnackBar(processingSnackBar);
                    changePassword(widget.userId, _passwordAgainController.text).then((resolves) async {
                      Route route;
                      Scaffold.of(context).showSnackBar(successSnackBar);
                      if (widget.hasAgreed) {
                        route = MaterialPageRoute(builder: (BuildContext context) {
                          return StudentPicker(users: widget.userIds);
                        });
                        Navigator.push(context, route);
                      } else {
                        Scaffold.of(context).showSnackBar(handbookSnackbar);
                        setState(() {
                          updateInitialTapped = true;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return InitialOnboard(
                                userIds: widget.userIds,
                                showAgreementCta: true,
                                userId: widget.userId,
                              );
                            },
                          ),
                        );
                      }
                    });
                  } else {
                    Scaffold.of(context).showSnackBar(errorSnackBar);
                  }
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Please review fields again before proceeding.',
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                    action: SnackBarAction(
                      label: 'Okay',
                      textColor: Colors.white,
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),
                  ));
                }
                return null;
              }),
            ),
          )
        ],
      ),
    );
  }
}
