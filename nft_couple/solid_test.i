[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 0.0076
  ymin = 0
  ymax = 0.75
  nx = 10
  ny = 64
  elem_type = QUAD4
[]

[Variables]
  [T]
    initial_condition = 742
  []
[]


[AuxVariables]
  [flux]
      order = FIRST
      family = MONOMIAL
  [../]
[]


[AuxKernels]
  [flux_x]
    type = DiffusionFluxAux
    diffusivity = 'thermal_conductivity'
    variable = flux
    diffusion_variable = T
    component = x
    boundary = right
  []
[]


[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [./time_diff_m]
    type = HeatConductionTimeDerivative
    variable = T
  [../]
  [source]
    type = HeatSource
    variable = T
    function = 1e7
  []
[]


[BCs]
  [./left_symmetry]
    type = NeumannBC
    variable = T
    boundary = 'left'
    value = 0.0
  [../]

  [./right]
    type = FunctorDirichletBC
    variable = T
    boundary = 'right'
    functor = Tz
  []
[]

[Materials]
  [thermal_cond]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '16020'
  []
  [thermal_matrix]
    type = HeatConductionMaterial
    temp = T
    thermal_conductivity_temperature_function = thermal_conductivity
    specific_heat_temperature_function = specific_heat
  []
[]

[Functions]
  [./specific_heat]
    type = ParsedFunction
    expression = '(1.359+0.05812*t+1.086*1e6/t/t)*5'
  [../]
  [./thermal_conductivity]
    type = ParsedFunction
    expression = '17.5*(1-0.223)/(1+0.161)+1.54e-2*(1+0.0061)/(1+0.161)*t+9.38e-6*t*t'  # 热导率随温度变化的函数
  [../]
  [./Tz]
    type = PiecewiseLinear
    axis = y
    x = '0 0.75'
    y = '742 800'
  [../]
[]

[Executioner]
  type = Transient

  dt = 0.1
  dtmin = 1.e-3

  petsc_options_iname = '-pc_type -ksp_gmres_restart'
  petsc_options_value = 'lu 100'

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-8
  nl_max_its = 20

  l_tol = 1e-5
  l_max_its = 100

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
