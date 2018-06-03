import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Forms Tutorial"),
          ),
          body: Column(
            children: <Widget>[
              Expanded(child: Container()),
              EmailPasswordForm(
                handleSubmit: (form) {
                  _scaffoldKey.currentState.showSnackBar(
                      SnackBar(content: Text("${form.email}, ${form.password}")));
                }
              ),
              Expanded(child: Container()),
            ],
          )
      ),
    );
  }
}

typedef void FormCallback(FormVO form);

class FormVO {
  FormVO(this.email, this.password);
  final String email;
  final String password;
}

class EmailPasswordForm extends StatelessWidget{

  EmailPasswordForm({this.handleSubmit});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _emailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordKey = GlobalKey<FormFieldState>();
  final FormCallback handleSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              key: _emailKey,
              decoration: InputDecoration(labelText: "Email"),
              autovalidate: true,
              autofocus: true,
              validator: (value){
                if (value.isEmpty) {
                  return "Invalid email";
                }
              },
            ),
            TextFormField(
              key: _passwordKey,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: (value){
                if (value.length < 6) {
                  return "Password must be longer than 6 characters";
                }
              },
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    handleSubmit(FormVO(
                      _emailKey.currentState.value,
                      _passwordKey.currentState.value
                    ));
                  }
                },
                child: Text("Submit"),
              ),
            )
          ],),
      ),
    );
  }


}