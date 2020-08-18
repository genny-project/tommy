import '../../models/BaseEntity.dart';
import '../../models/EntityAttribute.dart';
import './GetTokenData.dart';
import 'package:intl/intl.dart';

class BaseEntityUtils {
  static String getUniqueDatecode(String prefix, DateTime date) {
    String returnValue = prefix.toUpperCase();
    if (!returnValue.endsWith("_")) {
      returnValue = returnValue + "_";
    }
    returnValue += tokenData['sub'].toUpperCase().toString();
    var f = new NumberFormat("00", "en_AU");
    String dateCode =
        date.year.toString() + f.format(date.month) + f.format(date.day);
    returnValue += dateCode;
    print(returnValue);
    return returnValue;
  }

  static Future<BaseEntity> createBaseEntity(String code, String name) async {
    return BaseEntity.getBaseEntityByCode(code).then((be) {
      if (be == null) {
        be = new BaseEntity(code, name);
      }
      return be;
    });
  }

  static Future<String> getUniqueDateName(DateTime date) async {
    String value;
    var user = await BaseEntity.getBaseEntityByCode("USER");
    var firstname =
        user.getValue("PRI_FIRSTNAME", tokenData["name"].toString());
    DateFormat dateFormat = new DateFormat().addPattern("EEE d-MMM-yyyy");

    value = dateFormat.format(date) + " " + firstname;
    return value;
  }

  static String get2DigitString(int num) {
    var retStr = '';
    if (num < 10) {
      retStr = '0' + num.toString();
    } else {
      retStr = num.toString();
    }
    return retStr;
  }

  static String getUserCode() {
    var username = tokenData["preferred_username"];
    var userCode = 'PER_' +
        username
            .replaceAll("&", "_AND_")
            .replaceAll("@", "_AT_")
            .replaceAll(".", "_DOT_")
            .replaceAll("+", "_PLUS_")
            .toUpperCase();
    return userCode;
  }

  static String getUserNameFromToken() {
    var firstname = tokenData["given_name"];

    var lastname = tokenData["family_name"];

    return firstname + " " + lastname;
  }

  static String getDateString(DateTime date) {
    DateFormat dateFormat = new DateFormat().addPattern("EEE d-MMM-yyyy");

    return dateFormat.format(date);
  }
}
