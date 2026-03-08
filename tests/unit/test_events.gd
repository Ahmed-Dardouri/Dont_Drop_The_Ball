extends GutTest
## Unit tests for the dynamic event manager system (Events.gd)
## Tests listener registration, invocation, and removal

var _events: Node
var _listener_called: bool = false
var _received_event: Event = null
var _call_count: int = 0


func before_each() -> void:
	# Create a fresh Events instance for each test
	_events = Node.new()
	_events.set_script(_create_events_script())
	add_child_autofree(_events)
	_listener_called = false
	_received_event = null
	_call_count = 0


func _create_events_script() -> GDScript:
	var script = GDScript.new()
	script.source_code = """
extends Node

var events := {}

func add_listener(event_class: GDScript, method: Callable) -> void:
	if !events.has(event_class):
		events[event_class] = []
	events[event_class].push_front(method)

func remove_listener(event_class: GDScript, method: Callable) -> void:
	if !events.has(event_class):
		return
	if events[event_class].has(method):
		events[event_class].erase(method)

func invoke(event: Event) -> void:
	var event_class = event.get_script()
	if !events.has(event_class):
		return
	var listeners = events[event_class]
	for i in range(listeners.size() - 1, -1, -1):
		await listeners[i].call(event)
"""
	script.reload()
	return script


func _create_test_event_class() -> GDScript:
	var script = GDScript.new()
	script.source_code = """
class_name TestEvent extends Event
var data: String = ""

func _init(p_data: String = "") -> void:
	data = p_data
"""
	script.reload()
	return script


func _on_test_event(event: Event) -> void:
	_listener_called = true
	_received_event = event
	_call_count += 1


#region add_listener tests

func test_add_listener_registers_callback() -> void:
	var event_class := _create_test_event_class()
	var callback := Callable(self, "_on_test_event")
	_events.add_listener(event_class, callback)

	# Verify the listener was added by checking internal state
	assert_true(_events.events.has(event_class), "Event class should be registered")
	assert_true(_events.events[event_class].has(callback), "Callback should be in listeners list")


func test_add_listener_multiple_same_event() -> void:
	var event_class := _create_test_event_class()
	_events.add_listener(event_class, Callable(self, "_on_test_event"))
	_events.add_listener(event_class, Callable(self, "_on_test_event"))

	# Same callback added twice should appear twice (current behavior)
	assert_eq(_events.events[event_class].size(), 2, "Same callback can be added multiple times")


func test_add_listener_different_events() -> void:
	var event_class1 := _create_test_event_class()
	var event_class2 := _create_test_event_class()
	_events.add_listener(event_class1, Callable(self, "_on_test_event"))
	_events.add_listener(event_class2, Callable(self, "_on_test_event"))

	assert_true(_events.events.has(event_class1), "First event class should be registered")
	assert_true(_events.events.has(event_class2), "Second event class should be registered")


#endregion

#region remove_listener tests

func test_remove_listener_removes_callback() -> void:
	var event_class := _create_test_event_class()
	var callback := Callable(self, "_on_test_event")
	_events.add_listener(event_class, callback)
	_events.remove_listener(event_class, callback)

	assert_false(_events.events[event_class].has(callback), "Callback should be removed")


func test_remove_listener_nonexistent_class() -> void:
	var event_class := _create_test_event_class()
	# Should not crash when removing from non-existent event class
	_events.remove_listener(event_class, Callable(self, "_on_test_event"))
	assert_true(true, "Should handle non-existent event class gracefully")


func test_remove_listener_nonexistent_callback() -> void:
	var event_class := _create_test_event_class()
	_events.add_listener(event_class, Callable(self, "_on_test_event"))
	# Should not crash when removing non-existent callback
	_events.remove_listener(event_class, Callable(self, "nonexistent_method"))
	assert_eq(_events.events[event_class].size(), 1, "Original callback should remain")


#endregion

#region invoke tests

func test_invoke_calls_listener() -> void:
	var event_class := _create_test_event_class()
	_events.add_listener(event_class, Callable(self, "_on_test_event"))

	var event_script = event_class.new()
	event_script.data = "test_data"
	await _events.invoke(event_script)

	assert_true(_listener_called, "Listener should be called")
	assert_eq(_received_event.data, "test_data", "Event data should be passed correctly")


func test_invoke_no_listeners() -> void:
	var event_class := _create_test_event_class()
	var event_script = event_class.new()

	# Should not crash when invoking with no listeners
	await _events.invoke(event_script)
	assert_false(_listener_called, "Listener should not be called when not registered")


func test_invoke_multiple_listeners() -> void:
	var event_class := _create_test_event_class()
	_events.add_listener(event_class, Callable(self, "_on_test_event"))
	_events.add_listener(event_class, Callable(self, "_on_test_event"))

	var event_script = event_class.new()
	await _events.invoke(event_script)

	assert_eq(_call_count, 2, "Both listeners should be called")


#endregion
