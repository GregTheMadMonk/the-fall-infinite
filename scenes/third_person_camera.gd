extends Spatial

export (float) var distance = 10
export (float) var base_sensitivity = 0.005
export (float) var sensitivity = 1

export (bool) var locked = true

const needs = [ "env" ]
var nodes = Dictionary()

func _ready():
	$camera_pitch/viewport.transform.origin.x = -distance

func move(vector):
	if locked: return
	# moves camera based on sensitivity and input vector
	rotate_y(-vector.x * base_sensitivity * sensitivity)
	$camera_pitch.rotate_z(vector.y * base_sensitivity * sensitivity)

func zoom(factor):
	if locked: return
	$camera_pitch/viewport.transform.origin.x *= factor
	nodes["env"].environment.dof_blur_far_distance = abs($camera_pitch/viewport.transform.origin.x) + 10

func toggle_lock():
	locked = !locked
