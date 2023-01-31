extends Control
class_name AbstractChart

var x_labels: Array = []
var y_labels: Array = []
var functions_names: Array = []

###### STYLE
var chart_properties: ChartProperties = ChartProperties.new()

#### INTERNAL
# The bounding_box of the chart
var frame: Rect2
var node_box: Rect2
var bounding_box: Rect2
var plot_offset: Vector2
var plot_box: Rect2

var _padding_offset: Vector2 = Vector2(20.0, 20.0)
var _internal_offset: Vector2 = Vector2(15.0, 15.0)

# Nodes
onready var _canvas: Control = $Canvas
onready var _tooltip: Control = $Tooltip

###########
func _ready() -> void:
	set_process_input(false)
	set_process(false)
	
	_canvas.set_font(chart_properties.font)
	_tooltip.set_font(chart_properties.font)

func _draw() -> void:
	_calc_frame()
	_calc_node_box()
	_calc_bounding_box()
	_calc_plot_box()
	
	if chart_properties.borders:
		_draw_borders()
	
	if chart_properties.frame:
		_draw_frame()
	
	if chart_properties.background:
		_draw_background()
	
	if chart_properties.bounding_box:
		_draw_bounding_box()
	
	_pre_process()
	_post_process()
	
	if chart_properties.grid or chart_properties.ticks or chart_properties.labels:
		_draw_grid()
	
	if chart_properties.labels:
		_draw_xaxis_label()
		_draw_yaxis_label()
		_draw_title()

func _pre_process() -> void:
	return

func _post_process() -> void:
	return

func _calc_frame() -> void:
	frame = get_global_rect()

func _calc_node_box() -> void:
	#### @node_box size, which is the whole "frame"
	node_box = Rect2(Vector2.ZERO, frame.size - frame.position)

func _calc_bounding_box() -> void:
	#### calculating offset from the @node_box for the @bounding_box.
	plot_offset = _padding_offset
	
	### @bounding_box, where the points will be plotted
	bounding_box = Rect2(
		plot_offset, 
		frame.size - (plot_offset * 2)
	)

func _calc_plot_box() -> void:
	plot_box = Rect2(
		bounding_box.position + _internal_offset,
		bounding_box.size - (_internal_offset * 2)
	)

func _draw_borders() -> void:
	draw_rect(node_box, chart_properties.colors.borders, false, 1, true)

func _draw_frame() -> void:
	draw_rect(frame, chart_properties.colors.frame, true, 1.0, false)

func _draw_background() -> void:
	draw_rect(bounding_box, chart_properties.colors.background, true, 1, true)

func _draw_bounding_box() -> void:
	draw_rect(bounding_box, chart_properties.colors.bounding_box, false, 1, true)
	
#	# (debug)
#	var half: Vector2 = (bounding_box.size) / 2
#	draw_line(bounding_box.position + Vector2(half.x, 0), bounding_box.position + Vector2(half.x, bounding_box.size.y), Color.red, 3, false)
#	draw_line(bounding_box.position + Vector2(0, half.y), bounding_box.position + Vector2(bounding_box.size.x, half.y), Color.red, 3, false)

func _draw_origin() -> void:
	pass

func _draw_grid() -> void:
	pass

func _draw_vertical_grid() -> void:
	pass

func _draw_horizontal_grid() -> void:
	pass

func _create_canvas_label(text: String, position: Vector2, rotation: float = 0.0) -> Label:
	var lbl: Label = Label.new()
	_canvas.add_child(lbl)
	lbl.set("custom_fonts/font", chart_properties.font)
	lbl.set_text(text)
	lbl.modulate = chart_properties.colors.labels
	lbl.rect_rotation = rotation
	lbl.rect_position = position
	return lbl

func _draw_yaxis_label() -> void:
	var y_lbl_size: Vector2 = chart_properties.get_string_size(chart_properties.y_label)
	_canvas.update_y_label(
		chart_properties.y_label,
		chart_properties.colors.labels,
		Vector2(_padding_offset.x, (node_box.size.y / 2) + (y_lbl_size.x / 2)),
		-90
	)

func _draw_xaxis_label() -> void:
	var _x_label_size: Vector2 = chart_properties.get_string_size(chart_properties.x_label)
	_canvas.update_x_label(
		chart_properties.x_label,
		chart_properties.colors.labels,
		Vector2(
			node_box.size.x/2 - (_x_label_size.x / 2), 
			node_box.size.y - _padding_offset.y - _x_label_size.y 
		)
	)

func _draw_title() -> void:
	_canvas.update_title(
		chart_properties.title,
		chart_properties.colors.labels,
		Vector2(node_box.size.x / 2, _padding_offset.y*2) - (chart_properties.font.get_string_size(chart_properties.title) / 2)
	)
