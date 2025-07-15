# Player Sprite Collision Fix
# Replace the update_visuals function in Player.gd around line 519

func update_visuals():
	# Update sprite based on movement (including dodge)
	var movement_direction = velocity.x
	
	# During dodge, use dodge direction for sprite flip
	if is_dodging and dodge_direction.x != 0:
		movement_direction = dodge_direction.x
	
	# Use scale-based flipping to keep collision centered
	if movement_direction != 0:
		var base_scale = Vector2(0.5, 0.5)  # Adjust based on your sprite scale
		if movement_direction < 0:  # Moving left
			sprite.scale = Vector2(-abs(base_scale.x), base_scale.y)  # Face left
		else:  # Moving right
			sprite.scale = Vector2(abs(base_scale.x), base_scale.y)  # Face right

# Also update the afterimage creation around line 395:
func create_afterimage():
	if not is_dodging:
		return
	
	# Use PlayerVisuals pooling system if available
	if player_visuals and player_visuals.has_method("create_pooled_afterimage"):
		player_visuals.create_pooled_afterimage(global_position, sprite)
	else:
		# Fallback to creating new afterimage
		var afterimage = Sprite2D.new()
		afterimage.texture = sprite.texture
		afterimage.global_position = global_position
		afterimage.modulate = Color(0.5, 0.5, 1, 0.5)  # Blue tint
		afterimage.scale = sprite.scale  # Use sprite.scale instead of flip_h
		get_tree().current_scene.add_child(afterimage)
		
		# Fade out - create tween on the afterimage to avoid freed object errors
		var tween = afterimage.create_tween()
		tween.tween_property(afterimage, "modulate:a", 0, 0.3)
		tween.tween_callback(afterimage.queue_free)