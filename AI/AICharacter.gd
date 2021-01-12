extends KinematicBody

onready var waypoints = get_node(waypoints_path)
onready var nav = get_parent()

onready var timer = $Timer

export var waypoints_path = NodePath()

export var patrolSpeed = 2.0
export var chaseSpeed = 4.0
export var maxSpeed = 4.0

enum {
	IDLE,
	PATROL,
	CHASE
}

var currentSpeed = 0.0

var target_point = null

var path = []
var path_node = 0

var state = IDLE
var target = null
var wait_after_target_lost = 3
var wait_time = 0



func _ready():	
	target_point = waypoints.get_start()
	set_path_to(target_point)
	
func _physics_process(delta):
	
	sense()
	
	match state:
		PATROL:
			patrol()
		CHASE:
			chase()
		IDLE:
			idle()
	
	var s = currentSpeed * 1.0 / maxSpeed
	get_node("AnimationTreePlayer").blend2_node_set_amount("Idle_Run", s)
	
func sense():
	pass

func patrol():
	if get_global_transform().origin.distance_to(target_point) < 2:
		target_point = waypoints.get_next()
		set_path_to(target_point)
	
	move_on_path(patrolSpeed)
			
func chase():
	move_on_path(chaseSpeed)
		
	
func idle():
	if wait_time <= 0:
		state = PATROL

func move_on_path(speed):
	currentSpeed = speed
	if path_node < path.size():
		var direction = (path[path_node] - get_global_transform().origin)
		if direction.length() < 1:
			path_node += 1
		else:
			look_at(path[path_node], Vector3.UP)
			rotate_object_local(Vector3(0,1,0), PI)
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func set_path_to(point):
	path = nav.get_simple_path(get_global_transform().origin, point)
	path_node = 0
	
func _on_Area_body_entered(body):
	var layer_name = ProjectSettings.get_setting(
		str("layer_names/3d_physics/layer_", body.get_collision_layer()))
	
	if layer_name == "Player":
		state = CHASE
		target = body
		set_path_to(target.get_global_transform().origin)

func _on_Area_body_exited(body):
	var layer_name = ProjectSettings.get_setting(
		str("layer_names/3d_physics/layer_", body.get_collision_layer()))
	
	if layer_name == "Player":
		state = IDLE
		target = null
		wait_time = wait_after_target_lost


func _on_Timer_timeout():
	if state == IDLE:
		wait_time = wait_time - timer.wait_time
	if state == CHASE:		
		set_path_to(target.get_global_transform().origin)
