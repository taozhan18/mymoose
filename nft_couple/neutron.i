[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  nx = 20
  ny = 20
[]

[Variables]
  [./phi]
    initial_condition = 0.0
  [../]
  [./T]
    family = LAGRANGE
    order = FIRST
  [../]
[]

[Kernels]
  [./time_derivative]
    type = TimeDerivative
    variable = phi
    factor = 1/v
  [../]

  [./diffusion]
    type = Diffusion
    variable = phi
  [../]

  [./source]
    type = Function
    variable = phi
    function = source_function
  [../]

  [./reaction]
    type = ParsedAux
    variable = phi
    v = 'a_T*T*phi'
    deps = 'T phi'
  [../]
[]


[AuxVariables]
  [./a_T]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./aT_kernel]
    type = ParsedAux
    variable = a_T
    v = 'a(T)'
    deps = 'T'
  [../]
[]

[ICs]
  [./phi_ic]
    type = FunctionIC
    variable = phi
    function = initial_phi
  [../]
[]

[Functions]
  [./source_function]
    type = ParsedFunction
    value = 'x'
  [../]
  [./initial_phi]
    type = ParsedFunction
    value = 'initial_phi_expression' # 例如，初始条件为 0 或某函数表达式
  [../]

  [./T_function]
    type = ParsedFunction
    value = 'x' # 例如，T = f(x,y)
  [../]
[]

[BCs]
  [./left]
    type = DirichletBC
    variable = phi
    boundary = left
    value = 0
  [../]
  [./right]
    type = DirichletBC
    variable = phi
    boundary = right
    value = 0
  [../]
  [./top]
    type = DirichletBC
    variable = phi
    boundary = top
    value = 0
  [../]
  [./bottom]
    type = DirichletBC
    variable = phi
    boundary = bottom
    value = 0
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  dt = 0.01
  end_time = 1.0
[]

[Outputs]
  exodus = true
[]

