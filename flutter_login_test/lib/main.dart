import 'package:flutter/material.dart';
import 'LoginForm.dart';
import 'package:http/http.dart' as http;
import 'MainPage.dart';
import 'prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  runApp(MaterialApp(
    title: 'Login Test',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
    ),
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  String token = sharedPrefs.getString("token", "");
  String username = sharedPrefs.getString("username", "");
  bool tokenValidated = false;
  bool loaded = false;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    if (!widget.loaded) { //
      return Scaffold(
          body: Center(child: Text("Logging you in...", style: TextStyle(
              fontSize: 20.0
          )))
      );
    } else if (!widget.tokenValidated) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Log In")
        ),
        body: LoginForm()
      );
    } else {
      return Scaffold(
          body: Center(child: Text("Logging you in...", style: TextStyle(
            fontSize: 20.0
          )))
      );
    }
  }

  Future validateToken(String token, String username) async {
    var url = 'https://www.unmanneddroneservices.com/testing/validateToken.php?token=$token&username=$username';
    http.Response response = await http.get(url);
    // var data = jsonDecode(response.body);
    // print(data.toString());
    if (response.body == "token_valid") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage())).then(
          (value) {
            setState(() {
              widget.loaded = true;
              widget.tokenValidated = false;
            });
          }
      );
    } else {
      setState(() {
        widget.loaded = true;
        widget.tokenValidated = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.token != "" && widget.username != "") {
      validateToken(widget.token, widget.username);
    } else {
      setState(() {
        widget.loaded = true;
      });
    }

  }
}
