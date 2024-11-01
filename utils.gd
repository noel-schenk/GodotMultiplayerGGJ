extends Node

func for_each(array: Array, callback: Callable):
	for element in array:
		callback.call(element)  
