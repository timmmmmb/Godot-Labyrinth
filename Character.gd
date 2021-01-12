extends KinematicBody

var gravity = -9.8
var velocity = Vector3()
var camera
var anim_player
var character

var current_orbs = 0
export(Array, NodePath) var orbs_path
export(Array, NodePath) var enemies_path

onready var orb_label = get_node("../OrbLabel")
onready var game_label = get_node("../GameLabel")
onready var restart_button = get_node("../RestartButton")
onready var start_button = get_node("../StartButton")
onready var timer = $Timer
export var text_display_time = 2
var display_time = 0

const SPEED = 6
const ACCELERATION = 3
const DE_ACCELERATION = 5

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	anim_player = get_node("AnimationPlayer")
	character = get_node(".")
	
	orb_label.text = str("0 / ", orbs_path.size())
	for orb_path in orbs_path:
		var orb = get_node(orb_path)
		orb.connect("orb_collected", self, "on_orb_collected")
		
	for enemy_path in enemies_path:
		var enemy = get_node(enemy_path)
		enemy.connect("player_caught", self, "on_player_caught")
		
	restart_button.visible = false
	restart_button.pause_mode = Node.PAUSE_MODE_PROCESS
	start_button.pause_mode = Node.PAUSE_MODE_PROCESS
		
	game_label.text = "Collect all orbs an find the exit"
	display_time = text_display_time
	timer.start()
	get_tree().paused = true
		
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _physics_process(delta):
	
	camera = get_node("target/Camera").get_global_transform()
	var dir = Vector3()
	
	var is_moving = false

	if(Input.is_action_pressed("move_fw")):
		dir += -camera.basis[2]
		is_moving = true
	if(Input.is_action_pressed("move_bw")):
		dir += camera.basis[2]
		is_moving = true
	if(Input.is_action_pressed("move_l")):
		dir += -camera.basis[0]
		is_moving = true
	if(Input.is_action_pressed("move_r")):
		dir += camera.basis[0]
		is_moving = true
		
	dir.y = 0
	dir = dir.normalized()
	
	velocity.y += delta * gravity
	
	var hv = velocity
	hv.y = 0
	
	var new_pos = dir * SPEED
	var accel = DE_ACCELERATION
	
	if (dir.dot(hv) > 0):
		accel = ACCELERATION
		
	hv = hv.linear_interpolate(new_pos, accel * delta)
	
	velocity.x = hv.x
	velocity.z = hv.z
			
	velocity = move_and_slide(velocity, Vector3(0,1,0))	
	
	if is_moving:
		
		# Rotate the player to direction
		var angle = atan2(hv.x, hv.z)
		
		var char_rot = character.get_rotation()
		
		char_rot.y = angle
		character.set_rotation(char_rot)
	
	var speed = hv.length() / SPEED
	
	get_node("AnimationTreePlayer").blend2_node_set_amount("Idle_Run", speed)
	
func game_over():
	restart_button.visible = true
	
	
func on_orb_collected():
	current_orbs += 1
	
	orb_label.text = str(current_orbs, " / ", orbs_path.size())	
	
	game_label.text = "Orb collected!"
	display_time = text_display_time
	
func on_player_caught():
	game_label.text = "You got caught!"
	get_tree().paused = true
	game_over()


func _on_Exit_body_entered(body):
	if current_orbs == orbs_path.size():
		game_label.text = "Congratulations!"
		get_tree().paused = true
		game_over()
	else:
		game_label.text = "Collect all orbs first!"
		display_time = text_display_time


func _on_Timer_timeout():
	if display_time <= 0:
		game_label.text = ""
	else:
		display_time -= timer.wait_time
	


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false



func _on_StartButton_pressed():
	get_tree().paused = false
	start_button.visible = false
