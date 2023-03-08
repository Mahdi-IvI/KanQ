import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kan_q/config/config.dart';
import 'package:kan_q/models/board.dart';
import 'package:kan_q/myHomePage.dart';
import 'package:kan_q/models/sampleProjectBoards.dart';
import 'package:kan_q/widget/loading.dart';

class CreateOrJoinProject extends StatefulWidget {
  const CreateOrJoinProject({Key? key}) : super(key: key);

  @override
  State<CreateOrJoinProject> createState() => _CreateOrJoinProjectState();
}

class _CreateOrJoinProjectState extends State<CreateOrJoinProject> {
  final TextEditingController _createController = TextEditingController();
  final TextEditingController _joinController = TextEditingController();
  final _joinFormKey = GlobalKey<FormState>();
  final _createFormKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to KanQ"),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.add_circle_outline_sharp),
                text: "Create a Project",
              ),
              Tab(
                icon: Icon(Icons.dashboard),
                text: "Join to a Project",
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [createProject(), joinProject()],
        ),
      ),
    );
  }

  Widget createProject() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Form(
              key: _createFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Create a New Project:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(
                    height: kToolbarHeight,
                  ),
                  TextFormField(
                    controller: _createController,
                    validator: (text) {
                      if (text != null && text.trim().isNotEmpty) {
                        return null;
                      } else {
                        return "Please Enter the Project's Name.";
                      }
                    },
                    decoration: const InputDecoration(
                        label: Text("Enter Project Name:")),
                  )
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              if (_createFormKey.currentState!.validate()) {
                createAndSaveProject();
              }
            },
            child: SizedBox(
                width: double.infinity - 10,
                height: kToolbarHeight,
                child: Center(
                    child: loading
                        ? const WhiteLoading()
                        : const Text(
                            "Create the Project",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ))))
      ],
    );
  }

  Widget joinProject() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Form(
              key: _joinFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Join to Project:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(
                    height: kToolbarHeight,
                  ),
                  TextFormField(
                    controller: _joinController,
                    validator: (text) {
                      if (text != null && text.trim().isNotEmpty) {
                        return null;
                      } else {
                        return "Please Enter the Project'sJoin Code.";
                      }
                    },
                    decoration: const InputDecoration(
                        label: Text("Enter Project Code:")),
                  )
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              if (_joinFormKey.currentState!.validate()) {
                join();
              }
            },
            child: SizedBox(
                width: double.infinity - 10,
                height: kToolbarHeight,
                child: Center(
                    child: loading
                        ? const WhiteLoading()
                        : const Text(
                            "Join to the Project",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ))))
      ],
    );
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> createAndSaveProject() async {
    setState(() {
      loading = true;
    });
    String projectId =
        "${KanQ.auth.currentUser!.uid}-${DateTime.now().microsecondsSinceEpoch}";
    KanQ.fireStore.collection(KanQ.projectsCollection).doc(projectId).set({
      KanQ.projectId: projectId,
      KanQ.projectName: _createController.text.trim(),
      KanQ.projectOwner: KanQ.auth.currentUser!.uid,
      KanQ.projectMembers: [KanQ.auth.currentUser!.uid],
      KanQ.projectJoinCode: getRandomString(7),
      KanQ.projectCreatedDate: DateTime.now(),
    }).then((value) {
      List<Board> sampleBoards = SampleProjectBoards().createSampleBoard();
      for (int i = 0; i < sampleBoards.length; i++) {
        KanQ.fireStore
            .collection(KanQ.projectsCollection)
            .doc(projectId)
            .collection(KanQ.boardCollection)
            .doc(sampleBoards[i].boardId)
            .set(sampleBoards[i].toJson());
      }
    }).then((value) {
      late List userProjects;
      KanQ.fireStore
          .collection(KanQ.userCollection)
          .doc(KanQ.auth.currentUser!.uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data[KanQ.userProjects] == null ||
            data[KanQ.userProjects].toString() == "[]") {
          userProjects = [];
        } else {
          userProjects = data[KanQ.userProjects];
        }

        userProjects.add(projectId);
      }).then((value) {
        KanQ.fireStore
            .collection(KanQ.userCollection)
            .doc(KanQ.auth.currentUser!.uid)
            .update({KanQ.userProjects: userProjects});
      });
    }).then((value) async {
      await KanQ.getProjects().whenComplete(() async {
        await KanQ.sharedPreferences
            .setInt(KanQ.lastProjectIndex, KanQ.myProjects.length - 1);
        setState(() {
          loading = false;
        });
        navigateTo(const MyHomePage());
      });
    });
  }

  navigateTo(page) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page), (route) => false);
  }

  Future<void> join() async {
    String projectId = "";
    List projectMembers=[];
    setState(() {
      loading = true;
    });

    await KanQ.fireStore
        .collection(KanQ.projectsCollection)
        .where(KanQ.projectJoinCode, isEqualTo: _joinController.text.trim())
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        projectId = doc[KanQ.projectId];
        projectMembers = doc[KanQ.projectMembers];
      });
      print("//////////////////////////////");
      print(projectId);
    }).whenComplete(() {
      late bool alreadyJoined;
      List<String> userProjects = [];
      for (int i = 0; i < KanQ.myProjects.length; i++) {
        userProjects.add(KanQ.myProjects[i].projectId);
      }

      if (projectId != "") {
        if (userProjects.contains(projectId)) {
          alreadyJoined = true;
        } else {
          alreadyJoined = false;
          userProjects.add(projectId);
        }

        if (alreadyJoined) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Already joined to this Project")));
          setState(() {
            loading = false;
          });
        } else {
          String? userUID = KanQ.auth.currentUser?.uid;
          if (userUID != null) {
            projectMembers.add(userUID);
          }

          KanQ.fireStore
              .collection(KanQ.projectsCollection)
              .doc(projectId)
              .update({KanQ.projectMembers: projectMembers}).whenComplete(() {
            KanQ.fireStore
                .collection(KanQ.userCollection)
                .doc(KanQ.auth.currentUser!.uid)
                .update({KanQ.userProjects: userProjects}).whenComplete(
                    () async {
              await KanQ.getProjects().whenComplete(() async {
                int index = KanQ.myProjects.length - 1;
                for (int i = 0; i < KanQ.myProjects.length; i++) {
                  if (projectId == KanQ.myProjects[i].projectId) {
                    index = i;
                  }
                }
                await KanQ.sharedPreferences
                    .setInt(KanQ.lastProjectIndex, index);
                setState(() {
                  loading = false;
                });
                navigateTo(const MyHomePage());
              });
            });
          });
        }
      } else {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Project doesn't exist.")));
      }
    });
  }
}
