package game;

import game.MessengerUI;

class Game {
	var app:hxd.App;
	var phoneSprite:h2d.Bitmap;
	var uiContainer:h2d.Object;
	var answerButtonsContainer:h2d.Object;
	var redAreaBounds:{
		x:Float,
		y:Float,
		width:Float,
		height:Float
	};
	var messenger:MessengerUI;

	public function new(app:hxd.App) {
		this.app = app;
		init();
	}

	function init() {
		// Phone sprite
		var phoneTile = hxd.Res.game.phone.toTile();
		phoneSprite = new h2d.Bitmap(phoneTile, app.s2d);

		// Находим красную область
		redAreaBounds = findRedArea(phoneTile);
		trace('Red area found: x=${redAreaBounds.x}, y=${redAreaBounds.y}, w=${redAreaBounds.width}, h=${redAreaBounds.height}');

		// UI Container для интерфейса чата
		uiContainer = new h2d.Object(app.s2d);
		// Контейнер для кнопок ответов

		answerButtonsContainer = new h2d.Object(app.s2d);

		// Создаём мессенджер
		messenger = new MessengerUI(uiContainer, answerButtonsContainer, redAreaBounds.width, redAreaBounds.height, false);

		// Инициализируем позицию и масштаб UI
		var tileW = phoneSprite.tile.width;
		var tileH = phoneSprite.tile.height;
		var baseScale = 5.0;
		var maxScale = app.s2d.height / tileH;
		var scale = Math.min(baseScale, maxScale);
		updateUIPosition(scale);

		// Запускаем диалог
		messenger.startDialog();
	}

	function findRedArea(tile:h2d.Tile):{
		x:Float,
		y:Float,
		width:Float,
		height:Float
	} {
		var texture = tile.getTexture();
		var pixels = texture.capturePixels();

		var minX = tile.width;
		var minY = tile.height;
		var maxX = 0.0;
		var maxY = 0.0;

		var redCount = 0;

		for (y in 0...Std.int(tile.height)) {
			for (x in 0...Std.int(tile.width)) {
				var pixel = pixels.getPixel(x, y);

				var r = (pixel >> 16) & 0xFF;
				var g = (pixel >> 8) & 0xFF;
				var b = pixel & 0xFF;
				var a = (pixel >> 24) & 0xFF;

				var isRed = r > 220 && g < 50 && b < 50 && a > 200;

				if (isRed) {
					redCount++;
					if (x < minX)
						minX = x;
					if (y < minY)
						minY = y;
					if (x > maxX)
						maxX = x;
					if (y > maxY)
						maxY = y;

					pixels.setPixel(x, y, 0x00000000);
				}
			}
		}

		trace('Found $redCount red pixels');

		texture.uploadPixels(pixels);
		pixels.dispose();

		return {
			x: minX,
			y: minY,
			width: maxX - minX + 1,
			height: maxY - minY + 1
		};
	}

	public function update(dt:Float) {
		if (hxd.Key.isPressed(hxd.Key.F9)) {
			logDebugInfo();
		}

		var tileW = phoneSprite.tile.width;
		var tileH = phoneSprite.tile.height;
		var baseScale = 5.0;
		var maxScale = app.s2d.height / tileH;
		var scale = Math.min(baseScale, maxScale);

		phoneSprite.scaleX = scale;
		phoneSprite.scaleY = scale;

		var redAreaBottom = (redAreaBounds.y + redAreaBounds.height) * scale;
		var buttonsHeight = 150;
		var totalHeight = redAreaBottom + buttonsHeight;

		phoneSprite.x = (app.s2d.width - tileW * scale) * 0.5 - (tileW * scale) * 0.25;

		if (totalHeight > app.s2d.height) {
			phoneSprite.y = (app.s2d.height - totalHeight) * 0.5;
		} else {
			phoneSprite.y = app.s2d.height - tileH * scale;
		}

		updateUIPosition(scale);
	}

	function updateUIPosition(scale:Float) {
		uiContainer.x = phoneSprite.x + redAreaBounds.x * scale;
		uiContainer.y = phoneSprite.y + redAreaBounds.y * scale;
		uiContainer.scaleX = scale;
		uiContainer.scaleY = scale;

		var redAreaBottom = phoneSprite.y + (redAreaBounds.y + redAreaBounds.height) * scale;
		var additionalOffset = redAreaBounds.height * scale * 0.15;

		answerButtonsContainer.x = phoneSprite.x + redAreaBounds.x * scale;
		answerButtonsContainer.y = redAreaBottom + additionalOffset;
		answerButtonsContainer.scaleX = scale;
		answerButtonsContainer.scaleY = scale;
	}

	function logDebugInfo() {
		var tileW = phoneSprite.tile.width;
		var tileH = phoneSprite.tile.height;
		var baseScale = 5.0;
		var maxScale = app.s2d.height / tileH;
		var scale = Math.min(baseScale, maxScale);

		var log = "=== DEBUG INFO ===\n";
		log += "Screen: " + app.s2d.width + "x" + app.s2d.height + "\n";
		log += "Phone tile: " + tileW + "x" + tileH + "\n";
		log += "Phone scale: " + scale + "\n";
		log += "Phone pos: " + phoneSprite.x + ", " + phoneSprite.y + "\n";
		log += "Red area bounds: x="
			+ redAreaBounds.x
			+ ", y="
			+ redAreaBounds.y
			+ ", w="
			+ redAreaBounds.width
			+ ", h="
			+ redAreaBounds.height
			+ "\n";
		log += "UI container pos: " + uiContainer.x + ", " + uiContainer.y + "\n";
		log += "UI container scale: " + uiContainer.scaleX + ", " + uiContainer.scaleY + "\n";
		log += "Messenger container children: " + messenger.container.numChildren + "\n";

		trace(log);

		#if js
		js.Browser.navigator.clipboard.writeText(log);
		trace("Copied to clipboard!");

		js.Syntax.code("
			try {
				const audioContext = new (window.AudioContext || window.webkitAudioContext)();
				const oscillator = audioContext.createOscillator();
				const gainNode = audioContext.createGain();

				oscillator.connect(gainNode);
				gainNode.connect(audioContext.destination);

				oscillator.frequency.value = 800;
				gainNode.gain.value = 0.3;

				oscillator.start(audioContext.currentTime);
				oscillator.stop(audioContext.currentTime + 0.1);
			} catch(e) {
				console.log('Audio beep failed:', e);
			}
		");
		#end
	}
}
// another test
