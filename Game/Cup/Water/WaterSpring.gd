##### Spring Modelling
extends Node2D


signal splashed # we will trigger this signal to call the splash function


var velocity = 0 # the spring's current velocity
var force = 0 # the force being applied to the spring
var height = 0 # the current height of the spring

var target_height = 0 #the natural position of the spring

# the index of this spring
#we will set it on initialize
var index = 0

#how much an external object movement will affect this spring
var motion_factor = 0.015

#the last instance this spring collided with
#we check so it won't collide twice
var collided_with = null


@onready var collision = $Area2D/CollisionShape2D


## This function applies the hooke's law force to the spring!!
## This function will be called in each frame
## hooke's law ---> F =  - K * x 
func water_update(spring_constant, dampening):
	height = position.y #update the height value based on our current position
	
	var extension = height - target_height #the spring current extension
	var loss = -dampening * velocity
	
	force = - spring_constant * extension + loss #hooke's law
	
	velocity += force
	position.y += velocity


func initialize(x_position, p_index):
	height = position.y
	target_height = position.y
	velocity = 0
	position.x = x_position
	index = p_index


func set_collision_width(value):
	collision.shape.size = Vector2(value, collision.shape.size.y)


func _on_Area2D_body_entered(body):
	if not body is RigidBody2D:
		return
	
	body = body as RigidBody2D
	if body == collided_with:
		return
	
	collided_with = body
	
	#we multiply the motion of the body by the motion factor
	#if we didn't the speed would be huge, depending on your game
	var speed = body.linear_velocity.y * motion_factor
	splashed.emit(index, speed)
