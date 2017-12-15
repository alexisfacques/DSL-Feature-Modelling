"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var cp = require("child_process");
var express = require("express");
var bodyParser = require("body-parser");
var solver_1 = require("./solver");
var App = /** @class */ (function () {
    /**
     * App hosts a web server serving our Angular app.
     */
    function App(_host, _port) {
        if (_host === void 0) { _host = 'localhost'; }
        if (_port === void 0) { _port = 8080; }
        var _this = this;
        this._host = _host;
        this._port = _port;
        this._solver = new solver_1.Solver();
        var inputFile = process.argv[2] || './data/test.diagram';
        this._loadFeatureModel(inputFile)
            .then(function () {
            _this._createServer();
        })
            .catch(function () {
            process.abort();
        });
    }
    App.prototype._loadFeatureModel = function (inputFile) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var toCNF = cp.spawn('java', ['-jar', './bin/toCNF.jar', inputFile, './data/output.cnf']);
            var buffer;
            toCNF.stdout.on('data', function (data) {
                if (buffer)
                    buffer = Buffer.concat([buffer, data]);
                else
                    buffer = data;
            });
            toCNF.stderr.on('data', function (err) {
                console.error(err.toString('utf8'));
                reject();
            });
            toCNF.on('close', function (code) {
                _this._featureModel = JSON.parse(buffer.toString('utf8'));
                resolve();
            });
        });
    };
    App.prototype._createServer = function () {
        var _this = this;
        this._server = express()
            .use(bodyParser.urlencoded({ extended: true }))
            .use(bodyParser.json())
            .use(function (req, res, next) {
            res.header('Access-Control-Allow-Origin', '*');
            res.header('Access-Control-Allow-Headers', 'Content-Type');
            res.header('Access-Control-Allow-Origin', '*');
            res.header('Access-Control-Allow-Methods', 'GET,POST');
            if (req.method == 'OPTIONS')
                res.send(200);
            next();
        })
            .use('/', express.static("/usr/src/app/app/"))
            .get('/api/model', function (req, res, next) {
            res.json(_this._featureModel);
        })
            .get('/api/locked', function (req, res, next) {
            _this._solver.getLockedFeatures()
                .then(function (locked) {
                return res.json(locked);
            })
                .catch(function () {
                return res.status(500).json();
            });
        })
            .post('/api/locked', function (req, res, next) {
            _this._solver.getLockedFeatures(req.body.selected)
                .then(function (locked) {
                return res.json(locked);
            })
                .catch(function () {
                return res.status(500).json();
            });
        })
            .all('/*', function (req, res, next) {
            res.sendFile('index.html', { root: "/usr/src/app/app" });
        })
            .listen(this._port, this._host, function () {
            console.log("Web server listening to http://" + _this._host + ":" + _this._port + ". Loaded the following feature model :");
            console.log(_this._featureModel);
        });
    };
    return App;
}());
new App();
