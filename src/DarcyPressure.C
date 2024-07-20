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

  return params;
}
//访问构造函数,:表示依次对参数初始化
DarcyPressure::DarcyPressure(const InputParameters & parameters)
  : ADKernelGrad(parameters),

    // Set the coefficients for the pressure kernel
    _permeability(0.8451e-09),
    _viscosity(7.98e-04)
{
}
// _qp：当前积分点，_grad_u：梯度
ADRealVectorValue
DarcyPressure::precomputeQpResidual()
{
  return (_permeability / _viscosity) * _grad_u[_qp];
}
