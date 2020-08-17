abstract class Event {
  var _data;
  var _eventType;
  var _msgType;
  var _token;
  var _items;
  var _dataType;
}

abstract class IncomingEvent extends Event {
  var _type;
  var _payload;
}

abstract class OutgoingEvent extends Event {
  eventMsg() => {
        'event_type': this._eventType,
        'msg_type': this._msgType,
        'token': this._token,
        'data': this._data,
        'items': this._items,
        'data_type': this._dataType
      };
}

/*Button CLick Event*/
/*------------------------------------------------*/
buttonClickEvent({eventType, data, token, items, beCode}) =>
    new ButtonClickEvent(eventType, data, token);

class ButtonClickEvent extends OutgoingEvent {
  ButtonClickEvent(eventType, data, token) {
    this._data = data;
    this._eventType = eventType;
    this._token = token;
    this._msgType = 'EVT_MSG';
  }
}

/* Ask Back */
/*------------------------------------------------*/
answerEvent({eventType, data, token, items, beCode}) =>
    new AnswerEvents(items, token);

class AnswerEvents extends OutgoingEvent {
  AnswerEvents(items, token) {
    this._dataType = "Answer";
    this._token = token;
    this._msgType = 'DATA_MSG';
    this._items = 'items';
  }
}

/* Auth Events */
/*------------------------------------------------*/
authInit({eventType, data, token, items, beCode}) => new AuthInit(token);

class AuthInit extends OutgoingEvent {
  AuthInit(token) {
    this._eventType = 'AUTH_INIT';
    this._msgType = 'EVT_MSG';
    this._token = token;
    this._data = {'code': 'AUTH_INIT'};
  }
}

redirectReturn({eventType, data, token, items, beCode}) =>
    new RedirectReturn(token);

class RedirectReturn extends OutgoingEvent {
  RedirectReturn(token) {
    this._eventType = 'REDIRECT_RETURN';
    this._msgType = 'EVT_MSG';
    this._token = token;
    this._data = {
      'code': 'REDIRECT_RETURN',
    };
  }
}

sendCode({eventType, data, token, items, beCode}) =>
    new SendCode(eventType, data, token);

class SendCode extends OutgoingEvent {
  SendCode(eventType, data, token) {
    this._eventType = eventType;
    this._msgType = 'EVT_MSG';
    this._token = token;
    this._data = data;
  }
}

logOut({eventType, data, token, items, beCode}) =>
    LogOut(eventType, data, token);

class LogOut extends OutgoingEvent {
  LogOut(eventType, data, token) {
    this._eventType = eventType;
    this._msgType = 'EVT_MSG';
    this._token = token;
    this._data = data;
  }
}

/*Bucket Event*/
/*------------------------------------------------*/

bucketDropEvent({eventType, data, token, items, beCode}) =>
    new BucketDropEvent(data, token);

class BucketDropEvent extends OutgoingEvent {
  BucketDropEvent(data, token) {
    this._eventType = 'EVT_LINK_CHANGE';
    this._msgType = 'EVT_MSG';
    this._token = token;
    this._data = data;
  }
}

/*Cache miss Event*/
/*------------------------------------------------*/
cacheMissing({eventType, data, token, items, beCode}) =>
    new CacheMissing(beCode, token);

class CacheMissing extends OutgoingEvent {
  var _beCode;
  CacheMissing(beCode, token) {
    this._eventType = 'EVT_CACHE_MISSING';
    this._msgType = 'EVT_MSG';
    this._token = token;
    this._data = null;
    var targetBaseEntityCode = this._beCode;
  }

  eventMsg() => {
        'event_type': this._eventType,
        'msg_type': this._msgType,
        'token': this._token,
        'data': this._data,
        'items': this._items,
        'data_type': this._dataType,
        'targetBaseEntityCode': this._beCode
      };
}

/*Form Submit*/
/*------------------------------------------------*/
formSubmit({eventType, data, token, items, beCode}) =>
    new FormSubmit(data, token);

class FormSubmit extends OutgoingEvent {
  FormSubmit(data, token) {
    this._eventType = 'FORM_SUBMIT';
    this._msgType = 'EVT_MSG';
    this._data = data;
    this._token = token;
  }
}

/*GPS Data*/
/*------------------------------------------------*/
gpsData({eventType, data, token, items, beCode}) => new GPSData(items, token);

class GPSData extends OutgoingEvent {
  GPSData(items, token) {
    this._msgType = 'DATA_MSG';
    this._data = 'GPS';
    this._token = token;
    this._items = items;
  }
}

/*Search Data*/
/*------------------------------------------------*/
search({eventType, data, token, items, beCode}) => new Search(data, token);

class Search extends OutgoingEvent {
  Search(data, token) {
    this._eventType = 'SEARCH';
    this._msgType = 'EVT_MSG';
    this._data = data;
    this._token = token;
  }
}

tvEvent({eventType, data, token, items, beCode}) =>
    new TvEvent(eventType, data, token);

class TvEvent extends OutgoingEvent {
  TvEvent(eventType, data, token) {
    this._eventType = eventType;
    this._msgType = 'EVT_MSG';
    this._token = token;
    this._data = data;
  }
}

/*Incoming Alias */
/*----------------------------------------*/
alias(message) => new Alias(message);

class Alias extends IncomingEvent {
  Alias(message) {
    this._type = 'ALIAS_DATA';
    this._payload = message;
  }
}

/*Incoming Answer */
/*----------------------------------------*/
answer(message) => new Answer(message);

class Answer extends IncomingEvent {
  Answer(message) {
    this._type = 'ANSWER_DATA';
    this._payload = message;
  }
}

/*Incoming Ask  */
/*----------------------------------------*/
ask(message) => new Ask(message);

class Ask extends IncomingEvent {
  Ask(messgae) {
    this._type = 'ASK_DATA';
    this._payload = 'message';
  }
}

/*Incoming Attribute Data  */
/*----------------------------------------*/
attribute(message) => new Attribute(message);

class Attribute extends IncomingEvent {
  Attribute(message) {
    this._type = 'ATTRIBUTE_DATA';
    this._payload = message;
  }
}

/* INcoming Logout Command */
/*----------------------------------------*/
cmdLogOut() => new CmdLogOut();

class CmdLogOut extends IncomingEvent {
  CmdLogOut() {
    this._type = 'LOGOUT';
  }
}

/*Incoming Accounts Command */
/*----------------------------------------*/
accountCmd() => new AccountCmd();

class AccountCmd extends IncomingEvent {
  AccountCmd() {
    this._type = 'ACCOUNTS';
  }
}

/*Incoming baseEntity */
/*----------------------------------------*/
baseEntity(messgae) => new BaseEntity(messgae);

class BaseEntity extends IncomingEvent {
  BaseEntity(messgae) {
    this._type = 'BASE_ENTITY_MESSAGE';
    this._payload = messgae;
  }
}

/* Incoming Data*/
/*----------------------------------------*/
data(message) => new Data(message);

class Data extends IncomingEvent {
  Data(message) {
    this._type = 'DATA';
    this._payload = message;
  }
}

/* Event Link Change */
/*----------------------------------------*/
eventLinkChange(message) => new EventLinkChange(message);

class EventLinkChange extends IncomingEvent {
  EventLinkChange(message) {
    this._type = 'BASE_ENTITY_LINK_CHANGE';
    this._payload = message;
  }
}

/* GPS command */
/*----------------------------------------*/
gpsCmd(message) => new GPSCmd(message);

class GPSCmd extends IncomingEvent {
  GPSCmd(message) {
    this._type = 'GPS_CMD';
    this._payload = message;
  }
}

/*GPS monitor cmd */
/*----------------------------------------*/
gpsMonitor(message) => new GPSMonitor(message);

class GPSMonitor extends IncomingEvent {
  GPSMonitor(message) {
    this._type = this._payload = message;
  }
}

/*GPS monitor cmd */
/*----------------------------------------*/
layoutCmd(message) => new LayoutCmd(message);

class LayoutCmd extends IncomingEvent {
  LayoutCmd(message) {
    this._type = 'LAYOUT_CHANGE';
    this._payload = message;
  }
}

/*View cmd */
/*----------------------------------------*/
viewCmd(message) => new ViewCmd(message);

class ViewCmd extends IncomingEvent {
  ViewCmd(message) {
    this._type = 'VIEW_CHANGE';
    this._payload = message;
  }
}

/*PopUp cmd */
/*----------------------------------------*/
popupCmd(message) => new PopupCmd(message);

class PopupCmd extends IncomingEvent {
  PopupCmd(message) {
    this._type = 'POPUP_CHANGE';
    this._payload = message;
  }
}

/*Notification cmd */
/*----------------------------------------*/
notificationCmd(message) => new NotificationCmd(message);

class NotificationCmd extends IncomingEvent {
  NotificationCmd(message) {
    this._type = 'MOTIFICATON_MESSAGE';
    this._payload = message;
  }
}

/*SubLayout code */
/*----------------------------------------*/
subLayout(message) => new SubLayout(message);

class SubLayout extends IncomingEvent {
  SubLayout(message) {
    this._type = 'SUBLAYOUT_CODE';
    this._payload = message;
  }
}

/*Sublayout change cmd */
/*----------------------------------------*/
subLayoutCmd(message) => new SubLayoutCmd(message);

class SubLayoutCmd extends IncomingEvent {
  SubLayoutCmd(message) {
    this._type = 'SUBLAYOUT_CHANGE';
    this._payload = message;
  }
}

/*Reload cmd */
/*----------------------------------------*/
reloadCmd(message) => new ReloadCmd(message);

class ReloadCmd extends IncomingEvent {
  ReloadCmd(message) {
    this._type = 'RELOAD_PAGE';
    this._payload = message;
  }
}

/* Incoming  Notification cmd */
/*----------------------------------------*/
notification(message) => new Notification(message);

class Notification extends IncomingEvent {
  Notification(message) {
    this._type = 'NOTIFICATION_DATA';
    this._payload = message;
  }
}

/* Redirect  Notification cmd */
/*----------------------------------------*/
redirectCmd(message) => new RedirectCmd(message);

class RedirectCmd extends IncomingEvent {
  RedirectCmd(message) {
    this._type = 'REDIRECT';
    this._payload = message.redirect_url;
  }
}

/* Social Redirect cmd */
/*----------------------------------------*/
socialRedirectCmd(message) => new SocialRedirectCmd(message);

class SocialRedirectCmd extends IncomingEvent {
  SocialRedirectCmd(message) {
    this._type = 'SOCIAL';
    this._payload = message;
  }
}

/* Route Back */
/*----------------------------------------*/
routeBack(message) => new RouteBack(message);

class RouteBack extends IncomingEvent {
  RouteBack(message) {
    this._type = 'ROUTE_BACK';
    this._payload = message;
  }
}

/*Route Change*/
routeChange(message) => new RouteChange(message);

class RouteChange extends IncomingEvent {
  RouteChange(message) {
    this._type = 'ROUTE_CHANGE';
    this._payload = message;
  }
}
