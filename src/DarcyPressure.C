#include "DarcyPressure.h"

registerMooseObject("workspaceApp", DarcyPressure);
// 分表对头文件定义的三个函数进行描述
// ::表示访问类里面的函数，前面加的表示返回变量类型，如下面的返回 InputParameters
InputParameters
DarcyPressure::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription("Compute the diffusion term for Darcy pressure ($p$) equation: "
                             "$-\\nabla \\cdot \\frac{\\mathbf{K}}{\\mu} \\nabla p = 0$");
  // Add a required parameter. If this isn't provided in the input file MOOSE will error.
  params.addRequiredParam<Real>("permeability", "The isotropic permeability ($K$) of the medium.");

  // Add an optional parameter and set its default value.
  params.addParam<Real>(
      "viscosity",
      7.98e-04,
      "The dynamic viscosity ($\\mu$) of the fluid, the default value is that of water at 30 "
      "degrees Celcius (7.98e-04 Pa-s).");
  return params;
}
//访问构造函数,:表示依次对参数初始化，传入的是validParams()返回的参数。何时调用的这个函数？ADKernelGrad(parameters)头文件有定义这个？
DarcyPressure::DarcyPressure(const InputParameters & parameters)
  : ADKernelGrad(parameters),

    // Get the parameters from the input file
    // 检索用户定义输入的基本方法是模板getParam（）方法
    // The getParam() method can be called from within any member—not just the constructor.
    _permeability(getParam<Real>("permeability")),
    _viscosity(getParam<Real>("viscosity"))
      // check that viscosity value is not zero
{
    if (_viscosity == 0)
    paramError("viscosity", "The viscosity must be a non-zero real number.");
}
// _qp：当前积分点，_grad_u：梯度
// 访问测试函数梯度的函数
ADRealVectorValue
DarcyPressure::precomputeQpResidual()
{
  return (_permeability / _viscosity) * _grad_u[_qp];
}
