import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:geoff/geoff.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

class UploadField extends StatefulWidget {
  final Ask ask;
  const UploadField({
    Key? key,
    required this.ask,
  }) : super(key: key);

  @override
  State<UploadField> createState() => _UploadFieldState();
}

class _UploadFieldState extends State<UploadField> {
  late final BaseEntity entity =
      BridgeHandler.findByCode(widget.ask.targetCode);
  FilePickerResult? fileResult;
  Map<String, dynamic>? requestBody;
  int? fileBytes;
  int? fileTotalBytes;
  String? type;
  @override
  Widget build(BuildContext context) {
    TemplateHandler.contexts[widget.ask.question.code] = context;
    return ListTile(
      title: Text(widget.ask.name),
      subtitle: Text(
          entity.findAttribute(widget.ask.attributeCode).getValue().toString()),
      leading: getLeading(),
      onTap: () async {
        fileResult = await FilePicker.platform.pickFiles();

        if (fileResult != null) {
          MultipartProgressRequest request = MultipartProgressRequest(
              'POST',
              Uri.parse(
                  BridgeEnv.ENV_MEDIA_PROXY_URL.replaceFirst('http', 'https')),
              onProgress: (bytes, total) {
            setState(() {
              fileBytes = bytes;
              fileTotalBytes = total;
            });
          });

          request.headers['Authorization'] = 'bearer ${Session.token}';

          request.files.add(await http.MultipartFile.fromPath(
              'file', fileResult!.files.single.path!));
          request.send().then((value) {
            value.stream.bytesToString().then((value) => setState(() {
                  requestBody = jsonDecode(value);
                  entity.findAttribute(widget.ask.attributeCode).valueString =
                     requestBody!['files'][0]['uuid'];
                  type = lookupMimeType(fileResult!.paths.first!)?.split('/').first;
                  widget.ask.answer(requestBody!['files'][0]['uuid']);
                }));
          });
        }

        // http.post(Uri.parse(BridgeEnv.ENV_MEDIA_PROXY_URL), headers: {'Content-Type': 'multipart/form-data', 'Authorization': 'bearer ${Session.token}'}, body: data, ).then((value) => print("Response ${value.statusCode} ${value.body}"));
      },
    );
  }

  Widget getLeading() {
    if (entity.findAttribute(widget.ask.attributeCode).getValue().isNotEmpty) {
      // String? type = lookupMimeType(fileResult!.paths.first!)?.split('/').first;
      switch (type) {
        case 'image':
          return Image.network(BridgeEnv.ENV_MEDIA_PROXY_URL +
              "/${entity.findAttribute(widget.ask.attributeCode).valueString}");
        case 'video':
          return Icon(Icons.video_file);
        default:
          return Icon(Icons.description);
      }
    } else if (fileTotalBytes != null && fileBytes != null) {
      return CircularProgressIndicator(
        value: (fileBytes! / fileTotalBytes!),
      );
    }

    return Icon(Icons.upload);
  }
}

class MultipartProgressRequest extends http.MultipartRequest {
  MultipartProgressRequest(
    String method,
    Uri url, {
    required this.onProgress,
  }) : super(method, url);
  final void Function(int bytes, int totalBytes) onProgress;
  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    int bytes = 0;
    final tstream = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) async {
        bytes += data.length;
        onProgress(bytes, contentLength);
        if (contentLength >= bytes) {
          sink.add(data);
        }
      },
    );
    final stream = byteStream.transform(tstream);
    return http.ByteStream(stream);
  }
}
