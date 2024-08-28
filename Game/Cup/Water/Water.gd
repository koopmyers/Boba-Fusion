extends Node2D

@export var width := 32*6 #px, total water body lenght
@export var depth := 1000 #px
@export var density := 1.0

@export var impact_factor := 50.0
@export var spring_factor := 0.015
@export var dampening_factor := 0.03
@export var spread_factor := 0.2 #spread factor dictates how much the waves will spread to their neighboors

@export var springs_amount: int = 6 #number of springs in the scene

@export var border_thickness := 1.1

@export var surface_color := Color.WHITE:
	set(x):
		surface_color = x
		if is_inside_tree():
			water_border.color = surface_color

@export var color := Color.AQUAMARINE:
	set(x):
		color = x
		if is_inside_tree():
			water_polygon.modulate = color


@export var WaterSpring: PackedScene
@export var SplashParticle: PackedScene

var springs = []
var passes = 12
var is_initiated := false

@onready var distance_between_springs := width/float(springs_amount-1)
@onready var initial_level := global_position.y

@onready var water_polygon = $WaterPolygon
@onready var water_border = $WaterBorder
@onready var water_body_area = $WaterBodyArea
@onready var collisionShape = $WaterBodyArea/CollisionShape2D


func _ready():
	surface_color = surface_color
	color = color
	initiate()


func initiate():
	water_border.width = border_thickness
	spread_factor = spread_factor / 1000
	
	for i in range(springs_amount):
		var water_spring = WaterSpring.instantiate()
		add_child(water_spring)
		springs.append(water_spring)
		
		water_spring.initialize(distance_between_springs*i, i)
		water_spring.set_collision_width(distance_between_springs)
		water_spring.splashed.connect(splash)
	
	
	var rectangle = RectangleShape2D.new()
	collisionShape.set_shape(rectangle)
	rectangle.size = Vector2(width, depth)
	collisionShape.position = 0.5*Vector2(width, depth)
	
	
	is_initiated = true


func clear():
	is_initiated = false
	for i_spring in springs:
		i_spring.splashed.disconnect(splash)
		i_spring.queue_free()
	
	springs.clear()


func reload():
	clear()
	initiate()


func reset_level():
	global_position.y = initial_level



func _physics_process(_delta):
	if not is_initiated:
		return
	
	#moves all the springs accordingly
	for i_spring in springs:
		i_spring.water_update(spring_factor, dampening_factor)
	
	#represents the movement of the left and right neighbor of the springs
	
	var left_deltas = []
	var right_deltas = []
	
	#initialize the values with an array of zeros
	for i in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
	for j in range(passes):
		#loops through each spring of our array
		for i in range(springs.size()):
			#adds velocity to the spring to the LEFT of the current spring
			if i > 0:
				left_deltas[i] = spread_factor * (springs[i].height - springs[i-1].height)
				springs[i-1].velocity += left_deltas[i]
			#adds velocity to the spring to the RIGHT of the current spring
			if i < springs.size()-1:
				right_deltas[i] = spread_factor * (springs[i].height - springs[i+1].height)
				springs[i+1].velocity += right_deltas[i]
	
	new_border()
	draw_water_body()


func draw_water_body():
	
	#makes an array of the points in the curve
	var water_polygon_points = Array(water_border.curve.get_baked_points())
	
	#add other two points at the bottom of the polygon, to close the water body
	water_polygon_points.append(Vector2(water_polygon_points[-1].x, depth))
	water_polygon_points.append(Vector2(water_polygon_points[0].x, depth))
	
	#transforms our normal array into a poolvector2array
	#the polygon draw function uses poolvector2arrays to draw the polygon, so we converted it
	water_polygon_points = PackedVector2Array(water_polygon_points)
	
	#sets the points of our polygon, and also our UV in the case we want to give it a texture
	water_polygon.set_polygon(water_polygon_points)
	water_polygon.set_uv(water_polygon_points)
	
	#background_polygon.set_polygon(water_polygon_points)


func new_border():
	#DRAW A NEW BORDER TO THE WATER
	
	#creates a new curve 2D
	var curve = Curve2D.new()
	
	#creates a new array, that holds the positions of the surface points!!
	#we'll use those points to draw our border
	var surface_points = []
	for i_spring in springs:
		surface_points.append(i_spring.position)
	
	#adds the points to the curve
	for i_point in surface_points:
		curve.add_point(i_point)
	
	#puts the new curve into our border, smooths it out and then update the border drawing
	water_border.curve = curve
	water_border.smooth()
	water_border.queue_redraw()


#this function adds a speed to a spring with this index
func splash(index, speed):
	if index < 0 or springs.size() <= index:
		return
	
	springs[index].velocity += speed


func _on_water_body_area_body_entered(body: Node2D) -> void:
	if not body is TapiocaBubble:
		return
	
	body.fluid_density = density
	
	var particule = SplashParticle.instantiate()
	add_child(particule)
	particule.modulate = surface_color
	particule.global_position = body.global_position


func _on_water_body_area_body_exited(body: Node2D) -> void:
	if body is TapiocaBubble:
		body.fluid_density = 0.0
