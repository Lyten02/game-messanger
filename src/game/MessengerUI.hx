package game;

class MessengerUI {
	public var container:h2d.Object;
	var chatHistory:Array<{text:String, isBot:Bool}> = [];
	var messageContainer:h2d.Object;
	var answerButtonsContainer:h2d.Object;
	var currentDialogIndex:Int = 0;
	var messageYOffset:Float = 0;
	var chatHeight:Float = 0;
	var font:h2d.Font;

	// Диалог с ботом
	var dialog:Array<{botMessage:String, answers:Array<String>}> = [
		{botMessage: "Hi! How are you?", answers: ["Great!", "OK", "Bad"]},
		{botMessage: "What are you doing?", answers: ["Working", "Resting", "Playing"]},
		{botMessage: "Wanna play?", answers: ["Yes!", "No", "Maybe"]},
	];

	var uiWidth:Float;
	var uiHeight:Float;

	public function new(chatParent:h2d.Object, buttonsParent:h2d.Object, width:Float, height:Float, autoStart:Bool = true) {
		container = new h2d.Object(chatParent);
		answerButtonsContainer = new h2d.Object(buttonsParent);
		uiWidth = width;
		uiHeight = height;

		// Используем DefaultFont без масштабирования для чёткости
		font = hxd.res.DefaultFont.get();

		// Создаём UI мессенджера
		createHeader();
		createChatArea();

		// Запускаем диалог (если autoStart == true)
		if (autoStart) {
			sendBotMessage();
		}
	}

	public function startDialog() {
		sendBotMessage();
	}


	function createHeader() {
		var headerHeight = uiHeight * 0.15; // 15% от высоты

		// Фон хедера
		var headerBg = new h2d.Graphics(container);
		headerBg.beginFill(0x2C3E50);
		headerBg.drawRect(0, 0, uiWidth, headerHeight);
		headerBg.endFill();

		// Аватар (круг) - меньше
		var avatarRadius = headerHeight * 0.3;
		var avatar = new h2d.Graphics(container);
		avatar.beginFill(0x3498DB);
		avatar.drawCircle(headerHeight * 0.5, headerHeight * 0.5, avatarRadius);
		avatar.endFill();

		// Никнейм - компактный
		var nickname = new h2d.Text(font, container);
		nickname.text = "Bot";
		nickname.textColor = 0xFFFFFF;
		nickname.x = headerHeight;
		nickname.y = headerHeight * 0.25;

		// Статус онлайн
		var status = new h2d.Text(font, container);
		status.text = "online";
		status.textColor = 0x2ECC71;
		status.x = headerHeight;
		status.y = headerHeight * 0.6;
		status.scale(0.8);
	}

	function createChatArea() {
		var headerHeight = uiHeight * 0.15;
		// Чат занимает всё пространство от хедера до низа красной области
		chatHeight = uiHeight - headerHeight;

		// Фон чата
		var chatBg = new h2d.Graphics(container);
		chatBg.beginFill(0xECF0F1);
		chatBg.drawRect(0, headerHeight, uiWidth, chatHeight);
		chatBg.endFill();

		// Создаём h2d.Mask для обрезки контента
		var chatMask = new h2d.Mask(Std.int(uiWidth), Std.int(chatHeight), container);
		chatMask.x = 0;
		chatMask.y = headerHeight;

		// Контейнер для сообщений (внутри маски)
		messageContainer = new h2d.Object(chatMask);
		messageContainer.x = 5;
		messageContainer.y = 5;
	}



	function sendBotMessage() {
		if (currentDialogIndex >= dialog.length) {
			// Диалог закончен
			addMessage("Thanks for chatting!", true);

			// Очищаем кнопки ответов
			answerButtonsContainer.removeChildren();
			return;
		}

		var dialogItem = dialog[currentDialogIndex];

		// Добавляем сообщение бота
		addMessage(dialogItem.botMessage, true);

		// Создаём кнопки с вариантами ответов
		showAnswerOptions(dialogItem.answers);
	}

	function addMessage(text:String, isBot:Bool) {
		// Текст сообщения (создаём сначала чтобы узнать размер)
		var msgText = new h2d.Text(font);
		msgText.text = text;
		msgText.textColor = isBot ? 0x000000 : 0xFFFFFF;
		msgText.maxWidth = Std.int(uiWidth - 20); // Адаптивная ширина

		// Рассчитываем размер пузыря на основе текста
		var bubbleWidth = Math.min(msgText.textWidth + 10, uiWidth - 10);
		var bubbleHeight = msgText.textHeight + 8;

		// Фон сообщения
		var msgBg = new h2d.Graphics(messageContainer);
		msgBg.y = messageYOffset;

		if (isBot) {
			msgBg.beginFill(0xFFFFFF);
			msgBg.x = 0;
		} else {
			msgBg.beginFill(0x3498DB);
			msgBg.x = (uiWidth - 10) - bubbleWidth; // Выравниваем справа
		}
		msgBg.drawRoundedRect(0, 0, bubbleWidth, bubbleHeight, 3);
		msgBg.endFill();

		// Добавляем текст в пузырь
		msgText.remove();
		msgBg.addChild(msgText);
		msgText.x = 5;
		msgText.y = 4;

		messageYOffset += bubbleHeight + 5; // Следующее сообщение ниже
		chatHistory.push({text: text, isBot: isBot});

		// Скроллим к последнему сообщению
		scrollToBottom();
	}

	function showAnswerOptions(answers:Array<String>) {
		// Очищаем предыдущие кнопки
		answerButtonsContainer.removeChildren();

		var yPos = 0.0;
		for (answer in answers) {
			createAnswerButton(answer, yPos);
			yPos += 30; // Компактный отступ
		}
	}

	function createAnswerButton(answerText:String, yPos:Float) {
		// Создаём текст для определения размера
		var btnText = new h2d.Text(font);
		btnText.text = answerText;
		btnText.textColor = 0xFFFFFF;

		// Кнопка на всю ширину красной области
		var btnWidth = uiWidth;
		var btnHeight = btnText.textHeight + 12;

		var btn = new h2d.Interactive(btnWidth, btnHeight, answerButtonsContainer);
		btn.x = 0;
		btn.y = yPos;
		btn.backgroundColor = 0x2ECC71;

		var btnBg = new h2d.Graphics(btn);
		btnBg.beginFill(0x2ECC71);
		btnBg.drawRoundedRect(0, 0, btnWidth, btnHeight, 5);
		btnBg.endFill();

		btnText.remove();
		btn.addChild(btnText);
		btnText.x = 5;
		btnText.y = 6;

		btn.onClick = function(_) {
			onAnswerSelected(answerText);
		};

		btn.onOver = function(_) {
			btnBg.clear();
			btnBg.beginFill(0x27AE60);
			btnBg.drawRoundedRect(0, 0, btnWidth, btnHeight, 3);
			btnBg.endFill();
		};

		btn.onOut = function(_) {
			btnBg.clear();
			btnBg.beginFill(0x2ECC71);
			btnBg.drawRoundedRect(0, 0, btnWidth, btnHeight, 3);
			btnBg.endFill();
		};
	}

	function onAnswerSelected(answer:String) {
		// Добавляем ответ игрока
		addMessage(answer, false);

		// Переходим к следующему сообщению бота
		currentDialogIndex++;

		// Небольшая задержка перед ответом бота
		haxe.Timer.delay(function() {
			sendBotMessage();
		}, 500);
	}

	function scrollToBottom() {
		// Если контент чата выше области просмотра, сдвигаем контейнер вверх
		var contentHeight = messageYOffset;
		var visibleHeight = chatHeight - 10; // -10 для отступов

		if (contentHeight > visibleHeight) {
			// Сдвигаем messageContainer вверх, чтобы последнее сообщение было видно
			messageContainer.y = 5 - (contentHeight - visibleHeight);
		}
	}
}
