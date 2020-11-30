import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class LocationDialog extends StatefulWidget {
  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog>
    with SingleTickerProviderStateMixin {
  PermissionStatus _status;

  @override
  void initState() {
    runFirst();
    super.initState();
  }

  runFirst() async {
//await PermissionHandler()
//        .checkPermissionStatus(PermissionGroup.locationWhenInUse)
//        .then(_updateStatus);

    /* PermissionHandle() deprecated in permission_handler: ^5.0.0+hotfix.3 */

    await Permission.locationWhenInUse.status.then(_updateStatus);

    await _requestPerms();
    if (_status == PermissionStatus.granted) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NextPage()));
    } else if (_status == PermissionStatus.denied) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.red : Colors.green,
          ),
        );
      },
    );
  }
  void _updateStatus(PermissionStatus value) {
    setState(() {
      _status = value;
    });
  }
  void _requestPerms() async {
    Map<Permission, PermissionStatus> statuses = await
    [
      Permission.locationWhenInUse,
      Permission.locationAlways
    ].request();


    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      _updateStatus(PermissionStatus.denied);
      openAppSettings();
    }

    //  switch (status) {
    //    case PermissionStatus.disabled:
    //      await PermissionHandler().
    //      break;
    //  }
    //  _updateStatus(status);
    //  }


  }
}

  class NextPage extends StatefulWidget {
  @override
  _NextPageState createState() => _NextPageState();
  }

  class _NextPageState extends State<NextPage> {
    PermissionStatus _status;

    @override
    Widget build(BuildContext context) {
      debugPrint('Location Status $_status');
      return Scaffold(
        body: SafeArea(
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/perm_icon_location.png'),
                Text(
                  "LocationDialogHelper",
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "locationDialogBody",
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.0),
                      child: RaisedButton(
                        color: Colors.black,
                        onPressed: _requestPerms,
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Text(
                          "allow",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      );
    }

    void _requestPerms() async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.locationWhenInUse,
        Permission.locationAlways,
      ].request();

      final status = Permission.locationWhenInUse.serviceStatus;
   //   _updateStatus(status);
print(status);
// switch (status) {
      //     case PermissionStatus.disabled:
      //       await PermissionHandler().openAppSettings();
      //       break;
//    }
//    _updateStatus(status);
//  }

      void _updateStatus(PermissionStatus value) {
        setState(() {
          _status = value;
        });
      }
    }
  }