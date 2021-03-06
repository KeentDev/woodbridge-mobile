import 'package:flutter/material.dart';
import 'woodbridge-ui_components.dart';
import 'notification_services.dart';

class Notifications extends StatefulWidget {
  Notifications({
    this.firstName,
    this.lastName,
    this.userId,
  });

  bool completedAllPages = false;
  final String firstName;
  bool hasInitiated = false;
  final String lastName;
  List<List<Widget>> notificationTiles = <List<Widget>>[];
  int pageNum = 1;
  final int pageSize = 10;
  final String userId;

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
                  FutureBuilder(
                    future: !widget.hasInitiated ? buildNotificationList(this.widget.userId, this.widget.pageSize, 1) : Future.value(<Widget>[Container()]),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if(snapshot.connectionState == ConnectionState.done || widget.hasInitiated){
                        if(!widget.hasInitiated){
                          widget.notificationTiles = snapshot.data['notifications'];
                          widget.hasInitiated = true;
                        }
                        return Expanded(
                          child: widget.pageNum < widget.notificationTiles.length ? Column(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: widget.notificationTiles[0].length != 0 ? SingleChildScrollView(
                                  child: Column(
                                    children: widget.notificationTiles[widget.pageNum - 1],
                                    ),
                                  ) : Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "No notifications yet. We'll let you know if we've got something for you.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                              Flexible(
                                flex: 0,
                                child: PaginationControl(
                                  pageNum: widget.pageNum,
                                  prevCallback: () {
                                    setState(() {
                                      widget.pageNum--;
                                    });
                                  },
                                  nextCallback: () async {
                                    widget.pageNum++;
                                    if(widget.pageNum == widget.notificationTiles.length){
                                      await buildNotificationList(widget.userId, widget.pageSize, widget.pageNum).then((result) {
                                        widget.notificationTiles.addAll(result['notifications']);
                                      });
                                    }
                                    setState(() {});
                                  },
                                  nextDisableCondition: widget.notificationTiles[widget.pageNum].length == 0 || widget.notificationTiles[widget.pageNum - 1].length == 0,
                                ),
                              )
                            ],
                          ) : Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 64.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }else{
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 64.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}