extends Spatial

const needs = [ "root", "rand" ]
var nodes = Dictionary()

var bounseiness = 1			# bounce higher limit multiplier
var g = -9.8				# gravity
var spin = Vector3(1, 0, 0)	# Steve spin axis
var spin_speed = 0			# Steve spin speed
var tangent = 0 # tangent shift (instead of moving Steve, we move stairs)
var vel = 0					# Steve vertical velocity
var vel_tangent = 2			# Steve tangent velocity

var new_hit = true

func _process(delta):
	vel += -9.8 * delta
	tangent += delta * vel_tangent
	
	# move Steve
	transform.origin += Vector3(0, delta * vel, 0)
	# spin Steve
	$steve.rotate(spin, spin_speed * delta)
	
	# instead of moving Steve, we simulate
	# moving stairs continiously
	while tangent >= 2:
		tangent -= 2
	
	var dist = pow(transform.origin.y, 2) + pow(transform.origin.z, 2)
	
	dist -= pow(transform.origin.y + transform.origin.z, 2) / 2 # dot(r, n)^2/n^2
	dist = sqrt(dist)
	
	# handle "collisions"
	# projects Steve half-height on staricase normal to get effective collision distance
	var eff_dist = 1.7 * abs($steve.transform.basis.y.dot(Vector3(0, 1, -1))) / sqrt(2) + sqrt(2)
	if dist <= eff_dist:
		if new_hit:
			var random = nodes["rand"]
			new_hit = false
			vel = random.randf_range(10, bounseiness * 10)
			vel_tangent = random.randf_range(10, 20)
			spin_speed = random.randf_range(6, 12)
			spin.x = -random.randf_range(10, 100)
			spin.y = random.randf_range(0.01, 10)
			spin.z = random.randf_range(0.01, 10)
			spin = spin.normalized()
			
			nodes["root"].play_hit_sound()
	elif !new_hit:
		new_hit = true
