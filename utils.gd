extends Node

func sleep(time: float):
	await get_tree().create_timer(time).timeout

func for_each(array: Array, callback: Callable):
	for element in array:
		callback.call(element)

func better_print(texts: Array, chunk_size: int = 1):
	for text in texts:
		if typeof(text) == TYPE_STRING:
			var lines = text.split("\n")
			for i in range(0, lines.size(), chunk_size):
				print("\n".join(lines.slice(i, i + chunk_size)))
		else:
			print(text)

func set_timeout(a_callback_func: Callable, delay_seconds: float) -> Callable:
	var timer := get_tree().create_timer(delay_seconds)
	var canceled := false

	var wrapper = func():
		await timer.timeout
		if not canceled and a_callback_func:
			a_callback_func.call()
	
	wrapper.call()
	
	return func() -> void:
		canceled = true # untested probably wont work as lambdas are not equal to array functions

func set_interval(a_callback_func: Callable, interval_seconds: float) -> Callable:
	var canceled := false

	var wrapper = func():
		while not canceled:
			await get_tree().create_timer(interval_seconds).timeout
			if not canceled and a_callback_func:
				a_callback_func.call()

	wrapper.call() # Start the interval in the background

	return func() -> void:
		canceled = true # untested probably wont work as lambdas are not equal to array functions
