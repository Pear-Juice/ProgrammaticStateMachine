# Programmatic State Machine
## A simple state machine that exits solely in code.


This plugin defines two classes: `State` and `StateMachine`

Create a new `StateMachine` by defining a variable: 

```GDScript
let state_m = StateMachine.create(self)
```

Add states by calling:

```GDScript
state_m.add_state("State Name", enter_func, process_func, physics_process_func, exit_func)
```

transfer between states using:

```GDScript
state_m.transfer("StateName")
```

The state machine will automatically handle state transitions and call the correct functions.

## State Dependency

State dependencies are created to handle state transfers during asynchronous transfer calls.

To create a dependency, get the current state ID and save it to a variable. In the transfer call,
pass the saved state ID as a parameter.

```GDScript
var state_id = state_m.get_current_state_id()

await get_tree().create_timer(1.0).timeout

state_m.transfer("NextState", state_id)
```

### For a more in-depth example, see StateMachineExample.tscn
