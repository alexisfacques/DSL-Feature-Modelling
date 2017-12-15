import {
    AfterContentInit,
    ContentChildren,
    Directive,
    OnDestroy,
    QueryList,
    Input
} from '@angular/core';

import { NG_VALUE_ACCESSOR } from '@angular/forms';

import { Subject } from 'rxjs/Subject';

import { ValueAccessorBase } from '../class/value-accessor-base.class';

import { CheckboxComponent } from '../checkbox/checkbox.component';

@Directive({
    selector: '[checkbox-group]',
    host: {
        'role': 'checkboxgroup'
    },
    providers: [ { provide: NG_VALUE_ACCESSOR, useExisting: CheckboxGroupDirective, multi: true } ],
})
export class CheckboxGroupDirective extends ValueAccessorBase<Array<any>> implements AfterContentInit, OnDestroy {
    private itemUnsubscribe: Subject<void> = new Subject<void>();

    @ContentChildren(CheckboxComponent, {descendants: true})
    private checkboxes: QueryList<CheckboxComponent>;

    private _timeout: any;

    constructor() {
        super();
    }

    public ngAfterContentInit(): void {
        this.subscribe();
        this.checkboxes.changes
            .takeUntil(this.ngUnsubscribe)
            .subscribe( () => {
                this.subscribe();
            });
    }

    private subscribe(): void {
        if(!this.checkboxes) return;
        this.itemUnsubscribe.next();

        this.checkboxes.forEach( (checkbox: CheckboxComponent) => {
            checkbox.changes
                .takeUntil(this.itemUnsubscribe)
                .subscribe( (value: number) => {
                    this.value = this.value.filter( (number: number) => Math.abs(number) != checkbox.identifier && number != 0 );
                    this.value.push(value);

                    this.value = this.value.splice(0);
                    this.subscribe();
                });
        });
    }

    public ngOnDestroy(): void {
        super.ngOnDestroy();
        this.itemUnsubscribe.next();
        this.itemUnsubscribe.complete();
    }
}
