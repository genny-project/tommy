import 'package:flutter_test/flutter_test.dart';
import '../lib/models/Answer.dart';
import 'dart:core';

// unit test for checking that the class in Answer.dart has the correct values from the json it produces

main(){
  test('testing answer class from Answer.dart',(){

    final testValue = 'valueTest';
    final testAttributeCode = 'attributeCodeTest';
    final testTargetCode = 'targetCodeTest';
    final testSourceCode = 'sourceCodeTest';

    Answer testAnswer = new Answer(testSourceCode, testTargetCode, testAttributeCode, testValue);
    Map<String, dynamic> testJson = testAnswer.toJson();

    // this is where the values are compared
    expect(testJson['value'], testValue);
    expect(testJson['attributeCode'], testAttributeCode);
    expect(testJson['targetCode'], testTargetCode);
    expect(testJson['sourceCode'], testSourceCode);
  });
}