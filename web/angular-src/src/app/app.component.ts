import { Component, HostBinding } from '@angular/core';
import { OnDestroy } from '@angular/core';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/operator/takeUntil';

import { Unsubscribe } from './class/unsubscribe.class';

import { Feature } from './class/feature.interface';

import { FeatureModelService } from './service/feature-model.service';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.css']
})
export class AppComponent extends Unsubscribe {
    @HostBinding('class.loading')
    private isLoading: boolean = true;

    public list: Array<Feature> = [];
    public locked: Array<number> = [];

    private _selected: Array<number> = [];

    public get selected(): Array<number> {
        return this._selected;
    }

    public set selected( val: Array<number> ) {
        this.isLoading = true;
        this.featureModelService.selectedFeatures = val;
    }

    constructor(private featureModelService: FeatureModelService ) {
        super();

        this.featureModelService.featureModel$
            .takeUntil(this.ngUnsubscribe)
            .subscribe( (featureModel: Array<Feature>) => {
                this.list = featureModel;
            });

        this.featureModelService.lockedFeatures$
            .takeUntil(this.ngUnsubscribe)
            .subscribe( (locked: Array<number>) => {
                console.log(locked);
                this.locked = locked;
            });

        this.featureModelService.selectedFeatures$
            .takeUntil(this.ngUnsubscribe)
            .subscribe( (selected: Array<number>) => {
                this._selected = selected;
                this.isLoading = false;
            })
    }

    public getCurrentValue( id: number ): number {
        if(this.locked.includes(id) || this._selected.includes(id)) return 1;
        if(this.locked.includes(-id) || this._selected.includes(-id)) return -1;
        return 0;
    }

    public isLocked( id: number ): boolean {
        return this.locked.includes(id) || this.locked.includes(-id) || this.isLoading;
    }

    public resetForm(): void {
        this.featureModelService.reset();
    }
}
