import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:kan_q/models/project.dart';
import 'package:kan_q/models/task.dart';

class CompletedTasks extends StatefulWidget {
  final Project project;
  const CompletedTasks({Key? key,required this.project}) : super(key: key);

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  List<Task> completedTask=[];
  @override
  void initState() {
    for(int i=0 ; i < widget.project.projectBoards.length; i++){
      for(int j=0 ; j < widget.project.projectBoards[i].boardTasks.length; j++){
        if( widget.project.projectBoards[i].boardTasks[j].completed){
          completedTask.add(widget.project.projectBoards[i].boardTasks[j]);
        }
      }
    }
    setState(() {

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: ListView.builder(
        itemCount: completedTask.length,
        itemBuilder: (context, index) {
          DateTime endDate = completedTask[index].taskEndDate.toDate();
          var outputFormat = DateFormat('yyyy-MM-dd   HH:mm:ss');
          var outputDate = outputFormat.format(endDate);
          return Card(
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
                      padding: const EdgeInsets.all(36),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  completedTask[index].taskName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style:
                                  const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                    completedTask[index].taskDescription,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                    const TextStyle(fontSize: 16),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Icon(Icons.alarm,
                                  color: Theme.of(context).primaryColor),
                              Expanded(
                                child: StreamBuilder(
                                  stream: Stream.periodic(const Duration(seconds: 1)).asBroadcastStream(),
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                    Duration elapsed = Duration(seconds: int.parse(completedTask[index].spentTime))+completedTask[index].timer.elapsed;
                                    String elapsedString =
                                        ' ${elapsed.inHours.toString().padLeft(2, '0')}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
                                    return Text(elapsedString ,style:
                                        const TextStyle(fontSize: 16),);
                                  },
                                ),)
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              
                              Expanded(
                                child: Text("Completed Date: $outputDate", style:
                                const TextStyle(fontSize: 16),),
                              ),
                            ],
                          )


                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
