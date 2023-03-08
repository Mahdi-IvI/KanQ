import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_q/models/comment.dart';
import 'package:kan_q/models/taskTimer.dart';
import 'package:kan_q/models/user.dart';
import '../config/config.dart';

class Task {
  final String _taskId;
  final int _taskIndex;
  final String _boardId;
  final String _taskName;
  final String _taskDescription;
  final Timestamp _taskStartDate;
  Timestamp _taskEndDate;
  final List<User> _taskMembers;
  final int _taskImportanceGrade;
  final List<Comment> _taskComments;
   TaskTimer _timer;
  final String _spentTime;
  bool _completed;

  TaskTimer get timer => _timer;

  set timer(TaskTimer value) {
    _timer = value;
  }

  Task(
      this._taskId,
      this._taskIndex,
      this._boardId,
      this._taskName,
      this._taskDescription,
      this._taskStartDate,
      this._taskEndDate,
      this._taskMembers,
      this._taskImportanceGrade,
      this._taskComments,
      this._timer,
      this._spentTime,
      this._completed);

  void addMember(User user) {
    _taskMembers.add(user);
  }

  void addComment(Comment comment) {
    _taskComments.add(comment);
  }

  set setEndDate(Timestamp endDate) {
    _taskEndDate = endDate;
  }

  Task.fromJson(Map<String, dynamic> json, this._timer)
      : _taskId = json[KanQ.taskId],
        _taskIndex = json[KanQ.taskIndex],
        _boardId = json[KanQ.boardId],
        _taskName = json[KanQ.taskName],
        _taskDescription = json[KanQ.taskDescription],
        _taskStartDate = json[KanQ.taskStartDate],
        _taskEndDate = json[KanQ.taskEndDate],
        _taskMembers = json[KanQ.taskMembers],
        _taskImportanceGrade = json[KanQ.taskImportanceGrade],
        _taskComments = json[KanQ.taskComments],
        _spentTime = json[KanQ.spentTime],
        _completed = json[KanQ.completed];

  Map<String, dynamic> toJson() => {
        KanQ.taskId: _taskId,
        KanQ.taskIndex: _taskIndex,
        KanQ.boardId: _boardId,
        KanQ.taskName: _taskName,
        KanQ.taskDescription: _taskDescription,
        KanQ.taskStartDate: _taskStartDate,
        KanQ.taskEndDate: _taskEndDate,
        KanQ.taskMembers: _taskMembers,
        KanQ.taskImportanceGrade: _taskImportanceGrade,
        KanQ.taskComments: _taskComments,
        KanQ.spentTime: _spentTime,
        KanQ.completed: _completed,
      };

  List<Comment> get taskComments => _taskComments;

  int get taskImportanceGrade => _taskImportanceGrade;

  List<User> get taskMembers => _taskMembers;

  Timestamp get taskEndDate => _taskEndDate;

  set completed(bool value) {
    _completed = value;
  }

  Timestamp get taskStartDate => _taskStartDate;

  String get taskDescription => _taskDescription;

  String get taskName => _taskName;

  String get taskId => _taskId;

  bool get completed => _completed;

  String get spentTime => _spentTime;

  String get boardId => _boardId;

  int get taskIndex => _taskIndex;
}
