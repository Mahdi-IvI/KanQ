import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/config.dart';
import 'task.dart';

class Board {
  final String _boardId;
  final int _boardIndex;
  final String _boardName;
  final List<Task> _boardTasks;
  final Timestamp _boardCreatedDate;

  Board(this._boardId,this._boardIndex, this._boardName, this._boardTasks, this._boardCreatedDate);

  Board.fromJson(Map<String, dynamic> json)
      : _boardId = json[KanQ.boardId],
        _boardIndex = json[KanQ.boardIndex],
        _boardName = json[KanQ.boardName],
        _boardTasks = json[KanQ.boardTasks],
        _boardCreatedDate = json[KanQ.boardCreatedDate];

  Map<String, dynamic> toJson() => {
    KanQ.boardId: _boardId,
    KanQ.boardIndex: _boardIndex,
    KanQ.boardName: _boardName,
    KanQ.boardTasks: _boardTasks,
    KanQ.boardCreatedDate: _boardCreatedDate,
  };

  Timestamp get boardCreatedDate => _boardCreatedDate;

  List<Task> get boardTasks => _boardTasks;

  String get boardName => _boardName;

  String get boardId => _boardId;
}
