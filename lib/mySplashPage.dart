import 'package:flutter/material.dart';
import 'package:kan_q/createOrJoinProject.dart';
import 'package:kan_q/config/config.dart';
import 'package:kan_q/introduction.dart';
import 'package:kan_q/myHomePage.dart';
import 'package:kan_q/widget/loading.dart';

class MySplashPage extends StatefulWidget {
  const MySplashPage({Key? key}) : super(key: key);

  @override
  State<MySplashPage> createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage> {
  @override
  void initState() {
    super.initState();
    if (KanQ.auth.currentUser == null) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const IntroductionPage()),
                (route) => false);
      });

    } else {
      setData();
    }
  }

  setData() async {
    await KanQ.getProjects().whenComplete(() {
      if (KanQ.myProjects.isEmpty) {

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CreateOrJoinProject()), (route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MyHomePage()), (route) => false);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/introImage/KanQIcon.png"),
            const SizedBox(height: 10),
            const Loading()
          ],
        ),
      ),
    );
  }
}
