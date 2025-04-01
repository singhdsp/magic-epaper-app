import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}
