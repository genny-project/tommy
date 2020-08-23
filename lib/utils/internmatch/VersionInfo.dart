import 'package:flutter/services.dart';
import '../../models/Answer.dart';
import './BaseEntityUtils.dart';
import 'package:package_info/package_info.dart';

class Version {
  static var appName;
  static var packageName;
  static var version;
  static var buildNumber;

  static Answer appNameAns;
  static Answer appVersionAns;
  static Answer appBuildNumberAns;

  Future<bool> getpackageInfo() async {
    String userCode = BaseEntityUtils.getUserCode();

    appNameAns = new Answer(userCode, userCode, "PRI_DEVICE_CODE", appName);
    appVersionAns = new Answer(userCode, userCode, "PRI_DEVICE_CODE", version);
    appBuildNumberAns =
        new Answer(userCode, userCode, "PRI_DEVICE_CODE", buildNumber);

    return true;
  }

  Future<bool> initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    try {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } on PlatformException {
      print("No packge info");
    }
    return getpackageInfo();
  }
}
