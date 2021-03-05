import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'prefs.dart';

class SignUpPage extends StatefulWidget {
  bool hasResponse = false;
  bool creationValidated = false;
  bool usernameTaken = false;

  bool hidePassword = true;

  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final pwConfirmController = TextEditingController();
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
    final _formKey = GlobalKey<FormState>();
    widget._scaffoldKey = GlobalKey<ScaffoldState>();

    Widget validMessage = new Container();
    if (widget.hasResponse && !widget.creationValidated) {
      if (widget.usernameTaken) {
        widget.usernameTaken = false;
        validMessage = Text(
          "Username already taken.",
          style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(200, 0, 0, 1)),
        );
      } else {
        validMessage = Text(
          "Invalid login.",
          style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(200, 0, 0, 1)),
        );
      }
      widget.hasResponse = false;
    }
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create Account"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                                  r"^(?:[a-z0-9!#$%&'*/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*/=?^_`{|}~-]+)*|\" +
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
                              } else {
                                // to be included on register form

                                // RegExp exp = new RegExp(r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{6,}$");
                                // if (!exp.hasMatch(value)) {
                                //   return 'Passwords should contain one uppercase letter,\none lowercase letter, one number,\nand one special character.';
                                // }
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
                                        color: Colors.grey
                                    ))),
                          )
                        ]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Confirm password',
                          ),
                          obscureText: widget.hidePassword,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please reenter password.';
                            } else if (value != pwController.text) {
                              return 'Passwords don\'t match.';
                            }
                            return null;
                          },
                          controller: pwConfirmController,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            widget._scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Loading...')));
                            createAccount(emailController.text, pwController.text);
                            focusNode.requestFocus();
                          }
                        },
                        child: Text('Sign Up'),
                      ))
                ])),
          ),
          validMessage
        ],
      ),
    );
  }

  Future createAccount(String username, String password) async {
    var url = 'https://www.unmanneddroneservices.com/testing/createUser.php?username=$username&password=$password';
    http.Response response = await http.get(url);
    widget._scaffoldKey.currentState.hideCurrentSnackBar();
    if (response.body.contains("create_success")) {
      sharedPrefs.setBool("created_account", true);
      emailController.text = "";
      pwController.text = "";
      pwConfirmController.text = "";
      Navigator.pop(context);
    } else {
      if (response.body.contains("username_taken")) {
        widget.usernameTaken = true;
      }
      setState(() {
        widget.hasResponse = true;
        widget.creationValidated = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

}