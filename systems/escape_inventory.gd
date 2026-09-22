extends Node
## 8-slot item bar. Coins stack. Not a wallet.

signal changed

const MAX_SLOTS := 8

var slots: Array = []  ## {id, label, count}
var selected: int = 0


func reset() -> void:
	slots.clear()
	selected = 0
	changed.emit()


func add_item(id: String, label: String, amount: int = 1) -> void:
	for s in slots:
		if str(s.get("id", "")) == id:
			s["count"] = int(s.get("count", 0)) + amount
			changed.emit()
			return
	if slots.size() >= MAX_SLOTS:
		return
	slots.append({"id": id, "label": label, "count": amount})
	changed.emit()


func count_of(id: String) -> int:
	for s in slots:
		if str(s.get("id", "")) == id:
			return int(s.get("count", 0))
	return 0


func has_item(id: String) -> bool:
	return count_of(id) > 0


func take(id: String, amount: int = 1) -> bool:
	for i in slots.size():
		var s: Dictionary = slots[i]
		if str(s.get("id", "")) != id:
			continue
		if int(s.get("count", 0)) < amount:
			return false
		s["count"] = int(s["count"]) - amount
		if int(s["count"]) <= 0:
			slots.remove_at(i)
			if selected >= slots.size():
				selected = maxi(0, slots.size() - 1)
		changed.emit()
		return true
	return false


func selected_id() -> String:
	if selected < 0 or selected >= slots.size():
		return ""
	return str((slots[selected] as Dictionary).get("id", ""))


func selected_label() -> String:
	if selected < 0 or selected >= slots.size():
		return ""
	var s: Dictionary = slots[selected]
	var n: int = int(s.get("count", 1))
	var lab: String = str(s.get("label", s.get("id", "")))
	if n > 1:
		return "%s ×%d" % [lab, n]
	return lab
