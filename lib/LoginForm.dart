import 'package:flutter/material.dart';
import 'MainPage.dart';
import 'SignUpPage.dart';
import 'package:http/http.dart' as http;
import 'prefs.dart';

class LoginForm extends StatefulWidget {
  bool hasResponse = false;
  bool loginValidated = false;
  bool createdAccount = false;

  bool hidePassword = true;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  FocusNode focusNode;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    pwController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget validMessage = new Container();
    if (widget.hasResponse && !widget.loginValidated) {
      validMessage = Text(
        "Invalid login.",
        style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(200, 0, 0, 1)),
      );
      widget.hasResponse = false;
    }
    if (widget.createdAccount) {
      widget.createdAccount = false;
      sharedPrefs.setBool("created_account", false);
      validMessage = Text("Account created.",
          style:
              TextStyle(fontSize: 20.0, color: Color.fromRGBO(0, 200, 0, 1)));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Form(
              key: _formKey,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an email.';
                          } else {
                            RegExp exp = new RegExp(
                                r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\" +
                                    '"' +
                                    r"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*\" +
                                    '"' +
                                    r")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])");
                            if (!exp.hasMatch(value)) {
                              return 'Invalid email.';
                            }
                          }
                          return null;
                        },
                        controller: emailController,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Stack(children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Password',
                          ),
                          obscureText: widget.hidePassword,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a password.';
                            } else if (value.length < 6) {
                              return 'Passwords should be at least 6 characters in length.';
                            }
                            return null;
                          },
                          controller: pwController,
                        ),
                        Positioned(
                          right: 10.0,
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.hidePassword = !widget.hidePassword;
                                });
                              },
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Icon(
                                      IconData(
                                          (widget.hidePassword) ? 58617 : 58616,
                                          fontFamily: 'MaterialIcons'),
                                      color: Colors.grey))),
                        )
                      ]),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a Snackbar.
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Loading...')));
                          validateLogin(
                              emailController.text, pwController.text);
                          focusNode.requestFocus();
                        }
                      },
                      child: Text('Log In'),
                    ))
              ])),
        ),
        validMessage,
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
                onPressed: () {
                  Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUpPage()))
                      .then((value) {
                        bool created = sharedPrefs.getBool("created_account", false);
                    if (created) {
                      setState(() {
                        widget.createdAccount = true;
                      });
                    }
                  });
                },
                child: Text('Sign Up'),
                color: Colors.grey[300]))
      ],
    );
  }

  Future validateLogin(String username, String password) async {
    var url = 'https://www.unmanneddroneservices.com/testing/login.php?username=$username&password=$password';
    http.Response response = await http.get(url);
    Scaffold.of(context).hideCurrentSnackBar();
    pwController.text = "";
    if (response.body.contains("token")) {
      sharedPrefs.setString("username", emailController.text);
      sharedPrefs.setString("token", response.body.substring(5));
      emailController.text = "";
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainPage()))
          .then((value) {
            setState(() {

            });
      });
    } else {
      setState(() {
        widget.hasResponse = true;
        widget.loginValidated = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }
}
