/*Event helper class any user event will first call method from this class*/
import '../../models/Event.dart';
import './EventHandler.dart';

class UserEventHelper {
  EventHandler _eventHandler;

  UserEventHelper(EventHandler eventHandler){
      _eventHandler = eventHandler;
  }

  sendCode(eventType, data) {
    _eventHandler.sendEvent(
        event: sendCode, sendWithToken: true, eventType: null, data: null);
  }

  sendAnswers(answers) {
    _eventHandler.sendEvent(
        event: answerEvent,
        sendWithToken: true,
        eventType: null,
        data: answers);
  }

  sendAnswer(answers) {
    sendAnswers([answers]);
  }

  sendButtonEvent(eventType, data) {
    _eventHandler.sendEvent(
        event: buttonClickEvent,
        sendWithToken: true,
        eventType: eventType,
        data: data);
  }

  sendTreeViewEvent(eventType, data) {
    _eventHandler.sendEvent(
        event: tvEvent, sendWithToken: true, eventType: eventType, data: data);
  } 
  
  logout(){
    _eventHandler.logout();
  }
}
