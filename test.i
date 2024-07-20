#
# Multiple submesh setup with two cantilevers side by side
# https://mooseframework.inl.gov/modules/solid_mechanics/tutorials/introduction/step04.html
#

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [igafile]
    type = FileMeshGenerator
    file = test.e
    clear_spline_nodes = true
  []
[]
[Variables]
  [disp_x]
    order = SECOND
    family = RATIONAL_BERNSTEIN
  []
  [disp_y]
    order = SECOND
    family = RATIONAL_BERNSTEIN
  []
[]

[Kernels]
  [SolidMechanics]
#Stress divergence kernels
    displacements = 'disp_x disp_y disp_z'
   []
[]

[BCs]
  [bottom_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'pillar1_bottom pillar2_bottom'
    value = 0
  []
  [bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'pillar1_bottom pillar2_bottom'
    value = 0
  []
  [Pressure]
    [sides]
      boundary = 'pillar1_left pillar2_right'
      function = 1e4*t
    []
  []
[]

[Materials]
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e9
    poissons_ratio = 0.3
  []
  # we anticipate large deformation
  [stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  line_search = none
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = 5
  dt = 0.5
  [Predictor]
    type = SimplePredictor
    scale = 1
  []
[]

[Outputs]
  exodus = true
[]
