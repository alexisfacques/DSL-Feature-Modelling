import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { HttpModule } from '@angular/http';

import { AppComponent } from './app.component';
import { CheckboxComponent } from './checkbox/checkbox.component';

import { CheckboxGroupDirective } from './directive/checkbox-group.directive';

import { FeatureModelService } from './service/feature-model.service';

@NgModule({
    declarations: [
        AppComponent,
        CheckboxComponent,
        CheckboxGroupDirective
    ],
    imports: [
        FormsModule,
        BrowserModule,
        HttpModule
    ],
    providers: [
        FeatureModelService
    ],
    bootstrap: [
        AppComponent
    ]
})
export class AppModule {

}
