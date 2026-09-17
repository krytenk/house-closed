extends Object
class_name Palette

const LAGOON := Color("#2EC4B6")
const DEEP := Color("#0B6E6F")
const SAND := Color("#E2C290")
const CORAL := Color("#E07A5F")
const BAMBOO := Color("#C4A35A")
const AMBER := Color("#F4A261")
const CREAM := Color("#F7F1E3")
const INK := Color("#1B1B1B")

const FORBIDDEN_MAGENTA := Color("#FF00FF")
const FORBIDDEN_CHROME := Color("#FFD700")


static func is_forbidden_primary(c: Color) -> bool:
	if abs(c.r - 1.0) < 0.02 and c.g < 0.08 and abs(c.b - 1.0) < 0.02:
		return true
	if abs(c.r - 1.0) < 0.02 and abs(c.g - 215.0 / 255.0) < 0.04 and c.b < 0.08:
		return true
	return false
