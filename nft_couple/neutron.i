v = 2.416

[Mesh]
  type = FileMesh
  file = nft.e  # 替换为你的网格文件
[]


[Variables]
  [u]
  []
[]


[Kernels]
  [td]
    type = CoefTimeDerivative
    variable = u
    Coefficient = '${fparse 1 / v}'#
  []
  [diff_fuel]
    type = FunctionDiffusion
    variable = u
    function = 0.008249
    block = 'fuel'
  []
  [diff_fluid]
    type = FunctionDiffusion
    variable = u
    function = 0.01
    block = 'fluid'
  []
  [reaction_fuel]
    type = FunctionReaction
    variable = u
    function = 118.85827
    block = 'fuel'
  []
  [reaction_fluid]
    type = FunctionReaction
    variable = u
    function = -5.78
    block = 'fluid'
  []
[]

[Functions]
  [./phi_source]
    type = ParsedFunction
    expression = '(t+5)*cos(3.14*(y-0.375)/0.75)'
  [../]
  [./UIC]
    type = ParsedFunction
    expression = '2*cos(3.14*(y-0.375)/0.75)'
  [../]
[]

[BCs]
  [./left_symmetry]
    type = FunctionDirichletBC
    variable = u
    boundary = 'left'
    function = phi_source
  [../]

  [./right_symmetry]
    type = NeumannBC
    variable = u
    boundary = 'right'
    value = 0.0
  [../]

  [./top]
    type = DirichletBC
    variable = u
    value = 0
    boundary = top
  [../]

  [./bottom]
    type = DirichletBC
    variable = u
    value = 0
    boundary = bottom
  [../]
[]

[ICs]
  [u_ic]
    type = FunctionIC
    variable = 'u'
    function = UIC
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 5
  #dt = 0.1
  #nl_rel_tol = 1e-8
[]

[Outputs]
  [./csv]
    type = CSV
    show = u
    [../]
[]
