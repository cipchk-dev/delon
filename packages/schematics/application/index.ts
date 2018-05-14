import {
  Rule,
  Tree,
  SchematicContext,
  chain,
  noop,
} from '@angular-devkit/schematics';
import { NodePackageInstallTask } from '@angular-devkit/schematics/tasks';
import { addPackageToPackageJson } from '../utils/package';
import { VERSION, ZORROVERSION } from '../utils/lib-versions';
import { Schema as ApplicationOptions } from './schema';

function addDependenciesToPackageJson() {
  return (host: Tree, context: SchematicContext) => {
    addPackageToPackageJson(
      host,
      'dependencies',
      'ng-zorro-antd',
      ZORROVERSION,
    );
    addPackageToPackageJson(host, 'dependencies', '@delon/abc', VERSION);
    addPackageToPackageJson(host, 'dependencies', '@delon/acl', VERSION);
    addPackageToPackageJson(host, 'dependencies', '@delon/auth', VERSION);
    addPackageToPackageJson(host, 'dependencies', '@delon/cache', VERSION);
    addPackageToPackageJson(host, 'dependencies', '@delon/form', VERSION);
    addPackageToPackageJson(host, 'dependencies', '@delon/mock', VERSION);
    addPackageToPackageJson(host, 'dependencies', '@delon/theme', VERSION);
    addPackageToPackageJson(host, 'dependencies', '@delon/util', VERSION);
    context.addTask(new NodePackageInstallTask());
    return host;
  };
}

export default function(options: ApplicationOptions): Rule {
  return chain([
    options && options.skipPackageJson ? noop() : addDependenciesToPackageJson(),
  ]);
}
