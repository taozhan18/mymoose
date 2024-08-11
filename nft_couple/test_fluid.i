[GlobalParams]
  gravity = '0 0 0'
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 0.00114
  ymin = 0
  ymax = 0.75
  nx = 10
  ny = 64
  elem_type = QUAD4
[]

[Variables]
  # velocity
  [vel_x]
    initial_condition = 0
  []
  [vel_y]
    initial_condition = 1
  []
  [p]
    initial_condition = 3e6
  []
  [T]
    initial_condition = 742
  []
[]

[AuxVariables]
  [./density_T]
    family = MONOMIAL
    order = FIRST
  [../]
  [flux]
    initial_condition = 1e3
  []
[]

[Kernels]
  # mass
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    pressure = p
  [../]

  # x-momentum, time
  [./x_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
  [../]

  # x-momentum, space
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    pressure = p
    component = 0
  [../]

  # y-momentum, time
  [./y_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
  [../]

  # y-momentum, space
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    pressure = p
    component = 1
  [../]

 # temperature
 [./temperature_time]
   type = INSTemperatureTimeDerivative
   variable = T
 [../]

 [./temperature_space]
   type = INSTemperature
   variable = T
   u = vel_x
   v = vel_y
 [../]
[]

[AuxKernels]
  [./compute_aux_var]
    type = ParsedAux
    variable = density_T
    coupled_variables = 'T'
    function = '48.14*30/T/(1+0.4446*30/T^1.2)'
  [../]
[]

[Functions]
  # This demonstrates how to define fluid properties that are functions
  # of the LOCAL value of the (p,T) variables
  # x for temperature
  # y for pressure
  [k]
    type = ParsedFunction
    expression = '2.682e-3*(1+1.123e-3*y/1e6)*x^(0.71*(1-2e-4*y/1e6))'
  []
  [rho]
    type = ParsedFunction
    expression = '48.14*y/1e6/x/(1+0.4446*y/1e6/x^1.2)'
  []
  [mu]
    type = ParsedFunction
    expression = '3.674e-7*x^0.7'
  []
[]

[Materials]
  [./mu_f]
    type = ParsedMaterial
    coupled_variables = 'T'
    expression = '3.674e-7*T^0.7'
    outputs = out
    property_name = mu
  [../]
  [./k_f]
    type = ParsedMaterial
    coupled_variables = 'T'
    expression = '2.682e-3*(1+1.123e-3*30)*T^(0.71*(1-2e-4*30))'
    outputs = out
    property_name = k
  [../]
  [./const]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'cp rho'
    prop_values = '3116.0 1.75'
  [../]
[]

[BCs]
  # Outlet
  [./pressure_out]
    type = DirichletBC
    variable = p
    boundary = 'top'
    value = 3e6
  [../]

  # Inlet
  [vy_in]
    type = FunctionDirichletBC
    variable = vel_y
    boundary = 'bottom'
    function = 1
  []

  # no slip
  [vx_w]
    type = DirichletBC
    variable = vel_x
    boundary = 'left right bottom top'
    value = 0
  []
  [vy_w]
    type = DirichletBC
    variable = vel_y
    boundary = 'left right'
    value = 0
  []

  # BCs for energy equation
  [T_in]
    type = FunctionDirichletBC
    variable = T
    boundary = 'bottom'
    function = 742
  []
  [T_left]
    type = CoupledVarNeumannBC
    variable = T
    boundary = 'left'
    v = flux
  []
[]

[Preconditioning]
  [SMP_PJFNK]
    type = SMP
    full = true
    solve_type = 'PJFNK'
  []
[]

[Postprocessors]
  [p_in]
    type = SideAverageValue
    variable = p
    boundary = bottom
  []
  [p_out]
    type = SideAverageValue
    variable = p
    boundary = top
  []
  [T_in]
    type = SideAverageValue
    variable = T
    boundary = bottom
  []
  [T_out]
    type = SideAverageValue
    variable = T
    boundary = top
  []
[]

[Executioner]
  type = Transient

  dt = 1
  dtmin = 1.e-3

  petsc_options_iname = '-pc_type -ksp_gmres_restart'
  petsc_options_value = 'lu 100'

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-8
  nl_max_its = 20

  l_tol = 1e-5
  l_max_its = 100

  start_time = 0.0
  end_time = 10
  num_steps = 10
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
