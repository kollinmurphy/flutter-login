import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prefs.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text('Do you really want to exit?'),
          actions: [
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
      child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text("Members Area"),
              leading: new Container(),
              actions: [
                PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return {'Logout'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ]),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("You're logged in."),
          )),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        sharedPrefs.setString("token", "");
        sharedPrefs.setString("username", "");
        Navigator.pop(context);
        break;
      case 'Settings':
        break;
    }
  }
}
