import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_q/models/board.dart';

class SampleProjectBoards{
   final Board _toDoBoard=Board("To Do",
      1, "To Do", [], Timestamp.now());
  final Board _inProgressBoard=Board("In Progress",
      2, "In Progress", [], Timestamp.now());
  final Board _doneBoard=Board("Done",
      3, "Done", [], Timestamp.now());

  List<Board> sampleBoards=[];

   List<Board> createSampleBoard(){
     sampleBoards.add(_toDoBoard);
     sampleBoards.add(_inProgressBoard);
     sampleBoards.add(_doneBoard);
     return sampleBoards;
   }


}