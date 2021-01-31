extends WorldEnvironment

var env = "o"

func switch_to(environment):
	var new_env = "o"
	if environment == "_nether":
		new_env = "n"
	elif environment == "_end":
		new_env = "e"
	
	if new_env != env:
		if $env_changer.has_animation(env + "-" + new_env):
			$env_changer.play(env + "-" + new_env)
		elif $env_changer.has_animation(new_env + "-" + env):
			$env_changer.play_backwards(new_env + "-" + env)
	
	env = new_env
