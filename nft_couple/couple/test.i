# Fluid properties
rho = 1.8
cp = 5195

# Operating conditions
u_inlet = 0.4
T_inlet = 742
p_outlet = 0

# Numerical scheme
advected_interp_method = 'average'
velocity_interp_method = 'rc'

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 0.00114
    ymin = 0
    ymax = 0.75
    nx = 16
    ny = 64
  []
[]

[GlobalParams]
  rhie_chow_user_object = 'rc'
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = vel_x
    v = vel_y
    pressure = pressure
  []
[]

[Variables]
  [vel_x]
    type = INSFVVelocityVariable
    initial_condition = ${u_inlet}
  []
  [vel_y]
    type = INSFVVelocityVariable
    initial_condition = 1e-12
  []
  [pressure]
    type = INSFVPressureVariable
  []
  [T_fluid]
    type = INSFVEnergyVariable
    initial_condition = ${T_inlet}
  []
[]

[AuxVariables]
  [./density_T]
    family = MONOMIAL
    order = FIRST
  [../]
  [./mu]
    family = MONOMIAL
    order = FIRST
  [../]
  [./k]
    family = MONOMIAL
    order = FIRST
  [../]
  [project_T]
  []
  [flux]
    order = FIRST
    family =  LAGRANGE
  []
  [p_flux]
  [../]
  [flux1]
    initial_condition = 2e4
  []
  [tf]
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho}
  []
  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_x
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = mu
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_y
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = mu
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
  []

  [energy_time]
    type = INSFVEnergyTimeDerivative
    variable = T_fluid
    rho = ${rho}
    dh_dt = dh_dt
  []
  [energy_advection]
    type = INSFVEnergyAdvection
    variable = T_fluid
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []
  [energy_diffusion]
    type = FVDiffusion
    variable = T_fluid
    coeff = k
  []
[]

[AuxKernels]
  [./compute_aux_density]
    type = ParsedAux
    variable = density_T
    coupled_variables = 'T_fluid'
    function = '48.14*30/T_fluid/(1+0.4446*30/T_fluid^1.2)'
  [../]
  [./compute_aux_mu]
    type = ParsedAux
    variable = mu
    coupled_variables = 'T_fluid'
    function = '3.674e-7*T_fluid^0.7'
  [../]
  [./compute_aux_k]
    type = ParsedAux
    variable = k
    coupled_variables = 'T_fluid'
    function = '2.682e-3*(1+1.123e-3*30)*T_fluid^(0.71*(1-2e-4*30))'
  [../]
  [copy_over]
    type = ProjectionAux
    v = T_fluid
    variable = project_T
  []
  [./positive_flux]
    type = ParsedAux
    variable = p_flux
    coupled_variables = flux
    function = 'flux'
  [../]
[]

[FVBCs]
  [inlet-u]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = vel_y
    function = inlet_v
  []
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = vel_x
    function = 0
  []

  [inlet-T]
    type = FVDirichletBC
    variable = T_fluid
    value = '${fparse T_inlet}'#'${fparse u_inlet * rho * cp * T_inlet}'
    boundary = 'bottom'
  []

  [T_left]
    type = FVFunctorNeumannBC
    variable = T_fluid
    boundary = 'left'
    functor = p_flux
    factor = k
  []

  [no-slip-u]
    type = INSFVNoSlipWallBC
    boundary = 'left'
    variable = vel_x
    function = 0
  []
  [no-slip-v]
    type = INSFVNoSlipWallBC
    boundary = 'left'
    variable = vel_y
    function = 0
  []

  [symmetry-u]
    type = INSFVSymmetryVelocityBC
    boundary = 'right'
    variable = vel_x
    u = vel_x
    v = vel_y
    mu = mu
    momentum_component = 'x'
  []
  [symmetry-v]
    type = INSFVSymmetryVelocityBC
    boundary = 'right'
    variable = vel_y
    u = vel_x
    v = vel_y
    mu = mu
    momentum_component = 'y'
  []
  [symmetry-p]
    type = INSFVSymmetryPressureBC
    boundary = 'right'
    variable = pressure
  []

  [outlet_u]
    type = INSFVMomentumAdvectionOutflowBC
    variable = vel_x
    u = vel_x
    v = vel_y
    boundary = 'top'
    momentum_component = 'x'
    rho = ${rho}
  []
  [outlet_v]
    type = INSFVMomentumAdvectionOutflowBC
    variable = vel_y
    u = vel_x
    v = vel_y
    boundary = 'top'
    momentum_component = 'y'
    rho = ${rho}
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'top'
    variable = pressure
    function = '${p_outlet}'
  []
[]

[FunctorMaterials]
  [functor_constants]
    type = ADGenericFunctorMaterial
    prop_names = 'cp'
    prop_values = '${cp}'
  []
  [ins_fv]
    type = INSFVEnthalpyFunctorMaterial
    rho = ${rho}
    temperature = 'T_fluid'
  []
[]


[Functions]
  [./inlet_v]
    type = ParsedFunction
    expression = '0.4'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'
  line_search = 'none'
  nl_rel_tol = 1e-8
#  dt = 0.1
  start_time = 0.0
  end_time = 1
[]

[Outputs]
  perf_graph = true
  print_linear_residuals = false
  time_step_interval = 1
  execute_on = 'initial timestep_end'
  [console]
    type = Console
    output_linear = false
  []
  [out]
    type = Exodus
    use_displaced = false
  []
[]
