class_name StateMachine

extends Node

var state_array : Array[State]
var current_state : State
var paused_state : State
var debug : bool
var delta : float

## Creates a new state machine object[br]
## [param base] defines the node to attach proccess signals to
static func create(base : Node):
	var new_machine = StateMachine.new()
	base.add_child(new_machine)
	
	return new_machine

## Destroys the state machine
func destroy():
	current_state = null
	queue_free()

## Pauses the state machine
func pause():
	paused_state = current_state
	current_state = null

## Resumes the state machine
func resume():
	current_state = paused_state
	
## Adds a state to the state machine[br]
## [param state_name] The name of the state to add.[br]
## [param enter_func] The function called when the state is transferred to[br]
## [param process_func] The function called every frame after enter[br]
## [param phys_process_func] The function called every physics frame after enter[br]
func add_state(state_name : String, enter_func = null, process_func = null, phys_process_func = null, exit_func = null):
	var state = State.new()
	state.state_name = state_name
	state.enter = enter_func
	state.process = process_func
	state.phys_process = phys_process_func
	state.exit = exit_func
	state_array.append(state)

## Gets the current state's ID[br]
## Note: state id changes on state enter[br]
## Useful for passing in to a transfer call in order to ensure it is called from the same state
func get_current_state_id():
	return current_state.state_id

## Transfers to a state[br]
## [param state_name] The name of the state to transfer to[br]
## [param require_current_state] The id of the state that this transfer must happen from.[br]
## Only necessary if transfer is called asynchronously
func transfer(state_name : String, required_state_id := 0):
	if debug:
		if current_state:
			prints("SM: Transfer from:", current_state.state_name, "to", state_name)
		else:
			prints("SM: Transfer to", state_name)
	
	if (required_state_id != 0 && required_state_id != current_state.state_id):
		if debug:
			prints("SM: Cancelling transfer, state id", required_state_id, " does not match ", current_state.state_id)
			
		return
		
	if current_state && current_state.exit:
		current_state.exit.call()
		if debug:
			prints("SM: Exit", current_state.state_name)
	
	var found_state := false
	for state in state_array:
		if state.state_name == state_name:
			current_state = state
			found_state = true
	
	if !found_state:
		print("SM: Error: ", state_name, " not a registered state")
		return
		
	if current_state && current_state.enter:
		if debug:
			prints("SM: Enter", current_state.state_name)
	
		current_state.elapsed_time = 0
		current_state.state_id = Time.get_ticks_msec()+1
		current_state.enter.call()

func _process(delta):
	if current_state && current_state.process:
		current_state.process.call(delta)
		current_state.elapsed_time += delta
		
func _physics_process(delta: float) -> void:
	if current_state && current_state.phys_process:
		current_state.phys_process.call(delta)
		current_state.elapsed_time += delta
