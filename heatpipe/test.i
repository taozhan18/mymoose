#
# Single block coupled thermal/mechanical
# https://mooseframework.inl.gov/modules/combined/tutorials/introduction/thermoech_step01.html
#

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmax = 2
    ymax = 1
  []
  [pin]
    type = ExtraNodesetGenerator
    input = generated
    new_boundary = pin
    coord = '0 0 0'
  []
[]

[Variables]
  [T]
    initial_condition = 300.0
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
    use_displaced_mesh = true
  []
  [heat_source]
    type = HeatSource
    variable = T
    value = 5e4
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    add_variables = true
    strain = FINITE
    #scalar_out_of_plane_strain = scalar_strain_zz
    automatic_eigenstrain_names = true
    planar_formulation = PLANE_STRAIN
    generate_output = 'vonmises_stress strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz'
  []
[]

[Materials]
  [./youngs_modulus]
    type = ParsedMaterial
    property_name = youngs_modulus
    coupled_variables = 'T'
    expression = '2.116E8-53.73*1e3*T-0.01928*1e3*T*T'
    outputs = exodus
  [../]
  [thermal]
    type = HeatConductionMaterial
    temp = T
    #thermal_conductivity=0.1
    thermal_conductivity_temperature_function = thermal_conductivity_function
    use_displaced_mesh = true
  []
  [./elasticity_tensor]
    type = ComputeVariableIsotropicElasticityTensor
    args = T
    youngs_modulus = youngs_modulus
    poissons_ratio = 0.21
  [../]
  [./thermal_expansion_strain]
    type = ComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = cte_func_mean
    thermal_expansion_function_reference_temperature = 293
    stress_free_temperature = 0.0
    temperature = T
    eigenstrain_name = eigenstrain
  [../]
  [stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[Functions]
  [./cte_func_mean]
    type = ParsedFunction
    expression = '7e-6+5e-9*t+3.42e-13*t*t'
  [../]
  [./thermal_conductivity_function]
    type = ParsedFunction
    value = '45'  # 热导率随温度变化的函数
  [../]
[]

[BCs]
  [t_left]
    type = DirichletBC
    variable = T
    value = 300
    boundary = 'left'
  []
  [t_right]
    type = DirichletBC
    variable = T
    value = 400
    boundary = 'right'
  []
  [pin_x]
    type = DirichletBC
    variable = disp_x
    boundary = pin
    value = 0
  []
  [bottom_y]
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
