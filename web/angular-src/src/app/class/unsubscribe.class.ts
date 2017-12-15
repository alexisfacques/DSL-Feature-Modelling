import { OnDestroy } from '@angular/core';
import { Subject } from 'rxjs/Subject';

export class Unsubscribe implements OnDestroy {
    protected ngUnsubscribe: Subject<void> = new Subject<void>();

    constructor() {
    }

    public ngOnDestroy(): void {
        this.ngUnsubscribe.next();
        this.ngUnsubscribe.complete();
    }
}
