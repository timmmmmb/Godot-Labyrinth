extends Spatial


var active_point_index = 0

func get_start() -> Vector3:
	return get_child(0).global_transform.origin
	
func get_current() -> Vector3:
	return get_child(active_point_index).global_transform.origin
	
func get_next() -> Vector3:
	active_point_index = (active_point_index + 1) % get_child_count() 
	return get_current()
