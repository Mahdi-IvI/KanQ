import 'package:kan_q/models/user.dart';

class Comment{
  late User from;
  late DateTime publishDate;
  late String text;
  Comment(from,publishDate,text);
}