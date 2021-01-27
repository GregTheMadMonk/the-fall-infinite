extends Control

const needs = [ "root", "env", "cam", "player" ]
var nodes = Dictionary()

func _ready():
	# HTML5 version won't have DOF
	if OS.get_name() == "HTML5":
		$left/enable_dof.disabled = true
		$left/enable_dof.pressed = false


func _on_env_overworld_pressed():
	nodes["root"].set_environment("")


func _on_env_nether_pressed():
	nodes["root"].set_environment("_nether")

func _on_env_end_pressed():
	nodes["root"].set_environment("_end")

func _on_sensitivity_slider_value_changed(value):
	$left/sensitivity_caption.text = "Sensitivity [" + String(value) + "]"
	nodes["cam"].sensitivity = value


func _on_timescale_slider_value_changed(value):
	$left/timescale_label.text = "Time scale [" + String(value) + "]"
	Engine.time_scale = value

func _on_bounseiness_slider_value_changed(value):
	$left/bounsieness_label.text = "Bounseiness [" + String(value) + "]"
	nodes["player"].bounseiness = value


func _on_enable_dof_toggled(button_pressed):
	nodes["env"].environment.dof_blur_far_enabled = button_pressed


func _on_enable_sounds_toggled(button_pressed):
	nodes["root"].enable_sounds = button_pressed
