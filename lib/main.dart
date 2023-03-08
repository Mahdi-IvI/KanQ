import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kan_q/config/style.dart';
import 'package:kan_q/config/themeProvider.dart';
import 'package:kan_q/mySplashPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/authService.dart';
import 'config/config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  KanQ.auth = FirebaseAuth.instance;
  KanQ.fireStore = FirebaseFirestore.instance;
  KanQ.sharedPreferences = await SharedPreferences.getInstance();
  KanQ.myProjects = [];

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
   const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeProvider themeProvider=ThemeProvider();

  void getCurrentAppTheme() async {
    themeProvider.darkTheme = await themeProvider.darkThemePreference.getTheme();

  }
  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_){
            return themeProvider;
          }),
          StreamProvider<User?>.value(
            value: AuthService().user,
            initialData: KanQ.auth.currentUser,
          ),

        ],
        child: Consumer<ThemeProvider>(
          builder: ( context, themeProvider,  child) {
            return MaterialApp(
              title: 'KanQ',
              theme: Styles.themeData(themeProvider.darkTheme, context),
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
              home:  const MySplashPage(),
            );
          }
        )

    );
  }
}


