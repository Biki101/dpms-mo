import 'dart:typed_data';

import 'package:dental/components/drawer.dart';
import 'package:dental/services/notification.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var notificationData = [];

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  void getNotifications() async {
    var data = await Notificationservice().getNotifications() ?? {};
    setState(() {
      notificationData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(54, 135, 147, 1),
        title: const Text(
          'Notification',
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: notificationData.length == 0
            ? Text('No New Notification')
            : ListView.builder(
                itemCount: notificationData.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        // color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(54, 135, 147, 1),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            width: double.infinity,
                            child: Text(
                              notificationData[index]['title'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                  child: Html(
                                      data: notificationData[index]['body'])),
                              notificationData[index]['image_name'] == null ||
                                      notificationData[index]['image_name'] ==
                                          ''
                                  ? Text('')
                                  : FutureBuilder<Uint8List>(
                                      future: Notificationservice()
                                          .fetchNoticeBlobImage(
                                              notificationData[index]
                                                  ['image_name']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text('loading');
                                        } else if (snapshot.hasError) {
                                          print('Error: ${snapshot.error}');
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return Image.memory(snapshot.data!);
                                        }
                                      },
                                    )
                            ],
                          )
                        ]),
                  );
                },
              ),
      ),
      drawer: NavDrawer(),
    );
  }
}
