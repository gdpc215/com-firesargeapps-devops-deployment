import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AppComponent } from './app.component';
import { CatalogRoutes as routectlg } from './app.routes.catalog';

const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: routectlg.HOME },

  { path: routectlg.HOME, component: AppComponent, title: 'Home' },

  // Nested route example
  // {
  //   path: routectlg._route_,
  //   component: FrameComponent,
  //   children: [
  //     { path: '', component: _Component_, title: 'Title' }
  //   ]
  // },

  // Module route example
  // {
  //   path: routectlg._subcatalog_.BASE,
  //   component: FrameComponent,
  //   loadChildren: () => import('../features/_module_/_module_.module').then(m => m._module_Module),
  //   title: 'Title'
  // },

  // Error
  // {
  //   path: 'error',
  //   component: ErrorComponent,
  //   title: 'Error'
  // },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutesModule { }