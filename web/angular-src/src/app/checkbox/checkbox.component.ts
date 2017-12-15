import { Component, Input, HostListener, HostBinding, Output, EventEmitter } from '@angular/core';
import { NG_VALUE_ACCESSOR } from '@angular/forms';

import { ValueAccessorBase } from '../class/value-accessor-base.class';

@Component({
    selector: 'checkbox',
    templateUrl: './checkbox.component.html',
    styleUrls: ['./checkbox.component.css'],
    providers: [ { provide: NG_VALUE_ACCESSOR, useExisting: CheckboxComponent, multi: true } ]
})
export class CheckboxComponent extends ValueAccessorBase<number> {
    private i: number = 1;

    @Input()
    public identifier: number = 1;

    @Input()
    @HostBinding('class.disabled')
    private isLocked: boolean = false;

    @HostListener('click')
    private onClick( event: Event ): void {
        if(this.isLocked) return;

        this.i++;
        this.value = this.i % 3 - 1;
        this.changes.emit(this.identifier * this.value);
    }

    @HostBinding('class.is-selected')
    public get isSelected(): Boolean {
        return this.value == 1;
    }

    @HostBinding('class.is-deselected')
    public get isDeselected(): Boolean {
        return this.value == -1;
    }

    @Output()
    public changes: EventEmitter<number> = new EventEmitter<number>();

    public get data(): number {
        if(this.value) return this.identifier * this.value;
        return 0;
    }

    constructor() {
        super();
    }
}
