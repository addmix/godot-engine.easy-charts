extends Control
class_name Chart, "res://addons/easy_charts/utilities/icons/linechart.svg"

onready var _canvas: Canvas = $Canvas
onready var plot_box: PlotBox = $"%PlotBox"
onready var grid_box: GridBox = $"%GridBox"
onready var functions_box: Control = $"%FunctionsBox"
onready var function_legend: FunctionLegend = $"%FunctionLegend"

var functions: Array = []
var x: Array = []
var y: Array = []

var x_labels: Array = []
var y_labels: Array = []
var chart_properties: ChartProperties = ChartProperties.new()


###########

func plot(functions: Array, properties: ChartProperties = ChartProperties.new()) -> void:
	self.functions = functions
	self.chart_properties = properties
	
	theme.set("default_font", self.chart_properties.font)
	_canvas.prepare_canvas(self.chart_properties)
	plot_box.chart_properties = self.chart_properties
	function_legend.chart_properties = self.chart_properties
	
	load_functions(functions)

func get_function_plotter(plotter_type: int) -> FunctionPlotter:
	var plotter: FunctionPlotter
	match plotter_type:
		Function.Type.SCATTER:
			plotter = ScatterPlotter.new()
		Function.Type.LINE:
			plotter = LinePlotter.new()
		Function.Type.AREA:
			plotter = AreaPlotter.new()
	return plotter

func load_functions(functions: Array) -> void:
	self.x = []
	self.y = []
	
	for function in functions:
		self.x.append(function.x)
		self.y.append(function.y)
		
		var function_plotter: FunctionPlotter = get_function_plotter(function.get_type())
		function_plotter.configure(function)
		function_plotter.connect("point_entered", plot_box, "_on_point_entered")
		function_plotter.connect("point_exited", plot_box, "_on_point_exited")
		functions_box.add_child(function_plotter)
		
		function_legend.add_function(function)

func _draw() -> void:
	# GridBox
	var x_domain: Dictionary = calculate_x_domain(x)
	var y_domain: Dictionary = calculate_y_domain(y)
	
	var x_has_decimals: bool = ECUtilities._has_decimals(x)
	var y_has_decimals: bool = ECUtilities._has_decimals(y)
	
	var plotbox_margins: Vector2 = calculate_plotbox_margins(
		x_domain, y_domain, x_has_decimals, y_has_decimals 
	)
	
	# Update values for the PlotBox in order to propagate them to the children
	plot_box.box_margins = plotbox_margins
	
	# Update GridBox
	update_gridbox(x_domain, y_domain, x_has_decimals, y_has_decimals)
	
	# Update each FunctionPlotter in FunctionsBox
	for function_plotter in functions_box.get_children():
		function_plotter.update_values(x_domain, y_domain)

func calculate_x_domain(x: Array) -> Dictionary:
	var x_min_max: Dictionary = ECUtilities._find_min_max(x)
	return { lb = ECUtilities._round_min(x_min_max.min), ub = ECUtilities._round_max(x_min_max.max) }

func calculate_y_domain(y: Array) -> Dictionary:
	var y_min_max: Dictionary = ECUtilities._find_min_max(y)
	return { lb = ECUtilities._round_min(y_min_max.min), ub = ECUtilities._round_max(y_min_max.max) }

func update_gridbox(x_domain: Dictionary, y_domain: Dictionary, x_has_decimals: bool, y_has_decimals: bool) -> void:
	grid_box.set_domains(x_domain, y_domain)
#	grid_box.set_labels(x_labels, y_labels)
	grid_box.set_has_decimals(x_has_decimals, y_has_decimals)
	grid_box.update()

func calculate_plotbox_margins(x_domain: Dictionary, y_domain: Dictionary, x_has_decimals: bool, y_has_decimals: bool) -> Vector2:
	var plotbox_margins: Vector2 = Vector2(
		chart_properties.x_tick_size,
		chart_properties.y_tick_size
	)
	
	if chart_properties.show_labels:
		var x_ticklabel_size: Vector2
		var y_ticklabel_size: Vector2
		
		var y_max_formatted: String = ECUtilities._format_value(y_domain.ub, y_has_decimals)
		if y_domain.lb < 0: # negative number
			var y_min_formatted: String = ECUtilities._format_value(y_domain.lb, y_has_decimals)
			if y_min_formatted.length() >= y_max_formatted.length():
				 y_ticklabel_size = chart_properties.font.get_string_size(y_min_formatted)
			else:
				y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)
		else:
			y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)
		
		plotbox_margins.x += y_ticklabel_size.x + chart_properties.x_ticklabel_space
		plotbox_margins.y += chart_properties.font.size + chart_properties.y_ticklabel_space
	
	return plotbox_margins
