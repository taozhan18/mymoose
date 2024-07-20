#include "workspaceApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
workspaceApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

workspaceApp::workspaceApp(InputParameters parameters) : MooseApp(parameters)
{
  workspaceApp::registerAll(_factory, _action_factory, _syntax);
}

workspaceApp::~workspaceApp() {}

void
workspaceApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<workspaceApp>(f, af, s);
  Registry::registerObjectsTo(f, {"workspaceApp"});
  Registry::registerActionsTo(af, {"workspaceApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
workspaceApp::registerApps()
{
  registerApp(workspaceApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
workspaceApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  workspaceApp::registerAll(f, af, s);
}
extern "C" void
workspaceApp__registerApps()
{
  workspaceApp::registerApps();
}
