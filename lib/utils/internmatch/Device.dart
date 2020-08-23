import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../ProjectEnv.dart';
import '../../models/Answer.dart';
import '../../models/BaseEntity.dart';
import '../../models/QBulkMessage.dart';
import '../../models/Token.dart';
import './BaseEntityUtils.dart';
import './Sync.dart';

import 'dart:io';

import 'AppAuthHelper.dart';

class Device {
  static var deviceType;
  static var deviceCode;
  static var deviceVersion;

  static Answer deviceCodeAns;
  static Answer deviceTypeAns;
  static Answer deviceVersionAns;

  Device() {
    //initPlatformState().whenComplete(() => null);
  }



  Future<bool>_registerDevice() async {
     print("Registering Device");

    // set up POST request arguments
  


  //BaseEntity user = await BaseEntity.getBaseEntityByCode("USER");
  String userCode = BaseEntityUtils.getUserCode();
  
  deviceCodeAns = new Answer(userCode,userCode,"PRI_DEVICE_CODE",deviceCode);
  deviceTypeAns = new Answer(userCode,userCode,"PRI_DEVICE_TYPE",deviceType);
  deviceVersionAns = new Answer(userCode,userCode,"PRI_DEVICE_VERSION",deviceVersion);

  //Sync.doTheSync(); // and wait

   return true;
    // return Device.postHTTP(url, json).then((statusCode) {
    //   print("Device Registration Status Code =  $statusCode");
    //   return true;
    // });
    
  }

  Future<bool> initPlatformState() async {
    Map<String, dynamic> deviceData;

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        deviceType = "ANDROID";
        deviceCode = deviceData['androidId'];
        deviceVersion = deviceData['version.release'];
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        deviceType = "IOS";
        deviceCode = deviceData['identifierForVendor'];
        deviceVersion = deviceData['systemVersion'];
      }
      print("deviceType :: $deviceType");
      print("deviceCode :: $deviceCode");
      print("deviceVersion :: $deviceVersion");
      } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
      return  _registerDevice();
    
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static Future<String> postHTTP(url, data) async {
    var token = ProjectEnv.token;
    if (ProjectEnv.token == null) {
      token = AppAuthHelper.token;
    }
    var response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: data);
    if (response.statusCode == 200) {
      print(response.statusCode);
      print("Content Length= $response.contentLength");
      print(response.headers);
      print(response.request);
      var lastUpdated = DateTime.now();

      Token token = new Token(lastUpdated);
      token.persist();
 
    QBulkMessage.processQBulkMessage(response.body).then((_) {return (response.statusCode.toString());});
      
    } else {
      print("No response from backend device server");
      return (null);
    }
  }
}
