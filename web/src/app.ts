import * as cp from 'child_process';

import * as express from 'express';
import * as bodyParser from 'body-parser';
import * as http from 'http';

import { Solver } from './solver';

class App {
    /**
     * Our web server object.
     */
    private _server: http.Server;

    private _solver: Solver = new Solver();

    private _featureModel: any;

    /**
     * App hosts a web server serving our Angular app.
     */
    constructor( private _host: string = 'localhost', private _port: number = 8080 ) {
        let inputFile: string = process.argv[2] || './data/test.diagram';

        this._loadFeatureModel(inputFile)
            .then( () => {
                this._createServer();
            })
            .catch( () => {
                process.abort();
            });

    }

    private _loadFeatureModel( inputFile: string ): Promise<void> {
        return new Promise( (resolve, reject) => {
            let toCNF: cp.ChildProcess = cp.spawn( 'java', ['-jar', './bin/transform.jar', 'cnf', inputFile, './data/output.cnf'] );

            let buffer: Buffer;

            toCNF.stdout.on('data', (data: Buffer) => {
                if(buffer) buffer = Buffer.concat([buffer, data]);
                else buffer = data;
            });

            toCNF.stderr.on('data', (err: any) => {
                console.error(err.toString('utf8'));
                reject();
            });

            toCNF.on('close', (code: any) => {
                this._featureModel = JSON.parse(buffer.toString('utf8'));
                resolve();
            });
        });
    }

    private _createServer(): void {
        this._server = express()
            .use(bodyParser.urlencoded({ extended: true }))
            .use(bodyParser.json())

            // CORS
            .use( (req: express.Request, res: express.Response, next: express.NextFunction) => {
                res.header('Access-Control-Allow-Origin', '*');
                res.header('Access-Control-Allow-Headers', 'Content-Type');
                res.header('Access-Control-Allow-Origin', '*');
                res.header('Access-Control-Allow-Methods', 'GET,POST');

                if (req.method == 'OPTIONS' ) res.send(200);
                next();
            })

            // Directory to our web app.
            .use('/', express.static(`/usr/src/app/app/`))

            .get('/api/model', (req: express.Request, res: express.Response, next: express.NextFunction) => {
                res.json(this._featureModel);
            })

            .get('/api/locked', (req: express.Request, res: express.Response, next: express.NextFunction) => {
                this._solver.getLockedFeatures()
                    .then( (locked: Array<number> ) => {
                        return res.json(locked);
                    })
                    .catch( () => {
                        return res.status(500).json();
                    });
            })

            .post('/api/locked', (req: express.Request, res: express.Response, next: express.NextFunction) => {
                this._solver.getLockedFeatures(req.body.selected)
                    .then( (locked: Array<number> ) => {
                        return res.json(locked);
                    })
                    .catch( () => {
                        return res.status(500).json();
                    });
            })

            // Angular will handle the possible rooting.
            .all('/*', (req: express.Request, res: express.Response, next: express.NextFunction) => {
                res.sendFile('index.html', { root: `/usr/src/app/app` });
            })

            // Creating the web server.
            .listen(this._port, this._host, () => {
                console.log(`Web server listening to http://${this._host}:${this._port}. Loaded the following feature model :`);
                console.log(this._featureModel);
            });
    }
}

new App();
