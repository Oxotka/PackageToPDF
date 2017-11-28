﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВнешняяОбработкаОбъектСсылка = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ДополнительнаяОбработкаСсылка");
	ИдентификаторКоманды = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ИдентификаторКоманды");
	ИмяФормы1 = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ИмяФормы");
	ОбъектыНазначения = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ОбъектыНазначения");
	ТипОбъекта = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "МенеджерПечати");
	
	Если НЕ ЗначениеЗаполнено(ОбъектыНазначения)
		ИЛИ НЕ ЗначениеЗаполнено(ИмяФормы1) Тогда
		
		//ВызватьИсключение НСтр("ru='Непосредственное открытие этой формы не предусмотрено.'");
		
	КонецЕсли;
	
	Если ОбъектыНазначения <> Неопределено Тогда
		Объекты.ЗагрузитьЗначения(ОбъектыНазначения);
	КонецЕсли;
	
	// Формирования состава печатных форм
	КомандыПечати = УправлениеПечатью.КомандыПечатиФормы(ИмяФормы1);
	
	Идентификатор = "";
	Для Каждого КомандаПечати Из КомандыПечати Цикл
		
		Если КомандаПечати.ДополнительныеПараметры.Свойство("НеВыводитьВКомплекте") Тогда
			Продолжить;
		КонецЕсли;
		
		Если КомандаПечати.СкрытаФункциональнымиОпциями Тогда
			Продолжить;
		КонецЕсли;
		
		НоваяСтрока = КомплектПечатныхФорм.Добавить();
		Если КомандаПечати.ДополнительныеПараметры.Свойство("ИдентификаторВКомплекте") Тогда
			НоваяСтрока.Имя = КомандаПечати.ДополнительныеПараметры.ИдентификаторВКомплекте;
		Иначе
			НоваяСтрока.Имя = КомандаПечати.Идентификатор;
		КонецЕсли;
		НоваяСтрока.МенеджерПечати = КомандаПечати.МенеджерПечати;
		НоваяСтрока.Представление = КомандаПечати.Представление;
		НоваяСтрока.Порядок = КомандаПечати.Порядок;
		
		Если КомандаПечати.МенеджерПечати <> "СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки" Тогда
			Идентификатор = Идентификатор + НоваяСтрока.Имя + ",";
		КонецЕсли;
		
	КонецЦикла;
	
	// Загрузка сохраненных настроек
	Если Идентификатор <> "" Тогда
		Идентификатор = Лев(Идентификатор, СтрДлина(Идентификатор) - 1);
	КонецЕсли;
	
	КлючНастроек = Параметры.МенеджерПечати + "-" + Идентификатор;
	СохраненныеНастройкиПечатныхФорм = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("НастройкиПечатныхФормКомплект", КлючНастроек, Новый Массив);
	
	ВосстановитьНастройкиПечатныхФорм(СохраненныеНастройкиПечатныхФорм, Параметры.ИмяФормы);
	СформироватьИмяФайла();
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	СформироватьИмяФайла();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийТаблицыФормыСписок

&НаКлиенте
Процедура КомплектПечатныхФормПечататьПриИзменении(Элемент)
	
	НастройкаПечатнойФормы = ТекущаяНастройкаПечатнойФормы();
	Если НастройкаПечатнойФормы.Печатать И НастройкаПечатнойФормы.Копий = 0 Тогда
		НастройкаПечатнойФормы.Копий = 1;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОбновитьМакеты(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Если КомплектПечатныхФорм.НайтиСтроки(Новый Структура("Печатать", Истина)).Количество() > 0 Тогда
		
		ИменаМакетов = ПодготовитьНастройкиДляПечати();
		
		Если СразуСохранять Тогда
			
			УправлениеПечатьюКлиент.ВыполнитьКомандуПечатиНаПринтер(
				ТипОбъекта,
				ИменаМакетов,
				Объекты.ВыгрузитьЗначения(),
				Новый Структура("ФиксированныйКомплект", Истина));
				
		Иначе
			
			ПечатныеФормы = УправлениеПечатьюВызовСервера.СформироватьПечатныеФормыДляБыстройПечати(
				ТипОбъекта, ИменаМакетов, Объекты.ВыгрузитьЗначения(), Новый Структура("ФиксированныйКомплект", Истина));
			
			СохранитьФайлПакета(ПечатныеФормы.ТабличныеДокументы);
				
		КонецЕсли;
		
		Если Не ПустаяСтрока(КлючНастроек) Тогда
			СохраняемыеНастройкиПечатныхФорм = Новый Массив;
			Для Каждого НастройкаПечати Из КомплектПечатныхФорм Цикл
				СохраняемаяНастройка = Новый Структура("Имя, Копий, Печатать");
				ЗаполнитьЗначенияСвойств(СохраняемаяНастройка, НастройкаПечати);
				СохраняемыеНастройкиПечатныхФорм.Добавить(СохраняемаяНастройка);
			КонецЦикла;
			СохранитьНастройкиПечатныхФорм("НастройкиПечатныхФормКомплект", КлючНастроек, СохраняемыеНастройкиПечатныхФорм);
		КонецЕсли;
		
		Закрыть();
		
	Иначе
		
		ОчиститьСообщения();
		ТекстСообщения = НСтр("ru = 'Выберите хотя бы одну печатную форму для печати.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "КомплектПечатныхФорм");
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СохранитьФайлПакета(ТабличныеДокументы)
	
	Пакет = Новый ПакетОтображаемыхДокументов;
	Пакет.КоличествоЭкземпляров = 1;
	
	Для Каждого ТабличныйДокумент Из ТабличныеДокументы Цикл
		ЭлементПакета = Пакет.Состав.Добавить();
		ЭлементПакета.Данные = ПоместитьВоВременноеХранилище(ТабличныйДокумент.Значение, УникальныйИдентификатор);
	КонецЦикла;
	
	Пакет.ЗаписатьФайлДляПечати(ИмяФайла);
	
КонецПроцедуры

&НаКлиенте
Функция ПодготовитьНастройкиДляПечати()

	ИменаМакетов = "";
	СохраняемыеНастройкиПечатныхФорм = Новый Массив;
	Индекс = 0;
	Для Каждого ПечатнаяФорма Из КомплектПечатныхФорм Цикл
		Если ПечатнаяФорма.Печатать Тогда
			Если ПечатнаяФорма.Копий = 0 Тогда
				ПечатнаяФорма.Копий = 1;
			КонецЕсли;
			Если ПечатнаяФорма.МенеджерПечати <> ТипОбъекта Тогда
				Если ПечатнаяФорма.МенеджерПечати = "СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки" Тогда
					ИмяМакета = "ВнешняяПечатнаяФорма." + ПечатнаяФорма.Имя;
				Иначе
					ИмяМакета = ПечатнаяФорма.МенеджерПечати + "." + ПечатнаяФорма.Имя;
				КонецЕсли;
			Иначе
				ИмяМакета = ПечатнаяФорма.Имя;
			КонецЕсли;
			Если ПечатнаяФорма.Имя = "СчетФактураКомплект" Тогда
				КоличествоМакетовСчетовФактур = КоличествоМакетовСчетовФактур();
				Если КоличествоМакетовСчетовФактур > 1 Тогда
					Для Счетчик = 1 По КоличествоМакетовСчетовФактур - 1 Цикл
						СохраняемаяНастройка = Новый Структура;
						СохраняемаяНастройка.Вставить("ИмяМакета", ПечатнаяФорма.Имя);
						СохраняемаяНастройка.Вставить("Количество", ПечатнаяФорма.Копий);
						СохраняемаяНастройка.Вставить("ПозицияПоУмолчанию", Индекс);
						СохраняемыеНастройкиПечатныхФорм.Добавить(СохраняемаяНастройка);
						Индекс = Индекс + 1;
					КонецЦикла;
				КонецЕсли;
			КонецЕсли;
			СохраняемаяНастройка = Новый Структура;
			СохраняемаяНастройка.Вставить("ИмяМакета", ПечатнаяФорма.Имя);
			СохраняемаяНастройка.Вставить("Количество", ПечатнаяФорма.Копий);
			СохраняемаяНастройка.Вставить("ПозицияПоУмолчанию", Индекс);
			СохраняемыеНастройкиПечатныхФорм.Добавить(СохраняемаяНастройка);
			Индекс = Индекс + 1;

			// Для печати сразу на принтер строка с именами макетов
			// должна содержать столько имен макетов, сколько копий требуется напечатать.
			КоличествоМакетовДляПечати = ?(СразуСохранять, ПечатнаяФорма.Копий, 1);
			Для Сч =1 по КоличествоМакетовДляПечати Цикл
				ИменаМакетов = ИменаМакетов +"," + ИмяМакета;
			КонецЦикла;
			
		КонецЕсли;
	КонецЦикла;
	
	ИменаМакетов = Сред(ИменаМакетов, 2);
	
	// Сохранение настроек
	КлючНастроекПечати = ТипОбъекта + "-" + ИменаМакетов;
	Если Не ПустаяСтрока(ИменаМакетов) Тогда
		СохранитьНастройкиПечатныхФорм("НастройкиПечатныхФорм",КлючНастроекПечати, СохраняемыеНастройкиПечатныхФорм);
	КонецЕсли;
	
	Возврат ИменаМакетов;

КонецФункции

&НаСервере
Процедура ВосстановитьНастройкиПечатныхФорм(СохраненныеНастройкиПечатныхФорм, ИмяФормы)

	Если СохраненныеНастройкиПечатныхФорм = Неопределено
		ИЛИ (ТипЗнч(СохраненныеНастройкиПечатныхФорм) = Тип("Массив")
				И СохраненныеНастройкиПечатныхФорм.Количество() = 0) Тогда
		ВосстановитьНастройкиПечатныхФормПоУмолчанию(ИмяФормы);
	КонецЕсли;
	
	Для Каждого СохраненнаяНастройка Из СохраненныеНастройкиПечатныхФорм Цикл
		НайденныеНастройки = КомплектПечатныхФорм.НайтиСтроки(Новый Структура("Имя", СохраненнаяНастройка.Имя));
		Для Каждого НастройкаПечатнойФормы Из НайденныеНастройки Цикл
			НастройкаПечатнойФормы.Копий = СохраненнаяНастройка.Копий;
			НастройкаПечатнойФормы.Печатать = СохраненнаяНастройка.Печатать;
		КонецЦикла;
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ВосстановитьНастройкиПечатныхФормПоУмолчанию(ИмяФормы)

	Если ТипОбъекта = "Документ.РеализацияТоваровУслуг" Тогда
		
		Если ИмяФормы = "Документ.РеализацияТоваровУслуг.Форма.ФормаДокументаУслуги" Тогда
			НайденныеНастройки =
				КомплектПечатныхФорм.НайтиСтроки(Новый Структура("Имя", "Акт"));
			Для Каждого НастройкаПечатнойФормы Из НайденныеНастройки Цикл
				НастройкаПечатнойФормы.Копий = 2;
				НастройкаПечатнойФормы.Печатать = Истина;
			КонецЦикла;
			НайденныеНастройки =
				КомплектПечатныхФорм.НайтиСтроки(Новый Структура("Имя", "СчетФактураКомплект"));
			Для Каждого НастройкаПечатнойФормы Из НайденныеНастройки Цикл
				НастройкаПечатнойФормы.Копий = 2;
				НастройкаПечатнойФормы.Печатать = Истина;
			КонецЦикла;
		ИначеЕсли ИмяФормы = "Документ.РеализацияТоваровУслуг.Форма.ФормаДокументаТовары" Тогда
			НайденныеНастройки =
				КомплектПечатныхФорм.НайтиСтроки(Новый Структура("Имя", "ТОРГ12_БезУслуг"));
			Для Каждого НастройкаПечатнойФормы Из НайденныеНастройки Цикл
				НастройкаПечатнойФормы.Копий = 2;
				НастройкаПечатнойФормы.Печатать = Истина;
			КонецЦикла;
			НайденныеНастройки =
				КомплектПечатныхФорм.НайтиСтроки(Новый Структура("Имя", "СчетФактураКомплект"));
			Для Каждого НастройкаПечатнойФормы Из НайденныеНастройки Цикл
				НастройкаПечатнойФормы.Копий = 2;
				НастройкаПечатнойФормы.Печатать = Истина;
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Процедура СохранитьНастройкиПечатныхФорм(КлючОбъекта, КлючНастроек, СохраняемыеНастройкиПечатныхФорм)

	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(КлючОбъекта, КлючНастроек, СохраняемыеНастройкиПечатныхФорм);

КонецПроцедуры

&НаКлиенте
Функция КоличествоМакетовСчетовФактур()
	
	НастройкиПечати = УчетНДСВызовСервера.ПолучитьНастройкиПечатиСчетовФактур(Объекты.ВыгрузитьЗначения());
	СписокМакетов = НастройкиПечати.СписокМакетов;
	МассивМакетов = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(НастройкиПечати.СписокМакетов);
	Возврат МассивМакетов.Количество();
	
КонецФункции

&НаКлиенте
Функция ТекущаяНастройкаПечатнойФормы()
	
	Результат = Элементы.КомплектПечатныхФорм.ТекущиеДанные;
	Если Результат = Неопределено И КомплектПечатныхФорм.Количество() > 0 Тогда
		Результат = КомплектПечатныхФорм[0];
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ПутьКФайламНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ОписаниеОповещения = Новый ОписаниеОповещения("ПутьКФайламЗавершение", ЭтотОбъект);
	ДиалогВыбораФайла.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьКФайламЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПутьКФайлам = Результат[0];
	СформироватьИмяФайла();
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьКФайламПриИзменении(Элемент)
	
	СформироватьИмяФайла();
	
КонецПроцедуры

&НаСервере
Процедура СформироватьИмяФайла()
	
	ПутьКФайламСРазделителем = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПутьКФайлам);
	ИмяФайла = ПутьКФайламСРазделителем + ИмяДокумента(Объекты);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ИмяДокумента(Объекты)

	// TODO Научить работать с несколькими объектами
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Объекты[0].Значение);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Контрагент КАК Контрагент,
	|	ДанныеПервичныхДокументов.Номер КАК Номер,
	|	ДанныеПервичныхДокументов.Дата КАК Дата
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДанныеПервичныхДокументов КАК ДанныеПервичныхДокументов
	|		ПО ДанныеПервичныхДокументов.Документ = РеализацияТоваровУслуг.Ссылка
	|ГДЕ
	|	РеализацияТоваровУслуг.Ссылка = &Ссылка";
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат СтрШаблон("РТУ № %1 от %2 (%3).pdf", Выборка.Номер, Формат(Выборка.Дата,"ДЛФ=D"), Выборка.Контрагент);
	Иначе
		// Наименование по умолчанию
		Возврат "КомплектДокументов.pdf"
	КонецЕсли;

КонецФункции

#КонецОбласти