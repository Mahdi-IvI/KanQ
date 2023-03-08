import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kan_q/models/board.dart';
import 'package:kan_q/models/project.dart';
import 'package:kan_q/models/task.dart';
import 'package:kan_q/myHomePage.dart';
import 'package:kan_q/widget/loading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'config/config.dart';
import 'models/taskTimer.dart';

class CreateAndEditTask extends StatefulWidget {
  const CreateAndEditTask(
      {Key? key,
      required this.fromNewBoard,
      required this.board,
      required this.edit,
      required this.project,
      this.task})
      : super(key: key);
  final bool fromNewBoard;
  final Board board;
  final Project project;
  final bool edit;
  final Task? task;

  @override
  State<CreateAndEditTask> createState() => _CreateAndEditTaskState();
}

class _CreateAndEditTaskState extends State<CreateAndEditTask> {
  late TextEditingController taskName;
  late TextEditingController taskDesc;
  late int importanceGrade;
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  @override
  void initState() {
    if (widget.edit) {
      taskName = TextEditingController(text: widget.task!.taskName);
      taskDesc = TextEditingController(text: widget.task!.taskDescription);
      importanceGrade = widget.task!.taskImportanceGrade;
    } else {
      taskName = TextEditingController();
      taskDesc = TextEditingController();
      importanceGrade = 1;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit
            ? "Edit Task"
            : widget.fromNewBoard
                ? "Create the First Task"
                : "Create a new Task"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.edit
                              ? "Edit Task"
                              : widget.fromNewBoard
                                  ? "Create the First Task"
                                  : "Create a new Task",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: taskName,
                        validator: (text) {
                          if (text != null && text.trim().isNotEmpty) {
                            return null;
                          } else {
                            return "Please Enter the task Name.";
                          }
                        },
                        decoration: const InputDecoration(
                            label: Text("Task Name..."),
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: 5,
                        controller: taskDesc,
                        validator: (text) {
                          if (text != null && text.trim().isNotEmpty) {
                            return null;
                          } else {
                            return "Please Enter the task Description.";
                          }
                        },
                        decoration: const InputDecoration(
                            label: Text("Task Description..."),
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Level: ",
                          style: TextStyle(fontSize: 18),
                        ),
                        RatingBar.builder(
                          initialRating: importanceGrade.toDouble(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return const Icon(
                                  MdiIcons.numeric1Circle,
                                  color: Colors.green,
                                );
                              case 1:
                                return const Icon(
                                  MdiIcons.numeric2Circle,
                                  color: Colors.orange,
                                );
                              case 2:
                                return const Icon(
                                  MdiIcons.numeric3Circle,
                                  color: Colors.red,
                                );
                              default:
                                return const Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Colors.green,
                                );
                            }
                          },
                          onRatingUpdate: (rating) {
                            setState(() {
                              importanceGrade = rating.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _loading = true;
                });
                late String taskId;
                late Task task;
                if (widget.edit) {
                  taskId = widget.task!.taskId;
                  task = Task(
                      taskId,
                      widget.task!.taskIndex,
                      widget.board.boardId,
                      taskName.text.trim().toString(),
                      taskDesc.text.trim().toString(),
                      widget.task!.taskStartDate,
                      widget.task!.taskEndDate,
                      [],
                      importanceGrade,
                      [],
                      TaskTimer(),
                      widget.task!.spentTime,
                      widget.task!.completed);
                } else {
                  taskId = DateTime.now().microsecondsSinceEpoch.toString();
                  task = Task(
                      taskId,
                      widget.board.boardTasks.length,
                      widget.board.boardId,
                      taskName.text.trim().toString(),
                      taskDesc.text.trim().toString(),
                      Timestamp.now(),
                      Timestamp.fromDate(
                          DateTime.now().add(const Duration(days: 14))),
                      [],
                      importanceGrade,
                      [],
                      TaskTimer(),
                      "0",
                      false);
                }
                await KanQ.fireStore
                    .collection(KanQ.projectsCollection)
                    .doc(widget.project.projectId)
                    .collection(KanQ.taskCollection)
                    .doc(taskId)
                    .set(task.toJson())
                    .whenComplete(() async {
                  await KanQ.getProjects().whenComplete(() {
                    setState(() {
                      _loading = false;
                    });
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MyHomePage()),
                        (route) => false);
                  });
                });
              }
            },
            child: SizedBox(
                width: double.infinity,
                height: kToolbarHeight,
                child: Center(
                    child: _loading
                        ? const WhiteLoading()
                        : Text(
                            widget.edit ? "Edit Task" : "Create new Task",
                            style: const TextStyle(fontSize: 18),
                          ))),
          ),
        ],
      ),
    );
  }
}
