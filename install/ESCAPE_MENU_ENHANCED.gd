# EscapeMenuController.gd - ENHANCED VERSION READY FOR INSTALLATION
# Purpose: Complete pause menu with ESC key functionality
# Godot Version: 4.4.1 compatible
# Features: Save/load, resume, settings, improved input handling

extends Control
class_name EscapeMenuController

# UI References
@onready var menu_panel: Panel = $MenuPanel
@onready var title_label: Label = $MenuPanel/VBox/TitleLabel
@onready var resume_button: Button = $MenuPanel/VBox/ButtonContainer/ResumeButton
@onready var save_button: Button = $MenuPanel/VBox/ButtonContainer/SaveButton
@onready var load_button: Button = $MenuPanel/VBox/ButtonContainer/LoadButton
@onready var main_menu_button: Button = $MenuPanel/VBox/ButtonContainer/MainMenuButton
@onready var settings_button: Button = $MenuPanel/VBox/ButtonContainer/SettingsButton
@onready var quit_button: Button = $MenuPanel/VBox/ButtonContainer/QuitButton

# Feedback
@onready var feedback_label: Label = $MenuPanel/VBox/FeedbackLabel

# Confirmation Dialog
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var confirmation_label: Label = $ConfirmationDialog/Label

# State
var is_open: bool = false
var is_operation_in_progress: bool = false
var pending_operation: String = ""

# Menu references for proper integration
var save_load_menu_scene = preload("res://scenes/ui/SaveLoadMenu.tscn")
var save_load_menu: Control = null
var settings_menu_scene = preload("res://scenes/ui/UnifiedSettingsMenu.tscn")
var settings_menu: Control = null

# Animation
var fade_tween: Tween

func _ready():
	print("🎮 EscapeMenuController Enhanced Version initialized")
	setup_ui()
	connect_signals()
	_connect_to_save_system()
	
	# Initially hidden
	visible = false
	set_process_mode(Node.PROCESS_MODE_ALWAYS)  # Process even when paused
	
	# ENHANCED: Better input handling
	set_process_unhandled_input(true)

func setup_ui():
	# Setup UI elements with enhanced styling
	title_label.text = "Game Paused"
	
	resume_button.text = "Resume Game"
	save_button.text = "Save Game"
	load_button.text = "Load Game"
	main_menu_button.text = "Return to Main Menu"
	settings_button.text = "Settings"
	quit_button.text = "Quit to Desktop"
	
	# Enhanced feedback system
	feedback_label.text = ""
	feedback_label.visible = false
	
	# Enhanced panel styling
	menu_panel.custom_minimum_size = Vector2(320, 420)

func connect_signals():
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	confirmation_dialog.confirmed.connect(_on_confirmation_confirmed)
	confirmation_dialog.canceled.connect(_on_confirmation_canceled)

func _connect_to_save_system():
	# Enhanced save system integration
	if SaveManager:
		SaveManager.save_completed.connect(_on_save_completed)
		SaveManager.load_completed.connect(_on_load_completed)
		print("🔗 Enhanced escape menu connected to SaveManager")
	elif GameManager and GameManager.has_method("get_save_manager"):
		var save_manager = GameManager.get_save_manager()
		if save_manager:
			save_manager.save_completed.connect(_on_save_completed)
			save_manager.load_completed.connect(_on_load_completed)
			print("🔗 Enhanced escape menu connected to save system via GameManager")

func _unhandled_input(event):
	# ENHANCED: Handle multiple pause input methods
	if event.is_action_pressed("pause_game") or event.is_action_pressed("escape"):
		# Don't handle if other menus are open
		if _is_submenu_open():
			return
			
		toggle_menu()
		get_viewport().set_input_as_handled()
		print("⌨️ EscapeMenuController handled pause input (Enhanced)")

func _is_submenu_open() -> bool:
	# Enhanced submenu detection
	return ((settings_menu and is_instance_valid(settings_menu) and settings_menu.visible) or
			(save_load_menu and is_instance_valid(save_load_menu) and save_load_menu.visible) or
			(confirmation_dialog and confirmation_dialog.visible))

func toggle_menu():
	# Enhanced toggle with better state management
	if is_open:
		close_menu()
	else:
		open_menu()

func open_menu():
	# Enhanced menu opening with better integration
	if is_open or is_operation_in_progress:
		return
	
	is_open = true
	visible = true
	
	# ENHANCED: Use GameStateManager for proper pause handling
	if GameStateManager:
		GameStateManager.change_state(GameStateManager.Phase4GameState.PAUSED)
		print("🎮 EscapeMenuController: Game paused via GameStateManager")
	else:
		# Fallback to direct pause
		get_tree().paused = true
		print("⚠️ EscapeMenuController: Using direct pause (GameStateManager not available)")
	
	# Update button states
	_update_button_states()
	
	# Enhanced fade in animation
	modulate.a = 0.0
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	
	# Focus resume button for keyboard navigation
	resume_button.grab_focus()
	
	print("⏸️ Enhanced escape menu opened")

func close_menu():
	# Enhanced menu closing
	if not is_open or is_operation_in_progress:
		return
	
	# Clear any feedback
	_hide_feedback()
	
	# Enhanced fade out animation
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	fade_tween.tween_callback(_complete_close)

func _complete_close():
	# Enhanced close completion
	visible = false
	is_open = false
	
	# ENHANCED: Use GameStateManager for unified state control
	if GameStateManager:
		print("🎮 EscapeMenuController: Resuming game via GameStateManager")
		GameStateManager.change_state(GameStateManager.Phase4GameState.PLAYING)
	else:
		# Fallback to direct unpause
		print("⚠️ EscapeMenuController: Using direct unpause (GameStateManager not available)")
		get_tree().paused = false
	
	print("▶️ Enhanced escape menu closed - game resumed")

func _update_button_states():
	# Enhanced button state management
	var buttons_enabled = not is_operation_in_progress
	
	resume_button.disabled = not buttons_enabled
	main_menu_button.disabled = not buttons_enabled
	settings_button.disabled = not buttons_enabled
	quit_button.disabled = not buttons_enabled
	
	# Enhanced save button logic
	if buttons_enabled:
		if SaveManager:
			save_button.disabled = not SaveManager.has_active_game()
		elif GameManager and GameManager.has_method("save_game"):
			save_button.disabled = false
		else:
			save_button.disabled = true
	else:
		save_button.disabled = true
	
	# Enhanced load button logic
	if buttons_enabled:
		if SaveManager:
			load_button.disabled = not SaveManager.has_save_file()
		elif GameManager and GameManager.has_method("has_saved_game"):
			load_button.disabled = not GameManager.has_saved_game()
		else:
			load_button.disabled = true
	else:
		load_button.disabled = true

# === ENHANCED BUTTON HANDLERS ===

func _on_resume_pressed():
	print("🎮 Resume button pressed")
	close_menu()

func _on_save_pressed():
	# Enhanced save handling
	if is_operation_in_progress:
		return
	
	print("💾 Save button pressed")
	
	# Use multi-slot save system if available
	if save_load_menu_scene:
		if not save_load_menu:
			save_load_menu = save_load_menu_scene.instantiate()
			get_parent().add_child(save_load_menu)
			save_load_menu.menu_closed.connect(_on_save_load_menu_closed)
			save_load_menu.save_completed.connect(_on_save_menu_completed)
		
		save_load_menu.show_save_menu()
		hide()  # Hide escape menu
	else:
		# Fallback to direct save
		_perform_direct_save()

func _on_load_pressed():
	# Enhanced load handling
	if is_operation_in_progress:
		return
	
	print("📂 Load button pressed")
	
	# Use multi-slot load system if available
	if save_load_menu_scene:
		if not save_load_menu:
			save_load_menu = save_load_menu_scene.instantiate()
			get_parent().add_child(save_load_menu)
			save_load_menu.menu_closed.connect(_on_save_load_menu_closed)
			save_load_menu.slot_selected.connect(_on_slot_loaded)
		
		save_load_menu.show_load_menu()
		hide()  # Hide escape menu
	else:
		# Fallback to direct load
		_perform_direct_load()

func _on_main_menu_pressed():
	print("🏠 Main menu button pressed")
	if is_operation_in_progress:
		return
	
	# Enhanced confirmation dialog
	confirmation_label.text = "Return to main menu?\n\nAny unsaved progress will be lost."
	pending_operation = "main_menu"
	confirmation_dialog.popup_centered()

func _on_settings_pressed():
	print("⚙️ Settings button pressed")
	if is_operation_in_progress:
		return
	
	# Enhanced settings integration
	if not settings_menu:
		settings_menu = settings_menu_scene.instantiate()
		get_parent().add_child(settings_menu)
		settings_menu.tree_exited.connect(_on_settings_closed)
	
	hide()  # Hide escape menu while settings is open
	print("⚙️ Opening enhanced settings menu")

func _on_quit_pressed():
	print("🚪 Quit button pressed")
	if is_operation_in_progress:
		return
	
	# Enhanced quit confirmation
	confirmation_label.text = "Quit to desktop?\n\nAny unsaved progress will be lost."
	pending_operation = "quit"
	confirmation_dialog.popup_centered()

# === ENHANCED CONFIRMATION HANDLERS ===

func _on_confirmation_confirmed():
	print("✅ Confirmation confirmed for: ", pending_operation)
	match pending_operation:
		"main_menu":
			_perform_main_menu()
		"quit":
			_perform_quit()
	
	pending_operation = ""

func _on_confirmation_canceled():
	print("❌ Confirmation canceled for: ", pending_operation)
	pending_operation = ""

func _perform_main_menu():
	# Enhanced main menu return
	is_operation_in_progress = true
	_show_feedback("Returning to main menu...", Color.YELLOW)
	
	# Auto-save if possible
	if SaveManager and SaveManager.has_active_game():
		print("💾 Auto-saving before returning to main menu")
		SaveManager.save_current_game()
		await get_tree().create_timer(0.5).timeout
	
	# Use SceneTransition if available
	if SceneTransition:
		get_tree().paused = false
		SceneTransition.transition_to("res://scenes/ui/MainMenu.tscn")
	else:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _perform_quit():
	# Enhanced quit with auto-save
	is_operation_in_progress = true
	_show_feedback("Saving and quitting...", Color.YELLOW)
	
	# Auto-save before quitting
	if SaveManager and SaveManager.has_active_game():
		print("💾 Auto-saving before quit")
		SaveManager.save_current_game()
		await get_tree().create_timer(0.5).timeout
	
	print("🚪 Quitting game")
	get_tree().quit()

func _perform_direct_save():
	# Enhanced direct save fallback
	is_operation_in_progress = true
	_update_button_states()
	_show_feedback("Saving game...", Color.YELLOW)
	
	if SaveManager:
		var success = SaveManager.save_current_game()
		_on_save_completed(success, "Direct save")
	elif GameManager and GameManager.has_method("save_game"):
		var success = GameManager.save_game()
		_on_save_completed(success, "GameManager save")
	else:
		_on_save_completed(false, "No save system available")

func _perform_direct_load():
	# Enhanced direct load fallback
	is_operation_in_progress = true
	_update_button_states()
	_show_feedback("Loading game...", Color.YELLOW)
	
	if SaveManager:
		var success = await SaveManager.load_saved_game()
		_on_load_completed(success, "Direct load", null)
	elif GameManager and GameManager.has_method("load_game"):
		var success = await GameManager.load_game()
		_on_load_completed(success, "GameManager load", null)
	else:
		_on_load_completed(false, "No load system available", null)

# === ENHANCED SAVE SYSTEM CALLBACKS ===

func _on_save_completed(success: bool, message: String):
	print("💾 Save completed: ", success, " - ", message)
	is_operation_in_progress = false
	_update_button_states()
	
	if success:
		_show_feedback("Game saved successfully!", Color.GREEN)
	else:
		_show_feedback("Save failed: " + message, Color.RED)

func _on_load_completed(success: bool, message: String, _save_data):
	print("📂 Load completed: ", success, " - ", message)
	is_operation_in_progress = false
	_update_button_states()
	
	if success:
		_show_feedback("Game loaded successfully!", Color.GREEN)
		# Close menu after successful load
		await get_tree().create_timer(0.5).timeout
		close_menu()
	else:
		_show_feedback("Load failed: " + message, Color.RED)

# === ENHANCED FEEDBACK SYSTEM ===

func _show_feedback(text: String, color: Color = Color.WHITE):
	print("💬 Showing feedback: ", text)
	feedback_label.text = text
	feedback_label.modulate = color
	feedback_label.visible = true
	
	# Auto-hide after 3 seconds
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(_hide_feedback)

func _hide_feedback():
	if feedback_label:
		feedback_label.visible = false

# === ENHANCED SUBMENU CALLBACKS ===

func _on_save_load_menu_closed():
	print("📂 Save/load menu closed, returning to escape menu")
	show()  # Show escape menu again

func _on_slot_loaded(_slot: int):
	print("🎮 Load completed from slot ", _slot + 1, ", closing escape menu")
	close_menu()

func _on_save_menu_completed():
	print("💾 Save completed, closing escape menu")
	close_menu()

func _on_settings_closed():
	print("⚙️ Settings closed, returning to escape menu")
	show()
	settings_menu = null  # Clear reference

# === ENHANCED KEYBOARD SHORTCUTS ===

func _input(event):
	# Enhanced keyboard shortcuts
	if not is_open:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				if not resume_button.disabled:
					_on_resume_pressed()
					get_viewport().set_input_as_handled()
			KEY_S:
				if event.ctrl_pressed and not save_button.disabled:
					_on_save_pressed()
					get_viewport().set_input_as_handled()
			KEY_L:
				if event.ctrl_pressed and not load_button.disabled:
					_on_load_pressed()
					get_viewport().set_input_as_handled()
			KEY_M:
				if not main_menu_button.disabled:
					_on_main_menu_pressed()
					get_viewport().set_input_as_handled()
			KEY_Q:
				if event.ctrl_pressed and not quit_button.disabled:
					_on_quit_pressed()
					get_viewport().set_input_as_handled()

# === ENHANCED DEBUG AND UTILITIES ===

func get_debug_info() -> String:
	return """
Enhanced EscapeMenuController Debug Info:
- Menu Open: %s
- Operation in Progress: %s
- Pending Operation: %s
- Game Paused: %s
- GameStateManager Available: %s
- SaveManager Available: %s
""" % [
	str(is_open),
	str(is_operation_in_progress),
	pending_operation,
	str(get_tree().paused),
	str(GameStateManager != null),
	str(SaveManager != null)
]