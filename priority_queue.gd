extends RefCounted
class_name PriorityQueue

var _heap: Array = [] # entries are [priority: float, item]

func is_empty() -> bool:
	return _heap.is_empty()

func push(item, priority: float) -> void:
	_heap.append([priority, item])
	_sift_up(_heap.size() - 1)

func pop():
	var top = _heap[0][1]
	var last = _heap.pop_back()
	if not _heap.is_empty():
		_heap[0] = last
		_sift_down(0)
	return top

func _sift_up(i: int) -> void:
	while i > 0:
		var parent := (i - 1) >> 1
		if _heap[i][0] < _heap[parent][0]:
			var tmp = _heap[i]; _heap[i] = _heap[parent]; _heap[parent] = tmp
			i = parent
		else:
			break

func _sift_down(i: int) -> void:
	var n := _heap.size()
	while true:
		var smallest := i
		var l := 2 * i + 1
		var r := 2 * i + 2
		if l < n and _heap[l][0] < _heap[smallest][0]:
			smallest = l
		if r < n and _heap[r][0] < _heap[smallest][0]:
			smallest = r
		if smallest == i:
			break
		var tmp = _heap[i]; _heap[i] = _heap[smallest]; _heap[smallest] = tmp
		i = smallest
