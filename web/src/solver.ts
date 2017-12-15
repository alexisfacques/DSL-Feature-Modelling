import * as cp from 'child_process';


export class Solver {
    constructor( private _jarPath = './bin/sat4j.jar', private _inputFile = './data/output.cnf' ) {

    }

    public getLockedFeatures(assumptions: string = undefined): Promise<Array<number>> {
        return new Promise( (resolve, reject) => {
            let args: Array<string> = ['-jar', this._jarPath, 'locked', this._inputFile];
            if(assumptions) args.push(assumptions)
            let getCore: cp.ChildProcess = cp.spawn( 'java', args );

            let buffer: Buffer;

            getCore.stdout.on('data', (data: Buffer) => {
                if(buffer) buffer = Buffer.concat([buffer, data]);
                else buffer = data;
            });

            getCore.stderr.on('data', (err: any) => {
                console.error(err.toString('utf8'));
                reject();
            });

            getCore.on('close', (code: any) => {
                resolve(buffer
                            .toString('utf8')
                            .split('\n')[0]
                            .split(',')
                            .map( (string: string) => Number.parseInt(string) )
                        );
            });
        });
    }
}
