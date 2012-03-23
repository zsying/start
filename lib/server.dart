#library('server');

#import('dart:io');
#import('dart:isolate');
#import('router.dart');

class Server extends Isolate {
  String _host;
  int _port;
  HttpServer _server;
  Router _router;

  Server() : super() {
    _router = new Router();
  }
  
  stop() {
    _server.close();
    this.port.close();
  }

  void main() {
    this.port.receive((var message, SendPort replyTo) {
      if (message.isStart) {
        _host = message.params['host'];
        _port = message.params['port'];
        replyTo.send('Server starting', null);
        _server = new HttpServer();
        try {
          _server.listen(_host, _port);
          _server.onRequest = (HttpRequest req, HttpResponse rsp) =>
            _router.parse(req, rsp);
          replyTo.send('Server started', null);
        } catch (var e) {
          replyTo.send('Server error:${e.toString()}', null);
        }
      } else if (message.isStop) {
        replyTo.send('Server stopping', null);
        stop();
        replyTo.send('Server stopped', null);
      }
    });
  }

  noSuchMethod (String name, List args) {
    _router.add(name, args[0], args[1]);
  }
}
