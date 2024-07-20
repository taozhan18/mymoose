//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "workspaceTestApp.h"
#include "workspaceApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
workspaceTestApp::validParams()
{
  InputParameters params = workspaceApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

workspaceTestApp::workspaceTestApp(InputParameters parameters) : MooseApp(parameters)
{
  workspaceTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

workspaceTestApp::~workspaceTestApp() {}

void
workspaceTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  workspaceApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"workspaceTestApp"});
    Registry::registerActionsTo(af, {"workspaceTestApp"});
  }
}

void
workspaceTestApp::registerApps()
{
  registerApp(workspaceApp);
  registerApp(workspaceTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
workspaceTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  workspaceTestApp::registerAll(f, af, s);
}
extern "C" void
workspaceTestApp__registerApps()
{
  workspaceTestApp::registerApps();
}
