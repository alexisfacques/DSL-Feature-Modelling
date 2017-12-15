import { ControlValueAccessor } from '@angular/forms';
import { Unsubscribe } from '../class/unsubscribe.class';

export class ValueAccessorBase<T> extends Unsubscribe implements ControlValueAccessor {
    protected innerValue: T;
    protected changed = new Array<(value: T) => void>();
    protected touched = new Array<() => void>();

    constructor(){
        super();
    }

    public get value(): T {
        return this.innerValue;
    }

    public set value(value: T) {
        if (this.innerValue !== value) {
            this.innerValue = value;
            this.changed.forEach(f => f(value));
        }
    }

    public touch(): void {
        this.touched.forEach(f => f());
    }

    public writeValue( value: T ): void {
        this.innerValue = value;
    }

    public registerOnChange(fn: ( value: T ) => void): void {
        this.changed.push(fn);
    }

    public registerOnTouched(fn: () => void): void {
        this.touched.push(fn);
    }
}
