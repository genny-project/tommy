import 'dart:convert';
import 'package:internmatch/models/Answer.dart';
import 'package:internmatch/models/QDataAnswerMessage.dart';
import 'BaseEntityUtils.dart';
import 'DatabaseHelper.dart';


Future<String> getData() async {
  var dbData =
      await DatabaseHelper.internal().retrieveFromDB("dummytable", null);

// work out userCode
  var userCode= BaseEntityUtils.getUserCode();
  print('userCode=$userCode');
  //print(dbData[0]);

  //print(dbData[0]['id']);
  var items = new List<Answer>();
  for (final ans in dbData) {
    //print("##### ans=[$ans]");
    //print("##### ans['PRI_JOURNAL_DATE']= ${ans['PRI_JOURNAL_DATE']}");

    var dateElements = (ans['PRI_JOURNAL_DATE'] ?? '1/Jan/2020').split('/');
    var month = '00';
    switch (dateElements[1]) {
      case 'Jan':
        {
          month = '01';
        }
        break;
      case 'Feb':
        {
          month = '02';
        }
        break;
      case 'Mar':
        {
          month = '03';
        }
        break;
      case 'Apr':
        {
          month = '04';
        }
        break;
      case 'May':
        {
          month = '05';
        }
        break;
      case 'Jun':
        {
          month = '06';
        }
        break;
      case 'Jul':
        {
          month = '07';
        }
        break;
      case 'Aug':
        {
          month = '08';
        }
        break;
      case 'Sep':
        {
          month = '09';
        }
        break;
      case 'Oct':
        {
          month = '10';
        }
        break;
      case 'Nov':
        {
          month = '11';
        }
        break;
      case 'Dec':
        {
          month = '12';
        }
        break;
      default:
        {
          //statements;
        }
        break;
    }
    var dayNum = int.parse(dateElements[0]);
    var dayStr = '';
    if (dayNum < 10) {
      dayStr = '0' + dayNum.toString();
    } else {
      dayStr = dayNum.toString();
    }
    var fixedDate = dateElements[2] + '-' + month + '-' + dayStr;

    var journalCode =
        'JNL_' + userCode.substring(4) + dateElements[2] + month + dayStr;

    items.add(
        new Answer(userCode, journalCode, 'PRI_JOURNAL_DATE', "$fixedDate"));
    items.add(new Answer('PER_INTERN1', journalCode, 'PRI_JOURNAL_HOURS',
        "${ans['PRI_JOURNAL_HOURS']}"));
    items.add(new Answer(userCode, journalCode, 'PRI_JOURNAL_TASKS',
        "${ans['PRI_JOURNAL_TASKS']}"));
    items.add(new Answer(userCode, journalCode, 'PRI_JOURNAL_LEARNING_OUTCOMES',
        "${ans['PRI_JOURNAL_LEARNING_OUTCOMES']}"));
  }
  var answerMsg = new QDataAnswerMessage(items);
  var bridgeData = jsonEncode(answerMsg);

  //     '{"data_type": "Answer","msg_type": "DATA_MSG","token": "${AppAuthHelper.token}","items": [{"date": "${dbData[dbData.length - 1]['date']}", "hours": ${dbData[dbData.length - 1]['hours']}, "tasks": "${dbData[dbData.length - 1]['tasks']}", "LearningOutcomes": "${dbData[dbData.length - 1]['LearningOutcomes']}"}]}';
  //print("bridgedata :: $bridgeData");
  return bridgeData;
}

