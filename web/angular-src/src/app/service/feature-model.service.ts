import { Inject, Injectable } from '@angular/core';
import { Http, Response } from '@angular/http';

import { Observable } from 'rxjs/Observable';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';
import 'rxjs/add/operator/map';

import { Feature } from '../class/feature.interface';

@Injectable()
export class FeatureModelService {
    private _featureModel: Array<Feature> = [];
    private _featureModelSubject: BehaviorSubject<Feature[]> = new BehaviorSubject<Feature[]>(this._featureModel);
    public readonly featureModel$: Observable<Feature[]> = this._featureModelSubject.asObservable();

    private _lockedFeatures: Array<number> = [];
    private _lockedFeaturesSubject: BehaviorSubject<Array<number>> = new BehaviorSubject<Array<number>>(this._lockedFeatures);
    public readonly lockedFeatures$: Observable<Array<number>> = this._lockedFeaturesSubject.asObservable();
    private set lockedFeatures( val: Array<number> ) {
        this._lockedFeatures = val;
        this._lockedFeaturesSubject.next(val);
    }

    private _selectedFeatures: Array<number> = [];
    private _selectedFeaturesSubject: BehaviorSubject<Array<number>> = new BehaviorSubject<Array<number>>(this._selectedFeatures);
    public readonly selectedFeatures$: Observable<Array<number>> = this._selectedFeaturesSubject.asObservable();
    public set selectedFeatures( val : Array<number>) {
        this._selectedFeatures = val;
        this._setSelectedFeatures();
    }

    constructor( private http: Http ) {
        this.http.get('http://localhost:8080/api/model')
            .map( (res: Response) => res.json() )
            .subscribe( (featureModel: Array<Feature>) => {
                this._featureModel = featureModel;
                this._featureModelSubject.next(this._featureModel);

                this._getLockedFeatures();
            });
    }

    private _getLockedFeatures(): void {
        this.http.get('http://localhost:8080/api/locked')
            .map( (res: Response) => res.json() )
            .subscribe( (locked: Array<number>) => {
                console.log(locked);
                this.lockedFeatures = locked;
            });
    }

    private _setSelectedFeatures(): void {
        this.http.post('http://localhost:8080/api/locked',{
            selected: this._selectedFeatures.join(',')
        })
        .map( (res: Response) => res.json() )
        .subscribe( (locked: Array<number>) => {
            this.lockedFeatures = locked.filter( (val: number) => this._selectedFeatures.indexOf(val) < 0 );
            this._selectedFeaturesSubject.next(this._selectedFeatures);
        });
    }

    public reset(): void {
        this._getLockedFeatures();
        this._selectedFeatures = [];
        this._selectedFeaturesSubject.next(this._selectedFeatures);
    }
}
