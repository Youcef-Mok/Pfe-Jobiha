// Web implementation — dart:js_interop (modern replacement for dart:html)
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

JSObject get _ls => globalContext.getProperty('localStorage'.toJS);

String? platformRead(String key) {
  final val = _ls.callMethod<JSAny?>('getItem'.toJS, key.toJS);
  return (val as JSString?)?.toDart;
}

void platformWrite(String key, String value) {
  _ls.callMethod<JSAny?>('setItem'.toJS, key.toJS, value.toJS);
}

void platformClear() {
  _ls.callMethod<JSAny?>('clear'.toJS);
}
