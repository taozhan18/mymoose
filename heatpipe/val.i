[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = FileMesh
  file = val_mesh.e  # 替换为你的网格文件
[]

[Variables]
  [T]
    initial_condition = 948
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
    block = 'matrix'
  [../]
  [./elasticity_tensor_matrix]
    type = ComputeVariableIsotropicElasticityTensor
    args = T
    youngs_modulus = youngs_modulus_matrix
    poissons_ratio = 0.21
    block = 'matrix'
  [../]

  [thermal_matrix]
    type = HeatConductionMaterial
    temp = T
    thermal_conductivity_temperature_function = thermal_conductivity_function_matrix
    use_displaced_mesh = true
    block = 'matrix'
  []

  [./thermal_expansion_matrix]
    type = ComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = cte_func_mean_matrix
    thermal_expansion_function_reference_temperature = 293
    stress_free_temperature = 0.0
    temperature = T
    eigenstrain_name = eigenstrain
    block = 'matrix'
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
    boundary = left
    value = 0.0
  [../]
  [./bottom_symmetry]
    type = NeumannBC
    variable = T
    boundary = bottom
    value = 0.0
  [../]
  [./flux]
    type = NeumannBC
    variable = T
    boundary = 'matrixin_b'
    value = 5e5  # 这里设置你的热通量值，可以是常数或函数
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
  [./InclinedNoDisplacementBC]
    [./left]
      boundary = left
      penalty = 1e15
      displacements = "disp_x disp_y"
    [../]
    [./bottom]
      boundary = bottom
      penalty = 1e15
      displacements = "disp_x disp_y"
    [../]
  [../]
  [fix_bc_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
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
  #end_time = 5
  #dt = 1
[]

[Outputs]
  exodus = true
[]
