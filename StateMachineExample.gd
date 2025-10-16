#Example State Machine Usage
#Loops between Idle and Walk states every three seconds
#If you press Space during the Walk state then it will exit to the finish state
#Set state_m.debug = true for more verbose output

extends Node2D

var state_m : StateMachine

func _ready() -> void:
	#Create the state machine object, "self" allows the state machine to attach itself to the node tree. This can be any node in the scene tree
	state_m = StateMachine.create(self)
	
	#Create three states, Idle, Walk, and Finish. Idle just enters and exits. Walk processes each frame. Finish is the exit for the state machine loop
	state_m.add_state("Idle", idle_begin, null, null, idle_exit)
	state_m.add_state("Walk", walk_begin, walk_process, walk_phys_process, walk_exit)
	state_m.add_state("Finish", finish_begin)
	
	#Transfer to the first state
	state_m.transfer("Idle")
	
func idle_begin():
	print("Begin Idle")
	print("Waiting 3 seconds...")
	await get_tree().create_timer(3).timeout #Wait three secondsss
	#Transfer to the Walk state and require that this is transferring from the Idle state.
	state_m.transfer("Walk", "Idle")

func idle_exit():
	print("Exit Idle")
	
func walk_begin():
	print("Begin Walk")
	print("Waiting 3 seconds...")
	await get_tree().create_timer(3).timeout #Wait three seconds
	state_m.transfer("Idle", "Walk") #Transfer back to the Idle state and require that this is transferring from the Walk state

func walk_process(delta : float):
	print("Process Walk: ", delta)
	if Input.is_action_just_pressed("ui_select"): #When Space is received as input, exit the Idle-Walk loop and enter finish. Require this to be called from walk
		state_m.transfer("Finish", "Walk") #Transfer to Finish state

func walk_phys_process(delta : float):
	print("Phys process Walk: ", delta)

func walk_exit():
	print("Exit Walk")
	
func finish_begin():
	print("Finish!")
