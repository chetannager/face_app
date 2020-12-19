import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_app/camera.dart';
import 'package:face_app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraController cameraController;
  bool isLoading = false;
  bool isResult = false;
  String recognizeImg;
  File recognizeImg2;

  List<dynamic> reconganizationResult = [
    {
      "name": "looks like a face",
      "result": "99.9 %",
    },
    {
      "name": "appears to be female",
      "result": "99.3 %",
    },
    {
      "name": "age range",
      "result": "21 - 33 years old",
    },
    {
      "name": "smiling",
      "result": "92.2 %",
    },
  ];

  recognizeDetails() async {
    setState(() {
      isLoading = true;
      isResult = false;
    });
    Map<String, dynamic> requestData = {
      "headers": {
        "X-Amz-User-Agent": "aws-sdk-js/2.407.0 promise",
        "Content-Type": "application/x-amz-json-1.1",
        "X-Amz-Target": "RekognitionService.DetectFaces",
        "X-Rekognition-Consumer": "console"
      },
      "path": "/",
      "method": "POST",
      "region": "ap-south-1",
      "params": {},
      "contentString":
          "{\"Image\":{\"Bytes\":\"/9j/4AAQSkZJRgABAQAAAQABAAD/4QCQRXhpZgAASUkqAAgAAAADADEBAgAHAAAAMgAAADsBAgAHAAAAOQAAAGmHBAABAAAAQAAAAAAAAABHb29nbGUAUGljYXNhAAMAAJAHAAQAAAAwMjIwAaADAAEAAAABAAAABaAEAAEAAABqAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAP/hAepodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNS4wIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtcDpDcmVhdG9yVG9vbD0iR29vZ2xlIj4gPGRjOmNyZWF0b3I+IDxyZGY6U2VxPiA8cmRmOmxpPlBpY2FzYTwvcmRmOmxpPiA8L3JkZjpTZXE+IDwvZGM6Y3JlYXRvcj4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+ICAgPD94cGFja2V0IGVuZD0idyI/Pv/bAIQAAwICAwICAwMDAwQDAwQFCAUFBAQFCgcHBggMCgwMCwoLCw0OEhANDhEOCwsQFhARExQVFRUMDxcYFhQYEhQVFAEDBAQFBAUJBQUJFA0LDRQUFBQUFBQUFBQUFBQUFBMUFBQUExQUEhUTFBQUEBQUFBUUEhUUERQVFBQTEhMVFBER/8AAEQgAIAAgAwERAAIRAQMRAf/EABgAAAMBAQAAAAAAAAAAAAAAAAYHCAkF/8QALRAAAgEDAwMCBAcBAAAAAAAAAQIDBAURBgchABIxFGETIkFRCBUyM0NxoQn/xAAZAQADAQEBAAAAAAAAAAAAAAAFBgcEAwj/xAAzEQABAgQEAwYDCQAAAAAAAAABAgMABAUREiExQQYTUWFxgZGh8BQi4RUyQlJyorHB8f/aAAwDAQACEQMRAD8At6wQXBaaMJTU9Px/JIWP+AdS9yxJziMSaHrAtgeMS9rT/oNNarvVwaS0jWaptVO5ia5h2giYg8lFETkr7kj+uqDK8IJUgGcmA2s/hyJ9SIpUpQJ5bPMdcI/SnIeeZhzbDbzWLerS0epLRDLT+nqTS1lFU/rp5lCsUJHDDDKQfseQDkBRq9LepExyHje4uCNx7v7zhHmZBVIm0pczGR6XF/oYedwkjrIvipjDDOB0COcNs0tuYTzEbwMUnbU0jwsSiyIUJQ4IyMcHruDhVcQmSTgAETDtfstRaH0kLRV6mjs9tmiNtFO0ZephqFX5mIABBJRjx9GznpkqFVXOzJdDOJYOInYg6detu/KPTcq4fhxy1YhtY2B62/mHptrt7p/SWnvQaaqkr7f8Uu9bEB21MvaqvJkZB5XGcnx5PnoDNTT806VzAsdAOg6RFuKpQPT6VJFjhF99zb01g+iX0tP2Fsj36wwGbHIbw3gbtFxV4EbIx1qWixtCjKvYQImzVu5tv3Q3nW26BqIfzampDGl69KZElmDYlVM9uQqBPnBKtyD3ADp2VTH6VTROT6TgJzTexA2J7zfLUZaXi8cIF1LS2HlYb5pBsct+7aD7cLcnUGwNdY6uvZtRWC70rRtHOqQSx1kWGkcMiYAkV89nbgGMgduRnFw9TZbiNp1lI5TjZuCLkFKtAQTsRre+ed458RSKHHuchXzaHw0gp25370/unRy/l7vTV0UQmekmIJMZ8OhHDLkgZ4IyMgZGcVa4fmqMpJdspCtFDr0PQ+wdYmNQDsqPm84zs3S/FZUbqVNTY6WYQ6TppDGIO4H1zK37kh+q8ZVfA4Y5OMXChcOs0tImHRd5Q1/LfYdvU+GmpKiUdMi0l1zN0/t7B/Z9nkWDVFVbK623K0XVrbdLbOk8FRGxV1I8gsD4IOD5HJ4Pgs8zLNTLamX0hSVCxB0MNSVFBxCHXvV+J5d4tP6Wpq6maiulsSoWuVCPgyuxi7JYyPuI2yDjB9sdJPD3DIoMzMqbVdtzDh6gDFcHzGe47Y0zT/xCEZZi9/T6wqNDbyxaH3SsdxSZaWikc0FUVHCwy4Ut5HCt2OfZOjldp32jTnGR94fMO8Z+ouPGAE5IifllMKVhJ0Otj/lx4x//2Q==\"},\"Attributes\":[\"ALL\"]}",
      "operation": "detectFaces"
    };
    http.post(
        "https://ap-south-1.console.aws.amazon.com/rekognition/api/rekognition",
        body: json.encode(requestData),
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-TOKEN":
              "%5B%7B%22token%22%3A%22526461a47dc400f14817e3a90d54b357d8c2506b8f1b03eb915673c5179f23bd%22%2C%22version%22%3A%22hash-v2%22%7D%5D",
        }).then((data) async {
      print(data.body);
      if (data.statusCode == 200) {
        Map<String, dynamic> result = await json.decode(data.body);
        print(result);
      }

      setState(() {
        recognizeImg =
            "https://dhei5unw3vrsx.cloudfront.net/images/drive_thumb.jpg";
        isLoading = false;
        isResult = true;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Recognize App"),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              final d = await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext) => Camera()));
              if (d["event"] == "proceedImage") {
                recognizeDetails();
                final File file = File(d["imgPath"].toString());
                setState(() {
                  recognizeImg2 = file;
                });
                print(d["imgPath"].toString());
              }
            },
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please wait! we are fetching details about Image",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            )
          : isResult
              ? SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.file(
                          recognizeImg2,
                          width: 300,
                          height: 300,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Image Description",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Column(
                          children: reconganizationResult
                              .map((index) => Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          index["name"].toString(),
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        Text(
                                          index["result"].toString(),
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        )
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Please Open Camera to Recognize Image Details.",
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            final d = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext) => Camera()));

                            if (d["event"] == "proceedImage") {
                              recognizeDetails();
                              final File file = File(d["imgPath"].toString());
                              setState(() {
                                recognizeImg2 = file;
                              });
                              print(d["imgPath"].toString());
                            }
                          },
                          child: Text("Open Camera!"),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
