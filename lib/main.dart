import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_easy/models/user_model.dart';
import 'package:learn_easy/provider/provider.dart';
import 'package:learn_easy/service/firebase_service.dart';
import 'package:learn_easy/view/home_page.dart';
import 'package:learn_easy/view/login_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    //logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelId(currentUser.uid);
    if (thisUserModel != null) {
      runApp(MyAppLoggedIn(
        firebaseUser: currentUser,
        userModel: thisUserModel,
      ));
    } else {
      runApp(const MyApp());
    }
  } else {
    //not logged In
    runApp(const MyApp());
  }
}

//not logged In
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProviderData>(
      create: (context) => ProviderData(),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}

//Already loggedIn
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProviderData>(
      create: (context) => ProviderData(),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
      ),
    );
  }
}
