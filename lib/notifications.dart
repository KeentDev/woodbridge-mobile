import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'woodbridge-ui_components.dart';
import 'package:flutter/services.dart';
import 'services.dart';

class Notifications extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String userId;
  int pageNum = 1;
  int pageSize;
  bool completedAllPages = false;
  List<List<Widget>> notificationTiles;

  Notifications({
    this.firstName,
    this.lastName,
    this.userId,
    this.notificationTiles,
    this.pageSize,
  });

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Container(
        height: double.infinity,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 0,
                    child: ProfileHeader(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      heroTag: widget.userId,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: widget.notificationTiles[widget.pageNum - 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PaginationControl(
              pageNum: widget.pageNum,
              prevCallback: () {
                setState(() {
                  widget.pageNum--;
                });
              },
              nextCallback: () async {
                widget.pageNum++;

                if(widget.pageNum == widget.notificationTiles.length){
                  await buildNotificationList(widget.userId, widget.pageSize, widget.pageNum)
                    .then((result) {
                      widget.notificationTiles.addAll(result['notifications']);
                    });
                }
                setState(() {});
              },
              nextDisableCondition: widget.notificationTiles[widget.pageNum].length == 0 || widget.notificationTiles[widget.pageNum - 1].length == 0,
            )
          ],
        ),
      )
    );
  }
}