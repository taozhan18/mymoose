//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FunctionReaction.h"
#include "Function.h"

registerMooseObject("workspaceApp", FunctionReaction);

InputParameters
FunctionReaction::validParams()
{
  InputParameters params = Reaction::validParams();
  params.addClassDescription("Reaction with a function coefficient.");
  params.addParam<FunctionName>("function", 1.0, "Function multiplier for Reaction term.");
  return params;
}

FunctionReaction::FunctionReaction(const InputParameters & parameters)
  : Reaction(parameters),
    _function(getFunction("function"))
{
}

Real
FunctionReaction::computeQpResidual()
{
  return _function.value(_t, _q_point[_qp]) * _u[_qp] ;
}

Real
FunctionReaction::computeQpJacobian()
{
  return _function.value(_t, _q_point[_qp]) * _phi[_j][_qp];
}
