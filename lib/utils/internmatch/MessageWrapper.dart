Message message = new Message();

class Message {
  static final Message _message = new Message._internal();

  factory Message() {
    return _message;
  }

  Message._internal();

  pingMessage() {
    return {"type": "ping"};
  }

  messageWrapper(type, address, header, data) {
    if (data == null) {
      return {"type": type, "address": address, "header": header};
    } else {
      return {
        "type": type,
        "address": address,
        "header": header,
        "body": {"data": data}
      };
    }
  }

  eventMessage(final address, final event) {
    return (messageWrapper("send", address, {}, event));
  }

  registerMessage(final session_state) {
    return (messageWrapper("register", session_state, {}, null));
  }
}
