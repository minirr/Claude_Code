extends Node2D
## Desktop pet — larger window with accessible UI

const WIN_W = 500
const WIN_H = 300

var bird: Node2D
var classifier: Node
var popup_menu: PopupMenu
var file_dialog: FileDialog
var select_button: Button
var name_label: Label

var dragging: bool = false
var drag_mouse_start: Vector2i
var drag_window_start: Vector2i


func _ready():
	var window = get_window()

	# Enable true transparent background via DisplayServer (not ProjectSettings!)
	DisplayServer.set_setting("rendering/transparent_background", true)
	window.transparent_bg = true
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true

	var screen = DisplayServer.screen_get_size()
	window.position = Vector2i((screen.x - WIN_W) / 2, (screen.y - WIN_H) / 2)

	_create_bird()
	_create_ui()
	_create_classifier()


func _create_bird():
	bird = load("res://scripts/bird.gd").new()
	bird.name = "Bird"
	bird.position = Vector2(WIN_W / 2.0, WIN_H / 2.0 + 10)
	bird.scale = Vector2(1.6, 1.6)
	add_child(bird)

	var area = Area2D.new()
	area.name = "MouseArea"
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 55.0
	shape.shape = circle
	area.add_child(shape)
	area.mouse_entered.connect(bird._on_mouse_entered)
	area.mouse_exited.connect(bird._on_mouse_exited)
	area.input_event.connect(_on_bird_input)
	area.input_pickable = true
	bird.add_child(area)


func _create_classifier():
	classifier = load("res://scripts/environment_classifier.gd").new()
	classifier.name = "Classifier"
	add_child(classifier)


func _create_ui():
	popup_menu = PopupMenu.new()
	popup_menu.add_item("选择图片...", 0)
	popup_menu.add_separator()
	popup_menu.add_item("退出", 1)
	popup_menu.id_pressed.connect(_on_menu_item)
	add_child(popup_menu)

	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.title = "选择一张图片来识别环境"
	file_dialog.add_filter("*.jpg,*.jpeg,*.png", "图片文件")
	file_dialog.file_selected.connect(_on_image_selected)
	add_child(file_dialog)

	# Bigger, more visible button
	select_button = Button.new()
	select_button.text = "选图"
	select_button.position = Vector2(WIN_W - 110, WIN_H - 45)
	select_button.size = Vector2(100, 36)
	select_button.pressed.connect(_on_select_pressed)
	add_child(select_button)

	# Bigger name label
	name_label = Label.new()
	name_label.position = Vector2(14, 12)
	name_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.text = bird.get_bird_name()
	add_child(name_label)

	# Hint text
	var hint = Label.new()
	hint.position = Vector2(14, WIN_H - 22)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.add_theme_font_size_override("font_size", 11)
	hint.text = "拖拽移动  |  右键菜单  |  Ctrl+Q 退出"
	add_child(hint)


func _on_menu_item(id: int):
	match id:
		0: _pick_image()
		1: get_tree().quit()


func _on_select_pressed():
	_pick_image()


func _on_bird_input(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			popup_menu.position = DisplayServer.mouse_get_position() - get_window().position
			popup_menu.popup()
			bird.notify_interaction()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				bird.notify_interaction()
				dragging = true
				drag_mouse_start = DisplayServer.mouse_get_position()
				drag_window_start = get_window().position
			else:
				dragging = false
	if event is InputEventMouseMotion and dragging:
		var delta = DisplayServer.mouse_get_position() - drag_mouse_start
		get_window().position = drag_window_start + delta


func _pick_image():
	file_dialog.popup_centered_ratio(0.7)


func _on_image_selected(path: String):
	var env = classifier.classify(path)
	var species = BirdData.get_species(env)
	bird.set_species(species)
	name_label.text = bird.get_bird_name()


func _input(event):
	if event is InputEventKey and event.keycode == KEY_Q and event.ctrl_pressed:
		get_tree().quit()
