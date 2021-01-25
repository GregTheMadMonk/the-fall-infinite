# THE FALL
# "Simulation" (simulation of a simulation)
# Inspired by https://www.youtube.com/watch?v=SrPApgp-aa4

extends Spatial

const dim = 50 # how many stairs to create to each side
const depth = 3 # how deep is the staircase
var vel = 0 # Steve vertical velocity
var vel_tangent = 2 # Steve tangent velocity
var tangent = 0 # stairs shift
var spin = Vector3(1, 0, 0) # Steve spin axis
var spin_speed = 0 # Steve spin speed
var random # RNG
var base_sensitivity = 0.005
var sensitivity = 1

var bounseiness = 1 # bounce higher limit multiplier

var viewport_locked = true
var sounds_enabled = true

var sounds = []

func _ready():
	# initialize RNG
	random = RandomNumberGenerator.new()
	random.randomize()
	
	# load sounds
	var audio = Directory.new()
	audio.open("res://assets/audio")
	audio.list_dir_begin()
	while true:
		var sound = audio.get_next()
		if sound == "":
			break
		elif (sound.find(".import") != -1) and (sound.find(".") != 0):
			print("loading sound: " + sound)
			sounds.append(load("res://assets/audio/" + sound.replace(".import", "")))
	
	audio.list_dir_end()
	
	# initialize staircase for le epic fall
	put_step(0, 0)
	for i in range(1, dim + 1):
		put_step(i, -i)
		put_step(-i, i)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$player_root/camera_root/camera_pitch/viewport/title/titlecard_hide.play("hide")

func put_step(x, y):
	# create one oak stair block
	for j in range(depth):
		var z = -1 + j
		var stairs = MeshInstance.new()
		stairs.mesh = load("res://assets/models/stairs.obj")
		stairs.set_surface_material(0, load("res://assets/materials/stairs.tres"))
		stairs.transform.origin = Vector3(z * 2, y * 2, -x * 2)
		$stairs_root.add_child(stairs)

func _process(delta):
	vel += -9.8 * delta
	tangent += delta * vel_tangent
	var player = $player_root
	# move Steve
	player.transform.origin += Vector3(0, delta * vel, 0)
	# spin Steve
	$player_root/steve.rotate(spin, spin_speed * delta)
	
	# cycle ladder shifts
	while tangent >= 2:
		tangent -= 2
	
	# shift ladder to imitate movement
	$stairs_root.transform.origin = Vector3(0, 1, 1) * tangent
	
	var dist = pow(player.transform.origin.y, 2) + pow(player.transform.origin.z, 2)
	
	dist -= pow(player.transform.origin.y + player.transform.origin.z, 2) / 2 # dot(r, n)^2/n^2
	dist = sqrt(dist)
	
	# handle "collisions"
	# projects Steve half-height on staricase normal to get effective collision distance
	var eff_dist = 1.7 * abs($player_root/steve.transform.basis.y.dot(Vector3(0, 1, -1))) / sqrt(2) + sqrt(2)
	if dist <= eff_dist:
		vel = random.randf_range(10, bounseiness * 10)
		print("Hit!")
		if (sounds.size() != 0) && sounds_enabled && !$player.playing:
			$player.stream = sounds[random.randi_range(0, sounds.size() - 1)]
			$player.play()
		vel_tangent = random.randf_range(10, 20)
		spin_speed = random.randf_range(6, 12)
		spin.x = -random.randf_range(10, 100)
		spin.y = random.randf_range(0.01, 10)
		spin.z = random.randf_range(0.01, 10)
		spin = spin.normalized()
	
func _input(event):
	if event is InputEventMouseMotion && !viewport_locked:
		print(event.relative)
		$player_root/camera_root.rotate_y(-event.relative.x * base_sensitivity * sensitivity)
		$player_root/camera_root/camera_pitch.rotate_z(event.relative.y * base_sensitivity * sensitivity)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.is_pressed() && \
				!$player_root/camera_root/camera_pitch/viewport/hud.visible:
			viewport_locked = !viewport_locked
		elif event.button_index == BUTTON_RIGHT && event.is_pressed():
			if $player_root/camera_root/camera_pitch/viewport/hud.visible:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				$player_root/camera_root/camera_pitch/viewport/hud.visible = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				$player_root/camera_root/camera_pitch/viewport/hud.visible = true
		elif event.button_index == BUTTON_WHEEL_UP && event.is_pressed():
			camera_zoom(0.8)
		elif event.button_index == BUTTON_WHEEL_DOWN && event.is_pressed():
			camera_zoom(1/0.8)

# zoom in/out
func camera_zoom(factor):
	$player_root/camera_root/camera_pitch/viewport.transform.origin.x *= factor
	$env.environment.dof_blur_far_distance = abs($player_root/camera_root/camera_pitch/viewport.transform.origin.x) + 10

func _on_sensitivity_slider_value_changed(value):
	sensitivity = value
	$player_root/camera_root/camera_pitch/viewport/hud/left/sensitivity_caption.text = "Sensitivity [" + String(value) + "]"


func _on_timescale_slider_value_changed(value):
	Engine.time_scale = value
	$player_root/camera_root/camera_pitch/viewport/hud/left/timescale_label.text = "Time scale [" + String(value) + "]"


func _on_enable_sounds_toggled(button_pressed):
	sounds_enabled = button_pressed


func _on_bounseiness_slider_value_changed(value):
	bounseiness = value
	$player_root/camera_root/camera_pitch/viewport/hud/left/bounsieness_label.text = "Bounseiness [" + String(value) + "]"


func _on_enable_dof_toggled(button_pressed):
	$env.environment.dof_blur_far_enabled = button_pressed
