local com = import 'lib/commodore.libjsonnet';

local chart_output_dir = std.extVar('output_path');

local list_dir(dir, basename=true) =
  std.native('list_dir')(dir, basename);

local chart_files = list_dir(chart_output_dir);

local input_file(elem) = chart_output_dir + '/' + elem;
local stem(elem) =
  local elems = std.split(elem, '.');
  std.join('.', elems[:std.length(elems) - 1]);

local patch_obj(obj) =
  if std.get(obj, 'kind', null) == 'CustomResourceDefinition' then
    obj {
      metadata+: {
        annotations+: {
          // Ensures CRDs can be applied safely by ArgoCD without client-side
          // apply conflicts.
          'argocd.argoproj.io/sync-options': 'ServerSideApply=true',
        },
      },
    }
  else
    null;

local fixup(obj_file) =
  local objs = std.prune(com.yaml_load_all(obj_file));
  std.filter(function(it) it != null, [ patch_obj(obj) for obj in objs ]);

{
  [stem(elem)]: fixup(input_file(elem))
  for elem in chart_files
}
