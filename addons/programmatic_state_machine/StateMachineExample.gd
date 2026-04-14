#Example State Machine Usage
#Begins in idle state. After two seconds it transfers to state 1. From then on it loops between state 1 2 and 3 every two seconds
#If you press Space during any state it will cancel and transfer to the next state

extends Node2D

@export var sprite : Sprite2D
@export var pos_idle : Marker2D
@export var pos_1 : Marker2D
@export var pos_2 : Marker2D
@export var pos_3 : Marker2D

var state_m : StateMachine

func _ready() -> void:
	#Create the state machine object, "self" allows the state machine to attach itself to the node tree. This can be any node in the scene tree
	state_m = StateMachine.create(self)
	#Enable debug to print internal state transfers
	state_m.debug = true
	
	#Create four states, Idle, Pos_1, Pos_2, Pos_3. Pass in functions that will get called on state enter and process
	#Enter gets called on state enter
	#Process gets called on _process()
	#There are also phys_process and exit connections available
	#All connections are optional
	state_m.add_state("Idle", idle_enter, idle_process, null, idle_exit)
	state_m.add_state("Pos_1", pos_1_enter, pos_1_process)
	state_m.add_state("Pos_2", pos_2_enter, pos_2_process)
	state_m.add_state("Pos_3", pos_3_enter, pos_3_process)
	
	#Transfer to the first state
	state_m.transfer("Idle")

#Idle enter gets called when state machine transfers to "Idle"
func idle_enter():
	print("Wait 2 seconds...")
	await get_tree().create_timer(2).timeout
	
	print("Move to Pos 1 position")
	#Transfer to 
	state_m.transfer("Pos_1")

func idle_exit():
	print("Idle state exited")

func idle_process(delta):
	move_to(pos_idle.global_position, Color.WHITE, delta)
	
	if Input.is_action_just_pressed("ui_select"):
		print("Force to pos 1")
		state_m.transfer("Pos_1")
	

func pos_1_enter():
	print("Wait 2 seconds...")
	#get the current state id
	var current_state_id = state_m.get_current_state_id()
	await get_tree().create_timer(2).timeout
	
	print("Move to Pos 2 position")
	
	#because this transfer happens asynchronously after a delay,
	#pass the saved state id to ensure that when transfer is finally
	#called, it will only transfer if called from the same state we began in
	state_m.transfer("Pos_2", current_state_id)

func pos_1_process(delta):
	#Lerp position and color every frame to the desired position and color
	move_to(pos_1.global_position, Color.RED, delta)
	
	if Input.is_action_just_pressed("ui_select"):
		print("Force to pos 2")
		
		#Force the transfer from Pos_1 to Pos_2
		#This will mean that it will transfer before the delayed transfer
		#that will happen in pos_1_enter. The delayed transfer will cancel
		#because the current state's state id is different
		state_m.transfer("Pos_2")

#Identical to pos_1
func pos_2_enter():
	print("Wait 2 seconds...")
	var current_state_id = state_m.get_current_state_id()
	await get_tree().create_timer(2).timeout
	
	print("Move to Pos 3 position")
	state_m.transfer("Pos_3", current_state_id)

func pos_2_process(delta):
	move_to(pos_2.global_position, Color.GREEN, delta)
	
	if Input.is_action_just_pressed("ui_select"):
		print("Force to pos 3")
		state_m.transfer("Pos_3")

#Identical to pos_1
func pos_3_enter():
	print("Wait 2 seconds...")
	var current_state_id = state_m.get_current_state_id()
	await get_tree().create_timer(2).timeout
	
	print("Move to Pos 1 position")
	state_m.transfer("Pos_1", current_state_id)

func pos_3_process(delta):
	move_to(pos_3.global_position, Color.BLUE, delta)
	
	if Input.is_action_just_pressed("ui_select"):
		print("Force to pos 1")
		state_m.transfer("Pos_1")

#Lerp position and color one step
func move_to(pos : Vector2, color : Color, delta : float):
	sprite.global_position = lerp(sprite.global_position, pos, 3 * delta)
	sprite.modulate = lerp(sprite.modulate, color, 3 * delta)
