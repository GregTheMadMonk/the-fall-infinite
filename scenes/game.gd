# THE FALL
# "Simulation" (simulation of a simulation)
# Inspired by https://www.youtube.com/watch?v=SrPApgp-aa4

extends Spatial
var random # RNG

var sounds = []

var enable_sounds = true

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
	
	# create stairs
	$stairs_root.construct()
	$stairs_root.set_stairs_material(load("res://assets/materials/stairs.tres"))
	
	# assign scene properties
	assign_props(self)
	
	# capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# hide titlecard
	$title.hide()

func _process(delta):
	# shift ladder to imitate movement
	$stairs_root.transform.origin = Vector3(0, 1, 1) * $player_root.tangent

# handle player input
func _input(event):
	if event is InputEventMouseMotion:
		$player_root/camera_root.move(event.relative)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.is_pressed() && \
				!$hud.visible:
			$player_root/camera_root.toggle_lock()
		elif event.button_index == BUTTON_RIGHT && event.is_pressed():
			if $hud.visible:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				$hud.visible = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				$hud.visible = true
		elif event.button_index == BUTTON_WHEEL_UP && event.is_pressed():
			$player_root/camera_root.zoom(0.8)
		elif event.button_index == BUTTON_WHEEL_DOWN && event.is_pressed():
			$player_root/camera_root.zoom(1/0.8)

# recursively gives access to requested parts of the scene
func assign_props(node):
	if node.get("needs"):
		for needs in node.needs:
			if needs == "env":
				node.nodes[needs] = $env
			elif needs == "cam":
				node.nodes[needs] = $player_root/camera_root
			elif needs == "player":
				node.nodes[needs] = $player_root
			elif needs == "root":
				node.nodes[needs] = self
			elif needs == "rand":
				node.nodes[needs] = random
			elif needs == "snd":
				node.nodes[needs] = $player
	
	for child in node.get_children():
		assign_props(child)

func set_environment(environment):
	$stairs_root.set_stairs_material(load("res://assets/materials/stairs" + environment + ".tres"))

func play_hit_sound():
	if (sounds.size() != 0) && enable_sounds:
		$player.stream = sounds[random.randi_range(0, sounds.size() - 1)]
		$player.play()
