@tool
class_name PageInventoryContainer
extends BackPatchContainer

signal page_button_down(page:BaseAction, button:InventoryPageButton)
signal page_button_enter(page:BaseAction)
signal page_button_hover(page:BaseAction)
signal page_button_hover_end
signal page_button_clicked(page:BaseAction)

@export var tab_bar:TabBar
@export var pages_container:FlowContainer
@export var premade_page_button:InventoryPageButton

var _mouse_in_button:InventoryPageButton
var _page_buttons:Dictionary = {}
var _hover_delay:float = 0.3
var _hover_timer:float
var _click_delay:float = 0.4
var _click_timer:float

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	premade_page_button.visible = false
	tab_bar.tab_changed.connect(_on_tab_bar_select)
	if !ActionLibrary.Instance:
		ActionLibrary.new()
	build_page_list()

func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	if _mouse_in_button and _hover_timer > 0:
		_hover_timer -= delta
		if _hover_timer < 0:
			var page = ActionLibrary.get_action(_mouse_in_button._action_key)
			if page:
				page_button_hover.emit(page)
	if _click_timer > 0:
		_click_timer -= delta

func set_actor(actor:BaseActor):
	tab_bar.clear_tabs()
	var pages_per_tags = actor.pages.get_pages_per_page_tags()
	for page_tags in pages_per_tags.keys():
		if page_tags == "Any":
			page_tags = "All"
		tab_bar.add_tab(page_tags)

func build_page_list():
	for button in _page_buttons.values():
		button.queue_free()
	_page_buttons.clear()
	
	print("Building Pages")
	for page in ActionLibrary.list_all_actions():
		print(page.ActionKey)
		_build_button(page)

func _build_button(page:BaseAction):
	print("Build BUtton:  "+ page.ActionKey)
	var new_button:InventoryPageButton = premade_page_button.duplicate()
	pages_container.add_child(new_button)
	new_button.set_page(page)
	_page_buttons[page.ActionKey] = new_button
	new_button.visible = true
	new_button.button_down.connect(_on_page_button_down.bind(new_button))
	new_button.button_up.connect(_on_page_button_up.bind(new_button))
	new_button.mouse_entered.connect(_mouse_enter_button.bind(new_button))
	new_button.mouse_exited.connect(_mouse_exit_button.bind(new_button))

func _on_page_button_down(button:InventoryPageButton):
	var page = button.get_page()
	page_button_down.emit(page, button)
	_click_timer = _click_delay
	
func _on_page_button_up(button:InventoryPageButton):
	if _click_timer > 0:
		var page = button.get_page()
		page_button_clicked.emit(page)
	_click_timer = 0
	

func _mouse_enter_button(button:InventoryPageButton):
	_mouse_in_button = button
	_hover_timer = _hover_delay
	var page = button.get_page()
	page_button_enter.emit(page)
	
func _mouse_exit_button(button:InventoryPageButton):
	_mouse_in_button = null
	_hover_timer = -1
	page_button_hover_end.emit()

func _on_tab_bar_select(index:int):
	var tab_name = tab_bar.get_tab_title(index)
	if tab_name == "All":
		filter_pages_with_tag('')
	else:
		filter_pages_with_tag(tab_name)
	pass

func filter_pages_with_tag(tag:String):
	for button:InventoryPageButton in _page_buttons.values():
		var page = button.get_page()
		if tag == '':
			button.visible = true
		elif page.details.tags.has(tag):
			button.visible = true
		else:
			button.visible = false