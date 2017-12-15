"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var cp = require("child_process");
var Solver = /** @class */ (function () {
    function Solver(_jarPath, _inputFile) {
        if (_jarPath === void 0) { _jarPath = './bin/sat4j.jar'; }
        if (_inputFile === void 0) { _inputFile = './data/output.cnf'; }
        this._jarPath = _jarPath;
        this._inputFile = _inputFile;
    }
    Solver.prototype.getLockedFeatures = function (assumptions) {
        var _this = this;
        if (assumptions === void 0) { assumptions = undefined; }
        return new Promise(function (resolve, reject) {
            var args = ['-jar', _this._jarPath, 'locked', _this._inputFile];
            if (assumptions)
                args.push(assumptions);
            var getCore = cp.spawn('java', args);
            var buffer;
            getCore.stdout.on('data', function (data) {
                if (buffer)
                    buffer = Buffer.concat([buffer, data]);
                else
                    buffer = data;
            });
            getCore.stderr.on('data', function (err) {
                console.error(err.toString('utf8'));
                reject();
            });
            getCore.on('close', function (code) {
                resolve(buffer
                    .toString('utf8')
                    .split('\n')[0]
                    .split(',')
                    .map(function (string) { return Number.parseInt(string); }));
            });
        });
    };
    return Solver;
}());
exports.Solver = Solver;
