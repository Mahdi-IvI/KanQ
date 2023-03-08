import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:kan_q/createOrJoinProject.dart';
import 'package:kan_q/config/config.dart';
import 'package:kan_q/myHomePage.dart';
import 'package:kan_q/widget/loading.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  bool _loading = false;

  void _onIntroEnd(context) {
    setState(() {
      _loading = true;
    });
    signInWithGoogle();
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await KanQ.auth.signInWithCredential(credential).then((value) async {
      User? user = KanQ.auth.currentUser;
      if (user != null) {
        await KanQ.fireStore
            .collection(KanQ.userCollection)
            .doc(user.uid)
            .get()
            .then((DocumentSnapshot snapshot) async {
          if (snapshot.exists) {
            await KanQ.fireStore
                .collection(KanQ.userCollection)
                .doc(user.uid)
                .update({
              KanQ.userUID: user.uid,
              KanQ.userEmail: user.email,
              KanQ.userName: user.displayName,
              KanQ.userImageUrl: user.photoURL
            }).whenComplete(() async {
              await KanQ.getProjects();
            }).whenComplete(() {
              if (KanQ.myProjects.isEmpty) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const CreateOrJoinProject()),
                    (route) => false);
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MyHomePage()),
                    (route) => false);
              }
            });
          } else {
            await KanQ.fireStore
                .collection(KanQ.userCollection)
                .doc(user.uid)
                .set({
              KanQ.userUID: user.uid,
              KanQ.userEmail: user.email,
              KanQ.userName: user.displayName,
              KanQ.userImageUrl: user.photoURL,
            }).then((value) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const CreateOrJoinProject()),
                  (route) => false);
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'Please try again',
          textDirection: TextDirection.rtl,
        )));
      }
    });
    setState(() {
      _loading = false;
    });
  }

  Widget _buildImage(String assetName, [double width = 200]) {
    return Image.asset(
      'assets/introImage/$assetName',
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    PageDecoration pageDecoration = PageDecoration(
      titleTextStyle:
          const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyPadding: const EdgeInsets.symmetric(vertical: 20),
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      imagePadding: const EdgeInsets.only(top: 80),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 4000,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('KanQIcon.png', 100),
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: _loading
              ? const WhiteLoading()
              : const Text(
                  'Sign In With Google',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Welcome",
          body:
              "Welcome to KanQ app - an all-in-one solution for managing tasks and projects.",
          image: _buildImage('User flow-pana.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "How to Use",
          body: "1. Create tasks, move them between columns \n\n"
              "2. Use timer to track time spent on tasks \n\n"
              "3. Export everything to CSV file",
          image: _buildImage('Prototyping process-bro.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Benefits of Using Our Kanban Board App",
          body: "1. Increased productivity and organization\n\n"
              "2. Improved time management\n\n"
              "3. Accurate time tracking and reporting",
          image: _buildImage('Messaging-amico.png'),
          decoration: pageDecoration,
        ),
      ],
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      showDoneButton: false,
      showNextButton: true,
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
