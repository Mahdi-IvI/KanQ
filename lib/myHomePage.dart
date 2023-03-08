import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:csv/csv.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:kan_q/completedTasks.dart';
import 'package:kan_q/createAndEditTask.dart';
import 'package:kan_q/createOrJoinProject.dart';
import 'package:kan_q/introduction.dart';
import 'package:kan_q/models/task.dart';
import 'package:kan_q/widget/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'config/config.dart';
import 'config/themeProvider.dart';
import 'models/board.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedProjectIndex = 0;
  List<Board> _pBoards = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      if (KanQ.sharedPreferences.getInt(KanQ.lastProjectIndex) == null ||
          KanQ.sharedPreferences.getInt(KanQ.lastProjectIndex) == -1) {
        selectedProjectIndex = KanQ.myProjects.length - 1;
      } else {
        selectedProjectIndex =
            KanQ.sharedPreferences.getInt(KanQ.lastProjectIndex)!;
      }
      if (KanQ.myProjects.length > selectedProjectIndex) {
        _pBoards = KanQ.myProjects[selectedProjectIndex].projectBoards;
      } else {
        selectedProjectIndex=KanQ.myProjects.length - 1;
        _pBoards = KanQ.myProjects[KanQ.myProjects.length - 1].projectBoards;
      }
    });
  }

  late Size size;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String userName = KanQ.auth.currentUser?.displayName ?? "User";
    String userEmail = KanQ.auth.currentUser?.email ?? "Use Emailr";
    String userPhoto =
        KanQ.auth.currentUser?.photoURL ?? "https://picsum.photos/200/400";
    size = MediaQuery.of(context).size;
    final themeChange = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(userPhoto),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: KanQ.myProjects.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: Text(KanQ.myProjects[index].projectName),
                  onTap: () async {
                    await KanQ.sharedPreferences
                        .setInt(KanQ.lastProjectIndex, index)
                        .whenComplete(() {
                      setState(() {
                        selectedProjectIndex = index;
                        _pBoards = KanQ.myProjects[index].projectBoards;
                      });

                      Navigator.pop(context);
                    });
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create / Join a Project'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CreateOrJoinProject()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () {
                KanQ.auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const IntroductionPage()),
                    (route) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              onPressed: () {
                themeChange.darkTheme = !themeChange.darkTheme;
              },
              icon: themeChange.darkTheme
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.mode_night)),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Project Join Code') {
                showProjectJoinCode(context);
              }
              if (result == 'Completed Tasks') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CompletedTasks(
                            project: KanQ.myProjects[selectedProjectIndex])));
              }
              if (result == 'Export Data') {
                _exportToCSV();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Project Join Code',
                child: ListTile(
                  title: Text('Project Join Code'),
                  trailing: Icon(Icons.fit_screen_outlined),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Completed Tasks',
                child: ListTile(
                  title: Text('Completed Tasks'),
                  trailing: Icon(Icons.done_outline),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Export Data',
                child: ListTile(
                  title: Text('Export to CSV'),
                  trailing: Icon(Icons.import_export),
                ),
              ),
            ],
          ),
        ],
        title: Text(KanQ.myProjects.isNotEmpty
            ? KanQ.myProjects[selectedProjectIndex].projectName
            : 'ProjectName'),
      ),
      body: DragAndDropLists(
        children: List.generate(_pBoards.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        axis: Axis.horizontal,
        listWidth: size.width * 80 / 100,
        listDraggingWidth: size.width * 80 / 100,
        listPadding: const EdgeInsets.all(8.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddBoardsDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  _buildList(int outerIndex) {
    return _pBoards == []
        ? Loading
        : DragAndDropList(
            header: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(7.0)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _pBoards[outerIndex].boardName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateAndEditTask(
                                          fromNewBoard: _pBoards[outerIndex]
                                              .boardTasks
                                              .isEmpty,
                                          board: _pBoards[outerIndex],
                                          project: KanQ
                                              .myProjects[selectedProjectIndex],
                                          edit: false,
                                        )));
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            footer: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAndEditTask(
                                    fromNewBoard:
                                        _pBoards[outerIndex].boardTasks.isEmpty,
                                    board: _pBoards[outerIndex],
                                    project:
                                        KanQ.myProjects[selectedProjectIndex],
                                    edit: false,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromRGBO(0, 0, 0, 0.05),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Center(
                        child: Text(
                          'Add Task',
                          style: TextStyle(fontSize: 18, color: Colors.black45),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            children: List.generate(
                _pBoards[outerIndex].boardTasks.length,
                (index) => _buildItem(_pBoards[outerIndex],
                    _pBoards[outerIndex].boardTasks[index])),
          );
  }

  _buildItem(Board board, Task task) {
    return DragAndDropItem(
        child: InkWell(
      onTap: () {},
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 36, right: 36, top: 36),
                  width: size.width * 80 / 100,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.taskName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateAndEditTask(
                                            fromNewBoard: false,
                                            board: board,
                                            project: KanQ.myProjects[
                                                selectedProjectIndex],
                                            edit: true,
                                            task: task,
                                          )));
                            },
                            child: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            task.taskDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.alarm,
                                    color: Theme.of(context).primaryColor),
                                Expanded(
                                  child: StreamBuilder(
                                    stream: Stream.periodic(
                                            const Duration(seconds: 1))
                                        .asBroadcastStream(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      Duration elapsed = Duration(
                                              seconds:
                                                  int.parse(task.spentTime)) +
                                          task.timer.elapsed;
                                      String elapsedString =
                                          ' ${elapsed.inHours.toString().padLeft(2, '0')}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
                                      return Text(
                                        elapsedString,
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      task.completed
                          ? const SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                task.timer.elapsed.inSeconds > 0 ||
                                        task.timer.isActive
                                    ? AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        switchInCurve: Curves.easeInOut,
                                        switchOutCurve: Curves.easeInOut,
                                        child: task.timer.isActive
                                            ? IconButton(
                                                key: const ValueKey('pause'),
                                                icon: Icon(Icons.pause,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                onPressed: () {
                                                  stopTaskTimer(task);
                                                  setState(() {});
                                                },
                                              )
                                            : IconButton(
                                                key: const ValueKey('play'),
                                                icon: Icon(
                                                  Icons.play_arrow,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                onPressed: () {
                                                  startTaskTimer(task);
                                                  setState(() {});
                                                },
                                              ),
                                      )
                                    : TextButton(
                                        child: Text("Start Task",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 18)),
                                        onPressed: () {
                                          startTaskTimer(task);
                                          int oldBoardindex =
                                              _pBoards.indexOf(board);
                                          int oldListindex =
                                              _pBoards[oldBoardindex]
                                                  .boardTasks
                                                  .indexOf(task);
                                          late int newBoardindex;
                                          for (int i = 0;
                                              i < _pBoards.length;
                                              i++) {
                                            if (_pBoards[i].boardName ==
                                                "In Progress") {
                                              newBoardindex = i;
                                            }
                                          }
                                          if (newBoardindex != oldBoardindex) {
                                            _onItemReorder(
                                                oldListindex,
                                                oldBoardindex,
                                                _pBoards[newBoardindex]
                                                    .boardTasks
                                                    .length,
                                                newBoardindex);
                                          }
                                          setState(() {});
                                        },
                                      ),
                              ],
                            ),
                      task.timer.elapsed.inSeconds > 0 ||
                              task.timer.isActive ||
                              task.completed
                          ? TextButton(
                              child: Text(task.completed ? "completed" : "Done",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 18)),
                              onPressed: () {
                                if (!task.completed) {
                                  stopTaskTimer(task);
                                  int oldBoardindex = _pBoards.indexOf(board);
                                  int oldListindex = _pBoards[oldBoardindex]
                                      .boardTasks
                                      .indexOf(task);
                                  late int newBoardindex;
                                  for (int i = 0; i < _pBoards.length; i++) {
                                    if (_pBoards[i].boardName == "Done") {
                                      newBoardindex = i;
                                    }
                                  }
                                  print(_pBoards[newBoardindex]
                                      .boardTasks
                                      .length);
                                  if (newBoardindex != oldBoardindex) {
                                    print(
                                        "$oldBoardindex/$oldListindex/$newBoardindex/${_pBoards[newBoardindex].boardTasks.length}");
                                    _onItemReorder(
                                        oldListindex,
                                        oldBoardindex,
                                        _pBoards[newBoardindex]
                                            .boardTasks
                                            .length,
                                        newBoardindex);
                                  }
                                  setState(() {
                                    task.completed = true;
                                  });
                                  KanQ.fireStore
                                      .collection(KanQ.projectsCollection)
                                      .doc(KanQ.myProjects[selectedProjectIndex]
                                          .projectId)
                                      .collection(KanQ.taskCollection)
                                      .doc(task.taskId)
                                      .update({
                                    KanQ.completed: true,
                                    KanQ.taskEndDate: Timestamp.now()
                                  });
                                }
                              },
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
                Container(
                  width: size.width * 80 / 100,
                  height: 10,
                  color: task.taskImportanceGrade == 1
                      ? Colors.green
                      : task.taskImportanceGrade == 2
                          ? Colors.orange
                          : Colors.red,
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex,
      int newListIndex) async {
    setState(() {
      var movedItem = _pBoards[oldListIndex].boardTasks[oldItemIndex];
      _pBoards[oldListIndex].boardTasks.removeAt(oldItemIndex);
      _pBoards[newListIndex].boardTasks.insert(newItemIndex, movedItem);
    });
    await KanQ.fireStore
        .collection(KanQ.projectsCollection)
        .doc(KanQ.myProjects[selectedProjectIndex].projectId)
        .collection(KanQ.taskCollection)
        .doc(_pBoards[newListIndex].boardTasks[newItemIndex].taskId)
        .update({
      KanQ.boardId: KanQ
          .myProjects[selectedProjectIndex].projectBoards[newListIndex].boardId,
    });
    for (var i = 0; i < _pBoards[oldListIndex].boardTasks.length; i++) {
      await KanQ.fireStore
          .collection(KanQ.projectsCollection)
          .doc(KanQ.myProjects[selectedProjectIndex].projectId)
          .collection(KanQ.taskCollection)
          .doc(_pBoards[oldListIndex].boardTasks[i].taskId)
          .update({
        KanQ.taskIndex: i,
      });
    }
    for (var i = 0; i < _pBoards[newListIndex].boardTasks.length; i++) {
      await KanQ.fireStore
          .collection(KanQ.projectsCollection)
          .doc(KanQ.myProjects[selectedProjectIndex].projectId)
          .collection(KanQ.taskCollection)
          .doc(_pBoards[newListIndex].boardTasks[i].taskId)
          .update({
        KanQ.taskIndex: i,
      });
    }
  }

  _onListReorder(int oldListIndex, int newListIndex) async {
    setState(() {
      var movedList = _pBoards.removeAt(oldListIndex);
      _pBoards.insert(newListIndex, movedList);
    });
    for (var i = 0; i < _pBoards.length; i++) {
      await KanQ.fireStore
          .collection(KanQ.projectsCollection)
          .doc(KanQ.myProjects[selectedProjectIndex].projectId)
          .collection(KanQ.boardCollection)
          .doc(_pBoards[i].boardId)
          .update({
        KanQ.boardIndex: i,
      });
    }
  }

  Future showAddBoardsDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.close),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Create a new Board",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: controller,
                          validator: (text) {
                            if (text != null && text.trim().isNotEmpty) {
                              return null;
                            } else {
                              return "Please Enter the Board Name.";
                            }
                          },
                          decoration: const InputDecoration(
                              label: Text("Enter Board Name:"),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String boardId = DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString();
                              Board board = Board(
                                  boardId,
                                  KanQ.myProjects[selectedProjectIndex]
                                      .projectBoards.length,
                                  controller.text.trim(),
                                  [],
                                  Timestamp.now());
                              await KanQ.fireStore
                                  .collection(KanQ.projectsCollection)
                                  .doc(KanQ.myProjects[selectedProjectIndex]
                                      .projectId)
                                  .collection(KanQ.boardCollection)
                                  .doc(boardId)
                                  .set(board.toJson())
                                  .whenComplete(() {
                                setState(() {
                                  KanQ.myProjects[selectedProjectIndex]
                                      .projectBoards
                                      .add(board);
                                });

                                Navigator.of(context).pop();
                              });

                            }
                          },
                          child: const Text("Create new Board"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future showProjectJoinCode(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.close),
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 3.0,
                      ))),
                      child: Text(
                        KanQ.myProjects[selectedProjectIndex].projectJoinCode,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  void startTaskTimer(Task task, {Duration initialDuration = Duration.zero}) {
    task.timer.start();
  }

  void stopTaskTimer(Task task) {
    int newSpentTime = int.parse(task.spentTime) + task.timer.elapsed.inSeconds;
    task.timer.stop();
    KanQ.fireStore
        .collection(KanQ.projectsCollection)
        .doc(KanQ.myProjects[selectedProjectIndex].projectId)
        .collection(KanQ.taskCollection)
        .doc(task.taskId)
        .update({
      KanQ.spentTime: newSpentTime.toString(),
    });
  }

  Future<void> _exportToCSV() async {
    List<List<dynamic>> rows = [];
    for (var board in _pBoards) {
      rows.add([board.boardName]);

      for (var task in board.boardTasks) {
        Duration elapsed =
            Duration(seconds: int.parse(task.spentTime)) + task.timer.elapsed;

        DateTime endDate = task.taskEndDate.toDate();
        var outputFormat = DateFormat('yyyy-MM-dd   HH:mm:ss');
        var outputDate = outputFormat.format(endDate);
        rows.add(["     Task Name: ${task.taskName}"]);
        rows.add(["          Task Description: ${task.taskDescription}"]);
        rows.add([
          "          Completed Date: ${task.completed ? outputDate.toString() : "Not Completed"}"
        ]);
        rows.add([
          "          Spent Time: ${elapsed.inHours.toString().padLeft(2, '0')}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}"
        ]);
        rows.add([]);
      }
      rows.add([]);
      rows.add([]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getExternalStorageDirectory();
    final path = directory!.path;

    final file =
        File('$path/${KanQ.myProjects[selectedProjectIndex].projectName}.csv');
    await file.writeAsString(csv).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "file exported in: '$path/${KanQ.myProjects[selectedProjectIndex].projectName}.csv'")));

    });


    Share.shareXFiles([
      XFile('$path/${KanQ.myProjects[selectedProjectIndex].projectName}.csv')
    ], text: KanQ.myProjects[selectedProjectIndex].projectName);
  }
}
