import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_easy/service/ui_helper.dart';
import 'package:learn_easy/view/complete_profile.dart';

import '../models/user_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isHidden = true;
  bool isHidden1 = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cpasswordController.text.trim();
    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(
          context, "Incomplite Data", "Please fill all the fields");
    } else if (password != cPassword) {
      print('passwords do not match');
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The password you entered  do not match!");
    } else {
      signUp(email, password);
      print('signUp Successful');
    }
  }

  void signUp(String email, String password) async {
    UserCredential? userCredential;
    UIHelper.showLoadingDialog(context, "Creating new account...");
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
      print(ex.code.toString());
    }
    if (userCredential != null) {
      String uid = userCredential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullName: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then(
        (value) {
          print('New user Created');
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompleteProfile(
                    userModel: newUser, firebaseUser: userCredential!.user!),
              ));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                height: 170,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/image/loginImage1.png"))),
              ),
              Text(
                "Learn Easy",
                style: GoogleFonts.adamina(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
              const SizedBox(
                height: 48,
              ),
              Container(
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.grey,
                      )
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                height: size.height * 0.074,
                width: size.width * 0.89,
                child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    )),
              ),
              const SizedBox(
                height: 19,
              ),
              Container(
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.grey,
                      )
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                height: size.height * 0.074,
                width: size.width * 0.89,
                child: TextFormField(
                    obscureText: isHidden,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      suffixIcon: InkWell(
                          onTap: togglePasswordView,
                          child: Icon(
                            isHidden ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          )),
                    )),
              ),
              const SizedBox(
                height: 19,
              ),
              Container(
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.grey,
                      )
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                height: size.height * 0.074,
                width: size.width * 0.89,
                child: TextFormField(
                    obscureText: isHidden1,
                    controller: cpasswordController,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      suffixIcon: InkWell(
                          onTap: togglePasswordView1,
                          child: Icon(
                            isHidden1 ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          )),
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      checkValue();
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.adamina(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
              ),
            ],
          )),
        ),
      )),
      bottomNavigationBar:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Already have an account?",
            style: GoogleFonts.adamina(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800])),
        CupertinoButton(
          child: Text(
            'Log In',
            style: GoogleFonts.adamina(
                fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ]),
    );
  }

  void togglePasswordView() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  void togglePasswordView1() {
    setState(() {
      isHidden1 = !isHidden1;
    });
  }
}
