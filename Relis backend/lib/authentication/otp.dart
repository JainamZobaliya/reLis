import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:relis/authentication/signIn.dart';
import 'package:relis/authentication/signUp.dart';
import 'package:relis/globals.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({Key? key}) : super(key: key);
  static const routeName = '/OTPPage';

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _formKey = GlobalKey<FormState>();
  var otpList = ["","","","","",""];
  List<FocusNode> focusNode = List<FocusNode>.generate(6, (int index) => FocusNode());
  String otpString = "";
  String realOTP = "";
  bool _otpVisible = false;
  bool invalidOTP = false;
  FocusNode verifyOTPnode = FocusNode();
  List<TextEditingController> otpText = List<TextEditingController>.generate(6, (int index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    focusNode[0] = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text(appTitle),
        backgroundColor: appBarBackgroundColor,
        shadowColor: appBarShadowColor,
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.all(100),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF1A93EF).withOpacity(0.5),
                shape: BoxShape.rectangle,
                // border: Border.all(width: 2),
                borderRadius: BorderRadius.all(
                  const Radius.circular(8),
                ),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Color(0xFF2C3E50).withOpacity(0.9),
                    blurRadius: 3.0,
                    spreadRadius: 1.0,
                    // offset: new Offset(5.0, 5.0),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height*0.6,
              width: MediaQuery.of(context).size.width*0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.00),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: invalidOTP ? "" : 'Enter OTP',
                              style: TextStyle(
                                color: Colors.black,
                                height: 2,
                                fontSize: 20,
                              ),
                              children: <TextSpan>[
                                if(invalidOTP) TextSpan(
                                  text: "  You have entered invalid OTP!!!",
                                  style: TextStyle(
                                    color: Colors.red,
                                    height: 2,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                if(invalidOTP) TextSpan(
                                  text: " Please Enter valid OTP!",
                                  style: TextStyle(
                                    color: Colors.black,
                                    height: 2,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              for(int i=0; i<6; ++i)
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: 33,
                                        height: 50,
                                        child: TextFormField(
                                          onChanged: (text) {
                                            otpList[i] = text;
                                            if(i<5)
                                              FocusScope.of(context).requestFocus(focusNode[i+1]);
                                            if(i==5)
                                              FocusScope.of(context).requestFocus(verifyOTPnode);
                                          },
                                          controller: otpText[i],
                                          textInputAction: TextInputAction.done,
                                          autofocus: true,
                                          obscureText: !_otpVisible,
                                          focusNode: focusNode[i],
                                          maxLines: 1,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.white,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          maxLength: 1,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(10.5),
                                            hintText: '',
                                            hintStyle: TextStyle(
                                              color: Colors.white,
                                            ),
                                            labelText: '',
                                            counterText: "",
                                            labelStyle: TextStyle(
                                              color: Colors.white,
                                              height: 1,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.circular(
                                                  18.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.circular(
                                                  18.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                    ],
                                ),
                              IconButton(
                                tooltip: _otpVisible ? "Hide Password" : " Show Password",
                                color: Colors.white,
                                icon: Icon(
                                  _otpVisible ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _otpVisible = !_otpVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: resendOTPButton(),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: verifyButton(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20,),
                  Expanded(
                    child: otpImage(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget resendOTPButton() {
    return MaterialButton(
      elevation: 0.0,
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(15.0),
      ),
      focusElevation: 0.0,
      hoverElevation: 0.0,
      highlightElevation: 0.0,
      hoverColor: Colors.transparent,
      autofocus: false,
      textColor: Colors.white,
      color: Colors.transparent,
      splashColor: Color(0xFF1E8BC3),
      child: Text(
        "Resend OTP",
        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () async {
        Navigator.of(context).popAndPushNamed(SignUpPage.routeName);
        // Center(
        //   child: CircularProgressIndicator(),
        // );
        // if (_key.currentState.validate()) {
        //   _signInWithEmailAndPassword();
        // } else {
        //   showMessageSnackBar("Please fill the valid Details!!");
        // }
      },
    );
  }

  Widget verifyButton() {
    return MaterialButton(
      elevation: 0.0,
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(15.0),
      ),
      focusElevation: 0.0,
      hoverElevation: 0.0,
      highlightElevation: 0.0,
      hoverColor: Colors.transparent,
      autofocus: false,
      focusNode: verifyOTPnode,
      textColor: Color(0xFF1E8BC3),
      color: Colors.white,
      splashColor: Color(0xFF2C3E50).withOpacity(0.3),
      child: Text(
        "Verify",
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () async {
        verifyOTP(context, otpList);
      },
    );
  }

  verifyOTP(BuildContext context, var list){
    print("\n\n In Func!!! \n\n");
    otpString = "";
    for(int i=0; i<list.length; ++i)
    {
      otpString = otpString + list[i];
    }
    if(otpString == realOTP) {
      invalidOTP = false;
      while(Navigator.of(context).canPop())
        Navigator.of(context).pop();
      Navigator.of(context).popAndPushNamed(SignInPage.routeName);
    }
    else
    {
      invalidOTP = true;
      otpList = ["","","","","",""];
      for(int i=0; i<list.length; ++i)
      {
        otpText[i].clear();
      }
    }
    setState(() {});
  }

  Widget otpImage() {
    return Image.asset(
      "images/signin.png",
      fit: BoxFit.contain,);
  }

}


