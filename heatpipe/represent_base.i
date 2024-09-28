[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = FileMesh
  file = represent_mesh1.e  # 替换为你的网格文件
[]

[Variables]
  [T]
    initial_condition = 948
  []
[]
[AuxVariables]
  [flux_BC]
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
    use_displaced_mesh = true
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    add_variables = true
    strain = FINITE
    automatic_eigenstrain_names = true
    planar_formulation = PLANE_STRAIN
    generate_output = 'vonmises_stress strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz'
  []
[]

[Materials]
  [./youngs_modulus_matrix]
    type = ParsedMaterial
    property_name = youngs_modulus_matrix
    coupled_variables = 'T'
    expression = '(211600-51.73*(T-273)-0.01928*(T-273)*(T-273))*1E6'
    outputs = exodus
    block = '101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116'
  [../]
  [./elasticity_tensor_matrix]
    type = ComputeVariableIsotropicElasticityTensor
    args = T
    youngs_modulus = youngs_modulus_matrix
    poissons_ratio = 0.21
    block = '101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116'
  [../]

  [thermal_matrix]
    type = HeatConductionMaterial
    temp = T
    thermal_conductivity_temperature_function = thermal_conductivity_function_matrix
    use_displaced_mesh = true
    block = '101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116'
  []

  [./thermal_expansion_matrix]
    type = ComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = cte_func_mean_matrix
    thermal_expansion_function_reference_temperature = 293
    stress_free_temperature = 0.0
    temperature = T
    eigenstrain_name = eigenstrain
    block = '101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116'
  [../]
  [stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[Functions]
  [./cte_func_mean_matrix]
    type = ParsedFunction
    expression = 'if(t>1273,5e-6,1e-6*(-1.8276+0.0178*t-1.5544e-5*t*t+4.5246e-9*t*t*t))'
  [../]
  [./thermal_conductivity_function_matrix]
    type = ParsedFunction
    expression = '9.2+0.0175*(t-273)-2e-6*(t-273)*(t-273)'  # 热导率随温度变化的函数
  [../]
%(fix_b)s
[]

[BCs]
  [heatpipe]
    type = DirichletBC
    variable = T
    value = 948
    boundary = heatpipe
  []
  [./left_symmetry]
    type = NeumannBC
    variable = T
    boundary = 'left'
    value = 0.0
  [../]
  [./bottom_symmetry]
    type = NeumannBC
    variable = T
    boundary = 'bottom'
    value = 0.0
  [../]
  [./flux]
    type = FunctorNeumannBC#NeumannBC
    variable = T
    boundary = 'matrixin_b'
    functor = flux_BC # 这里设置你的热通量值，可以是常数或函数
  [../]
  [./Pressure]
    [./inter]
      boundary = 'matrixin_b'
      factor = 1
      #variable = disp_x
      displacements = "disp_x disp_y"
      function = 2e6
    [../]
  [../]
%(bc_1)s
%(bc_2)s
%(bc_3)s
[]

[ICs]
  [./ic_flux_1]
    type = ConstantIC
    variable = flux_BC
    value = %(b1)s
    block = '101'
  [../]
  [./ic_flux_2]
    type = ConstantIC
    variable = flux_BC
    value = %(b2)s
    block = '102'
  [../]
  [./ic_flux_3]
    type = ConstantIC
    variable = flux_BC
    value = %(b3)s
    block = '103'
  [../]
  [./ic_flux_4]
    type = ConstantIC
    variable = flux_BC
    value = %(b4)s
    block = '104'
  [../]
  [./ic_flux_5]
    type = ConstantIC
    variable = flux_BC
    value = %(b5)s
    block = '105'
  [../]
  [./ic_flux_6]
    type = ConstantIC
    variable = flux_BC
    value = %(b6)s
    block = '106'
  [../]
  [./ic_flux_7]
    type = ConstantIC
    variable = flux_BC
    value = %(b7)s
    block = '107'
  [../]
  [./ic_flux_8]
    type = ConstantIC
    variable = flux_BC
    value = %(b8)s
    block = '108'
  [../]
  [./ic_flux_9]
    type = ConstantIC
    variable = flux_BC
    value = %(b9)s
    block = '109'
  [../]
  [./ic_flux_10]
    type = ConstantIC
    variable = flux_BC
    value = %(b10)s
    block = '110'
  [../]
  [./ic_flux_11]
    type = ConstantIC
    variable = flux_BC
    value = %(b11)s
    block = '111'
  [../]
  [./ic_flux_12]
    type = ConstantIC
    variable = flux_BC
    value = %(b12)s
    block = '112'
  [../]
  [./ic_flux_13]
    type = ConstantIC
    variable = flux_BC
    value = %(b13)s
    block = '113'
  [../]
  [./ic_flux_14]
    type = ConstantIC
    variable = flux_BC
    value = %(b14)s
    block = '114'
  [../]
  [./ic_flux_15]
    type = ConstantIC
    variable = flux_BC
    value = %(b15)s
    block = '115'
  [../]
  [./ic_flux_16]
    type = ConstantIC
    variable = flux_BC
    value = %(b16)s
    block = '116'
  [../]
  [./ic_disp_x]
      type = FunctionIC
      variable = 'disp_x'
      function = %(disp_x_ic)s
  [../]
  [./ic_disp_y]
      type = FunctionIC
      variable = 'disp_y'
      function = %(disp_y_ic)s
  [../]
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_max_its = 20
  nl_max_its = 5
  #end_time = 5
  #dt = 1
[]

[Outputs]
  [exodus]
    type = Exodus
    elemental_as_nodal = true
  []
[]
