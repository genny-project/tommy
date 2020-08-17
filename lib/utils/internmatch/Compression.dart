import 'dart:typed_data';
import 'dart:convert';

class Compression {
  // Compress the data
//   encode(string){
  String incomingByteArray;
//   }

  codecFunc(message) {
    incomingByteArray = convertDataURIToBinary(message);

    var decompressedDataArray = message.decompress(incomingByteArray);
    print(decompressedDataArray);

    /*var decompressedStr = utf8.decode( decompressedDataArray );

      const deeplyParsed = deepParseJson( decompressedStr );

      callback( deeplyParsed );*/
  }

//   // Decompress the data
//   decode(){

  decompressByteArrayMessage(message) async {
    print("Decompressing message : $message"); // eslint-disable-line
    codecFunc(message);
  }

  String convertDataURIToBinary(base64) {
    // var base64Index = dataURI.indexOf(BASE64_MARKER) + BASE64_MARKER.length;
    // var base64 = dataURI.substring(base64Index);
    var raw = utf8.encode(base64);
    var rawLength = raw.length;
    var array = new Uint8List(rawLength);

    for (var i = 0; i < rawLength; i++) {
      array[i] = raw.indexOf(i);
    }

    return array.toString();
  }
}
