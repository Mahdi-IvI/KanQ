import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kan_q/models/board.dart';
import 'package:kan_q/models/project.dart';
import 'package:kan_q/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/taskTimer.dart';

class KanQ{
  static const String appName = 'KanQ';

  static late FirebaseAuth auth;
  static late FirebaseFirestore fireStore;
  static late FirebaseApp firebaseApp;
  static late SharedPreferences sharedPreferences;
  static late List<Project> myProjects;
  static const themeStatus = "themeStatus";

  static const String lastProjectIndex = 'lastProjectIndex';


  static const String userUID = 'userUID';
  static const String userEmail = 'userEmail';
  static const String userName = 'userName';
  static String userCollection = "users";
  static String userImageUrl = "userImageUrl";
  static String userProjects = "userProjects";


  static String projectsCollection = "projects";
  static String projectId = "projectId";
  static String projectName = "projectName";
  static String projectOwner = "projectOwner";
  static String projectMembers = "projectMembers";
  static String projectCreatedDate = "projectCreatedDate";
  static String projectBoards = "projectBoards";
  static String projectJoinCode = "projectJoinCode";


  static String boardCollection = "board";
  static String boardId = "boardId";
  static String boardIndex = "boardIndex";
  static String boardName = "boardName";
  static String boardTasks = "boardTasks";
  static String boardCreatedDate = "boardCreatedDate";

   static String taskCollection="task";
   static String taskId="taskId";
   static String taskIndex="taskIndex";
   static String taskName="taskName";
   static String taskDescription="taskDescription";
   static String taskStartDate="taskStartDate";
   static String taskEndDate="taskEndDate";
   static String taskMembers="taskMembers";
   static String taskImportanceGrade="taskImportanceGrade";
   static String taskComments="taskComments";
   static String spentTime="spentTime";
   static String completed="completed";

  static Future getProjects() async {
    KanQ.myProjects = [];
    QuerySnapshot projectQuerySnapshot = await KanQ.fireStore
        .collection(KanQ.projectsCollection)
        .where(KanQ.projectMembers, arrayContains: KanQ.auth.currentUser?.uid)
        .get();
    for (var projectDoc in projectQuerySnapshot.docs) {
      List<Board> boards = await getBoards(projectDoc[KanQ.projectId]);
      Project project = Project(
          projectDoc[KanQ.projectId],
          projectDoc[KanQ.projectName],
          projectDoc[KanQ.projectOwner],
          projectDoc[KanQ.projectMembers],
          boards,
          projectDoc[KanQ.projectJoinCode],
          projectDoc[KanQ.projectCreatedDate]);

        KanQ.myProjects.add(project);

    }
  }

  static Future<List<Board>> getBoards(String projectId) async {
    List<Board> boards = [];

    QuerySnapshot boardsQuerySnapshot = await KanQ.fireStore
        .collection(KanQ.projectsCollection)
        .doc(projectId)
        .collection(KanQ.boardCollection)
        .orderBy(KanQ.boardIndex)
        .get();

    for (var boardDoc in boardsQuerySnapshot.docs) {
      List<Task> tasks = await getTasks(projectId, boardDoc[KanQ.boardId]);
      Board board = Board(boardDoc[KanQ.boardId], boardDoc[KanQ.boardIndex],
          boardDoc[KanQ.boardName], tasks, boardDoc[KanQ.boardCreatedDate]);
      boards.add(board);
    }
    return boards;
  }

  static Future<List<Task>> getTasks(String projectId, String boardId) async {
    QuerySnapshot taskQuerySnapshot = await KanQ.fireStore
        .collection(KanQ.projectsCollection)
        .doc(projectId)
        .collection(KanQ.taskCollection)
        .where(KanQ.boardId, isEqualTo: boardId)
        .orderBy(KanQ.taskIndex)
        .get();

    List<Task> tasks = [];
    for (var taskDoc in taskQuerySnapshot.docs) {
      Task task = Task(
          taskDoc[KanQ.taskId],
          taskDoc[KanQ.taskIndex],
          taskDoc[KanQ.boardId],
          taskDoc[KanQ.taskName],
          taskDoc[KanQ.taskDescription],
          taskDoc[KanQ.taskStartDate],
          taskDoc[KanQ.taskEndDate],
          [],
          taskDoc[KanQ.taskImportanceGrade],
          [],
        TaskTimer(),
        taskDoc[KanQ.spentTime],
        taskDoc[KanQ.completed],
      );
      tasks.add(task);
    }

    return tasks;
  }
}