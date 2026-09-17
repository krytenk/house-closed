extends Control


func _ready() -> void:
	$FunOnly.text = Game.text("fun_only")
	$Title.text = Game.text("shop_tab")
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("lobby"))
	$Confirm.custom_minimum_size = Vector2(240, 56)
	$Confirm.visible = false
	var y := 160
	for sku in IapStub.catalog:
		var id: String = str(sku.get("id", ""))
		var price: float = float(sku.get("price_usd", 0))
		var b := Button.new()
		b.text = "%s  $%.2f" % [id, price]
		b.position = Vector2(80, y)
		b.custom_minimum_size = Vector2(640, 52)
		b.pressed.connect(_buy.bind(id, price, b))
		add_child(b)
		y += 64
	$Note.text = Game.text("iap_no_cashout")


func _buy(sku_id: String, price: float, _btn: Button) -> void:
	if not IapStub.can_purchase(sku_id):
		$Note.text = IapStub.last_error
		return
	if not IapStub.first_iap_done:
		$Confirm.visible = true
		$Confirm.text = Game.text("first_iap_confirm", {"amount": "$%.2f" % price})
		$Confirm.pressed.connect(func() -> void:
			IapStub.mock_purchase(sku_id, true)
			$Confirm.visible = false
			$Note.text = Game.text("iap_no_cashout")
			Save.write_disk()
		, CONNECT_ONE_SHOT)
		return
	IapStub.mock_purchase(sku_id, true)
	Save.write_disk()
	$Note.text = Game.text("iap_no_cashout")
