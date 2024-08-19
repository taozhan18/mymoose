[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 0.0076
  ymin = 0
  ymax = 0.75
  nx = 8
  ny = 64
  elem_type = QUAD4
[]

[Variables]
  [./dummy]
  [../]
[]
[Kernels]
  [./dummy_kernel]
    type = TimeDerivative
    variable = dummy
  [../]
[]
[AuxVariables]
  [T_fluid]
    initial_condition = 560
  []
  [./power]
  [../]
[]

[AuxKernels]
  [T_fluid]
    type = FunctorAux
    functor = Ty
    variable = T_fluid
    # execute_on = INITIAL
  []
  [aux_power]
    type = FunctionAux
    function = powerxy
    variable = power
    # execute_on = INITIAL
  []
[]



[Functions]
  [./Ty]
    type = PiecewiseMultilinear
    data_file = T_fluid.txt
  [../]
  [./powerxy]
    type = PiecewiseMultilinear
    data_file = phi.txt
  [../]
[]

[Executioner]
  type = Transient
  start_time = 0.0
  end_time = 5
  # num_steps = 32
[]

[Outputs]
  [exodus]
    type = Exodus
    sync_only = true
    sync_times = '0. 0.3125 0.625 0.9375 1.25 1.5625 1.875 2.1875 2.5 2.8125 3.125 3.4375 3.75 4.0625 4.375 4.6875 5.'
  []
[]
