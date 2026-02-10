local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.aws_load_balancer_controller;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('aws-load-balancer-controller', params.namespace);

local appPath =
  local project = std.get(std.get(app, 'spec', {}), 'project', 'syn');
  if project == 'syn' then 'apps' else 'apps-%s' % project;

{
  ['%s/aws-load-balancer-controller' % appPath]: app,
}
