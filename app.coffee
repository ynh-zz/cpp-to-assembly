cluster = require('cluster')
numCPUs = require('os').cpus().length;

if cluster.isMaster
  for i in [1..numCPUs]
    cluster.fork();
else

  express = require('express')
  routes = require('./routes')
  http = require('http')
  path = require('path')

  app = express();

  app.configure ()->
    app.set('port', process.env.PORT || 8080);
    app.set('views', __dirname + '/views');
    app.set('view engine', 'ejs');
    app.use(express.favicon());
  #  app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser('your secret here'));
    app.use(express.session());
    app.use(app.router);
    app.use(require('stylus').middleware(__dirname + '/public'));
    app.use(express.static(path.join(__dirname, 'public')));
    app.use routes.error404


  #app.configure 'development', ()->
  #  app.use(express.errorHandler())

 
  app.post '/compile', routes.indexpost


  http.createServer(app).listen app.get('port'), ()->
    console.log("Express server listening on port " + app.get('port'));
   