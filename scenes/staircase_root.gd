extends Spatial

export var dim = 50	# how many stairs to create to each side
export var depth = 3	# how deep is the staircase

func construct():
	# initialize staircase for le epic fall
	put_step(0, 0)
	for i in range(1, dim + 1):
		put_step(i, -i)
		put_step(-i, i)

func put_step(x, y):
	# create one stair block
	for j in range(depth):
		var z = -1 + j
		var stairs = MeshInstance.new()
		stairs.mesh = load("res://assets/models/stairs.obj")
		stairs.transform.origin = Vector3(z * 2, y * 2, -x * 2)
		add_child(stairs)

func set_stairs_material(material):
	for stair in get_children():
		stair.set_surface_material(0, material)
