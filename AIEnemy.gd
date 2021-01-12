extends KinematicBody

onready var waypoints = get_node(waypoints_path)
onready var nav = get_parent()

export var waypoints_path = NodePath()

export var patrolSpeed = 5
export var chaseSpeed = 10

var currentSpeed = 0

var target_point = null

var path = []
var path_node = 0

var state = "Idle"
var target = null


func _ready():	
	target_point = waypoints.get_start()
	set_path_to(target_point)
	
func _physics_process(delta):
	
	sense()
	
	match state:
		"Patrol":
			patrol()
		"Chase":
			chase()
		"Idle":
			idle()
			
	get_node("AnimationTreePlayer").blend2_node_set_amount("Idle_Run", currentSpeed)
	
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
	state = "Patrol"

func move_on_path(speed):
	currentSpeed = speed
	if path_node < path.size():
		var direction = (path[path_node] - get_global_transform().origin)
		if direction.length() < 1:
			path_node += 1
		else:
			look_at(path[path_node], Vector3.UP)
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func set_path_to(point):
	path = nav.get_simple_path(get_global_transform().origin, point)
	path_node = 0
	


func _on_Timer_timeout():
	if state == "Chase":
		set_path_to(target.get_global_transform().origin)
