phi_in = %(phi_in)s
sigma_af_fuel = %(sigma_af_fuel)s
sigma_af_fluid = %(sigma_af_fluid)s
v = 2.416

[Mesh]
  type = FileMesh
  file = nft.e
[]


[Variables]
  [u]
  []
[]

#[AuxVariables]
#  [./T_fuel]
#    block = fuel
#  [../]
#  [./T_fluid]
#    block = fluid
#  [../]
#  [./rho_fluid]
#    block = fluid
#  [../]
#[]

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
  # [source]
  #   type = BodyForce
  #   variable = u
  #   function = phi_source
  #   block = fuel
  #   value = 1e6
  # []
[]

#[AuxKernels]
  #[./compute_aux_T_fuel]
  #  type = FunctionAux
  #  variable = T_fuel
  #  function = f_T_fuel
  #  execute_on = INITIAL
  #[../]
  #[./compute_aux_T_fluid]
  #  type = FunctionAux
  #  variable = T_fluid
  #  function = f_T_fuel
  #  execute_on = INITIAL
  #[../]
  #[./compute_aux_density]
  #  type = ParsedAux
  #  variable = rho_fluid
  #  coupled_variables = 'T_fluid'
  #  expression = '48.14*30/T_fluid/(1+0.4446*30/T_fluid^1.2)'
  #[../]
#[]

[Materials]
  [compute_Dfluid]
    type = GenericConstantMaterial
    prop_names = 'D_fluid'
    prop_values = 0.01
    block = 'fluid'
  []
  [compute_Dfuel]
    type = GenericConstantMaterial
    prop_names = 'D_fuel'
    prop_values = 0.008249
    block = 'fuel'
  []
  [./compute_sigma_af_fuel]
    type = GenericFunctionMaterial
    prop_names = 'sigma_af_fuel'
    prop_values = f_sigma_af_fuel
    block = 'fuel'
  [../]
  [./compute_aux_sigma_af_fluid]
    type = GenericFunctionMaterial
    prop_names = 'sigma_af_fluid'
    prop_values = f_sigma_af_fluid
    block = 'fluid'
  [../]
[]

[Functions]
  [./U_IC]
    type = ParsedFunction
    expression = '2*cos(3.14*(y-0.375)/0.75)'
  [../]
  [./phi_BC]
    type = PiecewiseMultilinear
    data_file = ${phi_in}
  [../]
  [./f_sigma_af_fuel]
    type = PiecewiseMultilinear
    data_file = ${sigma_af_fuel}
  [../]
  [./f_sigma_af_fluid]
    type = PiecewiseMultilinear
    data_file = ${sigma_af_fluid}
  [../]
[]

[BCs]
  [./left]
    type = FunctionDirichletBC
    variable = u
    boundary = 'left'
    function = phi_BC
  [../]

  [./right]
    type = DirichletBC
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
    function = U_IC
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 5
  num_steps = 32
  #dt = 0.1
[]

[Outputs]
  exodus = true
[]
