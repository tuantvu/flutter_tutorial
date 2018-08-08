import 'package:flutter/material.dart';
import 'dart:io';

class GetIPScreen extends StatefulWidget {
  @override
  _GetIPScreenState createState() {
    return new _GetIPScreenState();
  }
}

class _GetIPScreenState extends State<GetIPScreen> {
  String _ipAddress;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: new Text("IP Address: $_ipAddress"),
            ),
            new RaisedButton(
                child: new Text("Get IP"),
                onPressed: () async {
                  debugPrint("pressed button");
                  if (NetworkInterface.listSupported) {
                    List<NetworkInterface> networkInterfaces = await NetworkInterface.list(
                      type: InternetAddressType.IP_V4
                    );
                    networkInterfaces.forEach((i) => debugPrint("name: ${i.name}, address: ${i.addresses}"));
                    setState(() {
                      _ipAddress = networkInterfaces[0].addresses.first.address;
                    });
                  } else {
                    setState(() {
                      _ipAddress = "Not Supported";
                    });
                  }
                })
          ],
        ),
      ),
    );
  }
}