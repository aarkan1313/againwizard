# Test script for PlayerStatSheet dependency injection
extends Node

func _ready():
	print("🧪 Testing PlayerStatSheet dependency injection...")
	
	# Test 1: Create PlayerStatSheet without entity
	var stat_sheet = PlayerStatSheet.new()
	print("✓ PlayerStatSheet created")
	
	# Test 2: Check if it's not initialized yet
	if not stat_sheet._is_initialized:
		print("✓ Correctly not initialized before entity is set")
	
	# Test 3: Set owner entity
	var mock_player = Node.new()
	mock_player.name = "TestPlayer"
	stat_sheet.set_owner_entity(mock_player)
	print("✓ Owner entity set")
	
	# Test 4: Initialize
	stat_sheet.initialize()
	print("✓ Initialize called")
	
	# Test 5: Check base stats
	if stat_sheet.has_stat("intelligence"):
		print("✓ Base stats registered: intelligence =", stat_sheet.get_stat_value("intelligence"))
	else:
		print("❌ Base stat 'intelligence' not found")
	
	# Test 6: Check computed stats
	var max_health = stat_sheet.get_stat_value("max_health")
	print("✓ Computed stat works: max_health =", max_health)
	
	# Validate that computed stats are working correctly
	var expected_health = 100.0 + stat_sheet.get_stat_value("vitality") * 5.0 + stat_sheet.get_stat_value("level") * 3.0
	if abs(max_health - expected_health) < 0.1:
		print("✓ max_health computation is correct")
	else:
		print("❌ max_health computation incorrect. Expected:", expected_health, "Got:", max_health)
	
	# Test 7: Try allocating stat points
	stat_sheet.available_stat_points = 5
	var success = stat_sheet.allocate_stat_points("intelligence", 2)
	if success:
		print("✓ Stat allocation works: intelligence =", stat_sheet.get_stat_value("intelligence"))
		
		# Verify that computed stats updated
		var new_max_health = stat_sheet.get_stat_value("max_health")
		if new_max_health != max_health:
			print("✓ Computed stats updated after stat allocation")
		else:
			print("❌ Computed stats did not update after stat allocation")
	else:
		print("❌ Stat allocation failed")
	
	# Test 8: Check XP gain
	var initial_level = stat_sheet.get_level()
	var initial_points = stat_sheet.get_available_stat_points()
	stat_sheet.gain_experience(150)
	var final_level = stat_sheet.get_level()
	var final_points = stat_sheet.get_available_stat_points()
	
	print("✓ XP gain works: level =", final_level, "available points =", final_points)
	
	if final_level > initial_level:
		print("✓ Level up occurred")
		var expected_new_points = initial_points + (final_level - initial_level) * 5
		if final_points == expected_new_points:
			print("✓ Stat points awarded correctly for level up")
		else:
			print("❌ Stat points incorrect. Expected:", expected_new_points, "Got:", final_points)
	
	# Test 9: Verify milestone system preparation
	if stat_sheet.has_method("apply_milestone_bonus"):
		print("✓ Milestone system methods available")
	else:
		print("❌ Milestone system methods missing")
	
	# Test 10: Check save/load compatibility
	var all_stats = stat_sheet.get_all_stats()
	if all_stats.has("intelligence") and all_stats.has("max_health"):
		print("✓ Save/load compatibility: all stats accessible")
	else:
		print("❌ Save/load compatibility issue: missing expected stats")
	
	print("🎉 All tests completed!")
	
	# Cleanup
	mock_player.queue_free()