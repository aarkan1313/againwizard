# COMPATIBILITY_TEST.gd
# Purpose: Test script to validate spell toolbar integration
# Usage: Add as autoload or run as standalone script
# Godot Version: 4.4.1

extends Node

# Test configuration
var run_full_test: bool = true
var verbose_output: bool = true
var test_results: Array = []

func _ready():
	name = "CompatibilityTest"
	print("🧪 Starting Spell Toolbar Compatibility Test")
	
	if run_full_test:
		run_compatibility_tests()

func run_compatibility_tests():
	"""Run complete compatibility test suite"""
	print("=" * 50)
	print("SPELL TOOLBAR COMPATIBILITY TEST")
	print("=" * 50)
	
	# Test 1: Check required files exist
	test_file_existence()
	
	# Test 2: Validate existing systems
	test_existing_systems()
	
	# Test 3: Check UI integration points
	test_ui_integration()
	
	# Test 4: Validate input system
	test_input_system()
	
	# Test 5: Check scene structure
	test_scene_structure()
	
	# Print results
	print_test_results()

func test_file_existence():
	"""Test that all required files exist"""
	add_test_header("File Existence Test")
	
	var required_files = [
		"res://scripts/ui/SpellToolbar.gd",
		"res://scripts/ui/SpellSlot.gd", 
		"res://scenes/ui/SpellToolbar.tscn",
		"res://scripts/managers/ToolbarManager.gd"
	]
	
	var all_exist = true
	for file_path in required_files:
		var exists = ResourceLoader.exists(file_path)
		log_test_result("File exists: " + file_path, exists)
		if not exists:
			all_exist = false
	
	add_test_result("All required files exist", all_exist)

func test_existing_systems():
	"""Test existing game systems compatibility"""
	add_test_header("Existing Systems Test")
	
	# Test SpellComponent class
	var spell_component_exists = _class_exists("SpellComponent")
	log_test_result("SpellComponent class exists", spell_component_exists)
	
	# Test InputHandler singleton
	var input_handler = get_node_or_null("/root/InputHandler")
	var input_handler_exists = input_handler != null
	log_test_result("InputHandler singleton exists", input_handler_exists)
	
	# Test GameEvents singleton
	var game_events = get_node_or_null("/root/GameEvents")
	var game_events_exists = game_events != null
	log_test_result("GameEvents singleton exists", game_events_exists)
	
	# Test SpellData class
	var spell_data_exists = _class_exists("SpellData")
	log_test_result("SpellData class exists", spell_data_exists)
	
	var all_systems = spell_component_exists and input_handler_exists and spell_data_exists
	add_test_result("All existing systems compatible", all_systems)

func test_ui_integration():
	"""Test UI integration compatibility"""
	add_test_header("UI Integration Test")
	
	# Find main scene
	var main_scene = get_tree().current_scene
	var main_scene_exists = main_scene != null
	log_test_result("Main scene exists", main_scene_exists)
	
	# Find UI CanvasLayer
	var ui_layer = null
	if main_scene:
		ui_layer = main_scene.get_node_or_null("UI")
	var ui_layer_exists = ui_layer != null and ui_layer is CanvasLayer
	log_test_result("UI CanvasLayer exists", ui_layer_exists)
	
	# Check for existing UI elements (should not conflict)
	var has_player_ui = false
	var has_wave_display = false
	if ui_layer:
		has_player_ui = ui_layer.get_node_or_null("PlayerUI") != null
		has_wave_display = ui_layer.get_node_or_null("WaveDisplay") != null
	
	log_test_result("PlayerUI exists (no conflict expected)", has_player_ui)
	log_test_result("WaveDisplay exists (no conflict expected)", has_wave_display)
	
	add_test_result("UI integration ready", ui_layer_exists)

func test_input_system():
	"""Test input system compatibility"""
	add_test_header("Input System Test")
	
	# Test required input actions
	var required_actions = [
		"spell_1", "spell_2", "spell_3", "spell_4", "spell_5",
		"move_left", "move_right", "move_up", "move_down"
	]
	
	var all_actions_exist = true
	for action in required_actions:
		var exists = InputMap.has_action(action)
		log_test_result("Input action exists: " + action, exists)
		if not exists:
			all_actions_exist = false
	
	# Test InputHandler methods
	var input_handler = get_node_or_null("/root/InputHandler")
	var has_spell_methods = false
	var has_movement_methods = false
	
	if input_handler:
		has_spell_methods = input_handler.has_method("is_spell_cast_pressed")
		has_movement_methods = input_handler.has_method("get_movement_vector")
	
	log_test_result("InputHandler has spell methods", has_spell_methods)
	log_test_result("InputHandler has movement methods", has_movement_methods)
	
	var input_compatible = all_actions_exist and has_spell_methods and has_movement_methods
	add_test_result("Input system compatible", input_compatible)

func test_scene_structure():
	"""Test scene structure and player setup"""
	add_test_header("Scene Structure Test")
	
	# Find player
	var player = get_tree().get_first_node_in_group("players")
	var player_exists = player != null
	log_test_result("Player node exists", player_exists)
	
	# Check for SpellComponent on player
	var spell_component = null
	if player:
		spell_component = player.get_node_or_null("SpellComponent")
	var spell_component_exists = spell_component != null
	log_test_result("Player has SpellComponent", spell_component_exists)
	
	# Test SpellComponent methods
	var spell_methods_exist = false
	if spell_component:
		spell_methods_exist = (
			spell_component.has_method("get_equipped_spells") and
			spell_component.has_method("is_spell_ready") and
			spell_component.has_method("get_spell_cooldown") and
			spell_component.has_method("cast_spell")
		)
	log_test_result("SpellComponent has required methods", spell_methods_exist)
	
	# Check spell data
	var has_spells = false
	if spell_component and spell_component.has_method("get_equipped_spells"):
		var spells = spell_component.get_equipped_spells()
		has_spells = spells.size() > 0
	log_test_result("Player has equipped spells", has_spells)
	
	var scene_ready = player_exists and spell_component_exists and spell_methods_exist
	add_test_result("Scene structure ready for toolbar", scene_ready)

func _class_exists(class_name: String) -> bool:
	"""Check if a class exists in the project"""
	# Try to create an instance to test if class exists
	var script_exists = false
	
	# Check common locations for the class
	var possible_paths = [
		"res://scripts/components/" + class_name + ".gd",
		"res://scripts/data/" + class_name + ".gd",
		"res://scripts/" + class_name + ".gd"
	]
	
	for path in possible_paths:
		if ResourceLoader.exists(path):
			script_exists = true
			break
	
	return script_exists

func add_test_header(header: String):
	"""Add a test section header"""
	if verbose_output:
		print("\n--- " + header + " ---")

func log_test_result(test_name: String, passed: bool):
	"""Log individual test result"""
	var symbol = "✅" if passed else "❌"
	var message = symbol + " " + test_name
	
	if verbose_output:
		print(message)

func add_test_result(test_name: String, passed: bool):
	"""Add a major test result"""
	test_results.append({
		"name": test_name,
		"passed": passed
	})
	
	var symbol = "✅" if passed else "❌"
	print("\n" + symbol + " " + test_name.to_upper())

func print_test_results():
	"""Print final test results summary"""
	print("\n" + "=" * 50)
	print("TEST RESULTS SUMMARY")
	print("=" * 50)
	
	var total_tests = test_results.size()
	var passed_tests = 0
	
	for result in test_results:
		var symbol = "✅" if result.passed else "❌"
		print(symbol + " " + result.name)
		if result.passed:
			passed_tests += 1
	
	print("\nResults: %d/%d tests passed" % [passed_tests, total_tests])
	
	if passed_tests == total_tests:
		print("\n🎉 ALL TESTS PASSED!")
		print("Your project is ready for spell toolbar integration.")
		print("\n📋 Next steps:")
		print("1. Copy toolbar files to your project")
		print("2. Add ToolbarManager to Main.tscn")
		print("3. Test the toolbar in game")
	else:
		print("\n⚠️ SOME TESTS FAILED")
		print("Please resolve the failed tests before installing the toolbar.")
		print("\n🔧 Common fixes:")
		print("- Ensure all required classes exist")
		print("- Check that input actions are configured")
		print("- Verify scene structure matches expected layout")

func run_integration_test():
	"""Test actual toolbar integration (run after installation)"""
	print("\n🧪 Running Integration Test...")
	
	# Try to create toolbar components
	var toolbar_scene_path = "res://scenes/ui/SpellToolbar.tscn"
	if ResourceLoader.exists(toolbar_scene_path):
		var toolbar_scene = load(toolbar_scene_path)
		if toolbar_scene:
			var toolbar = toolbar_scene.instantiate()
			if toolbar:
				print("✅ Toolbar scene instantiation successful")
				toolbar.queue_free()
			else:
				print("❌ Failed to instantiate toolbar scene")
		else:
			print("❌ Failed to load toolbar scene")
	else:
		print("❌ Toolbar scene file not found")
	
	# Try to create toolbar manager
	var manager_script_path = "res://scripts/managers/ToolbarManager.gd"
	if ResourceLoader.exists(manager_script_path):
		var manager_script = load(manager_script_path)
		if manager_script:
			var manager = manager_script.new()
			if manager:
				print("✅ ToolbarManager creation successful")
				manager.queue_free()
			else:
				print("❌ Failed to create ToolbarManager")
		else:
			print("❌ Failed to load ToolbarManager script")
	else:
		print("❌ ToolbarManager script file not found")

# Utility function to run specific tests
func run_specific_test(test_name: String):
	"""Run a specific test by name"""
	match test_name:
		"files":
			test_file_existence()
		"systems":
			test_existing_systems()
		"ui":
			test_ui_integration()
		"input":
			test_input_system()
		"scene":
			test_scene_structure()
		"integration":
			run_integration_test()
		_:
			print("Unknown test: " + test_name)

# Console commands for manual testing
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				run_compatibility_tests()
			KEY_F10:
				run_integration_test()
			KEY_F11:
				print(get_debug_info())

func get_debug_info() -> String:
	"""Get debug information about current project state"""
	var info = """
DEBUG INFO:
- Scene: %s
- Player exists: %s
- UI layer exists: %s
- InputHandler exists: %s
- GameEvents exists: %s
""" % [
		get_tree().current_scene.name if get_tree().current_scene else "None",
		str(get_tree().get_first_node_in_group("players") != null),
		str(get_tree().current_scene.get_node_or_null("UI") != null if get_tree().current_scene else false),
		str(get_node_or_null("/root/InputHandler") != null),
		str(get_node_or_null("/root/GameEvents") != null)
	]
	
	return info