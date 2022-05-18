import 'package:flutter/services.dart';
import 'package:sentence_boundary/sentence_boundary.dart';
import 'package:waray_translator/src/services/data_helper.dart';

class WarayTranslator extends DataHelper {
  WarayTranslator._singleton();
  static final WarayTranslator __ = WarayTranslator._singleton();
  static final SentenceBoundary _boundary = SentenceBoundary();
  static late final List<String> _englishSource;
  static late final List<String> _warayTarget;
  static Future<WarayTranslator> get instance async {
    var dataSet = await rootBundle.loadString("assets/corpus.txt");
    List<String> listLines = dataSet.split("\n");
    List<List<String>> parsets = [];
    for (String line in listLines) {
      parsets.add(line.split(RegExp(r"[\t]")));
    }
    _englishSource = _getInputData(parsets);
    _warayTarget = _getTargetData(parsets);
    return __;
  }

  static List<String> _getInputData(List<List<String>> data) {
    List<String> ff = [];
    for (var x in data) {
      ff.add(x[0]);
    }
    return ff;
  }

  static List<String> _getTargetData(List<List<String>> data) {
    List<String> ff = [];
    for (var x in data) {
      ff.add(x[x.length - 1]);
    }
    return ff;
  }

  Future<String> translate(String text) async {
    try {
      List<List<String>> _bounded = _boundary.detect(text);
      print("BOUNDED : $_bounded");
      List<List<String>> _translated = [];
      for (List<String> group in _bounded) {
        List<String> _translatedG = [];
        String fullgramText = group.join(" ");
        int regExpIndex = specialCharRegExp.firstMatch(fullgramText)?.end ?? -1;
        String foundRegExp = "";
        String foundName = "";
        print("FULLGRAM :$fullgramText");
        print("REGINDEX: $regExpIndex");
        if (regExpIndex >= 0) {
          foundRegExp = fullgramText[regExpIndex - 1];
        }
        fullgramText =
            fullgramText.replaceAll(specialCharRegExp, "").toLowerCase().trim();
        List<String> _engCopy = List.from(_englishSource.map(
            (e) => e.toLowerCase().replaceAll(specialCharRegExp, "").trim()));

        int indexOf = _engCopy.indexOf(fullgramText);
        print(
            "INDEX : ${_engCopy.indexOf("Where are you Tom ?".toLowerCase().replaceAll(specialCharRegExp, "").trim())}");
        if (indexOf < 0) {
          /// NOT FOUND!
          print("NOT FOUND ! $fullgramText");
          List<String> ff = fullgramText.split(" ");
          List<String> __translate = [];
          for (String z in ff) {
            int _indexOf = _engCopy.indexOf(z);
            if (_indexOf < 0) {
              __translate.add(z);
            } else {
              __translate.add(_warayTarget[_indexOf]
                  .replaceAll(specialCharRegExp, "")
                  .trim());
            }
            _translatedG.add(__translate.join(" "));
          }
        } else {
          _translatedG.add(
              _warayTarget[indexOf].replaceAll(specialCharRegExp, foundRegExp));
        }
        _translated.add(_translatedG);
        // if(fullgramText){}
        // for (String word in group) {
        //   String _temp = word;
        //   _temp = _temp
        //       .toLowerCase()
        //       .replaceAll(specialCharRegExp, "[FOUND-REGEXP]")
        //       .trim();
        //   print(_temp);
        //   // _englishSource.indexOf();
        //   // print(_temp.replaceAll(_regExp, replace));
        // }
      }
      print("TARGET : ${_translated}");
      // print(_warayTarget.sublist(0, 10));
      return "";
    } catch (e) {
      return text;
    }
  }
}
