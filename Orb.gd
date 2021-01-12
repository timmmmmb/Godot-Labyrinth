extends Spatial


signal orb_collected


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	var layer_name = ProjectSettings.get_setting(
		str("layer_names/3d_physics/layer_", body.get_collision_layer()))
		
	if layer_name == "Player":
		emit_signal("orb_collected")
		queue_free()
