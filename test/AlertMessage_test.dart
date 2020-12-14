import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/AlertMessage.dart';
//import 'package:mockito/mockito.dart';

//class MockBuildContext extends Mock implements BuildContext {}

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: showAlertMessage('find this', context),
      ),
    );
  }
}

void main() {
  //MockBuildContext _mockContext = MockBuildContext();
  testWidgets('showAlertMessage widget test', (WidgetTester tester) async {
    //Build our app and trigger a frame.
    await tester.pumpWidget(TestWidget());

    // await tester.pumpWidget(MaterialApp(
    //   title: 'Flutter Demo',
    //   home: Scaffold(
    //     appBar: AppBar(
    //       title: Text('title'),
    //     ),
    //     body: Center(
    //       child: Text('find this'),
    //     ),
    //   ),
    // ));

    tester.pumpAndSettle();

    //Future(() => expect(find.text('find this'), findsOneWidget));
    expect(find.text('find this'), findsOneWidget);
  });
}
