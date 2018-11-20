﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВнешняяОбработкаОбъектСсылка = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ДополнительнаяОбработкаСсылка");
	ИдентификаторКоманды = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ИдентификаторКоманды");
	ИмяПередаваемойФормы = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ИмяФормы");
	ОбъектыНазначения = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ОбъектыНазначения");
	ТипОбъекта = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "МенеджерПечати");
	
	Если НЕ ЗначениеЗаполнено(ОбъектыНазначения)
		ИЛИ НЕ ЗначениеЗаполнено(ИмяПередаваемойФормы) Тогда
		
		ВызватьИсключение НСтр("ru='Непосредственное открытие этой формы не предусмотрено.'");
		
	КонецЕсли;
	
	Если ОбъектыНазначения <> Неопределено Тогда
		Объекты.ЗагрузитьЗначения(ОбъектыНазначения);
	КонецЕсли;
	
	// Формирования состава печатных форм
	КомандыПечати = УправлениеПечатью.КомандыПечатиФормы(ИмяПередаваемойФормы);
	
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
	
	// Отсортируем таблицу печатных форм
	ТаблицаПечатныхФорм = КомплектПечатныхФорм.Выгрузить();
	СортироватьТаблицуПечатныхФормПоУмолчанию(ТаблицаПечатныхФорм);
	КомплектПечатныхФорм.Загрузить(ТаблицаПечатныхФорм);
	
	ЗаполнитьСписокВыбораПапкиДляСохранения(ОбъектыНазначения);
	
	// Если не настроена печать факсимиле
	РезультатПроверки = ПроверитьЗаполнениеПечатиПодписейОрганизации(ОбъектыНазначения, Истина);
	
	УправлениеПечатьюБП.ОформитьВыводРеквизитаподписьИПечать(Элементы.ПечатьИПодписи, Элементы.ГруппаПечатьПодписи, РезультатПроверки);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	МассивСохраненныхПутей = Элементы.ПутьКФайлам.СписокВыбора.ВыгрузитьЗначения();
	Если МассивСохраненныхПутей.Количество() = 0 Тогда
		ЗаполнитьИсториюВыбораПоУмолчанию();
	Иначе
		// Выберем последний сохраненный путь.
		ПутьКФайлам = МассивСохраненныхПутей[МассивСохраненныхПутей.Количество()-1];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаНавигационнойСсылки(НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	УправлениеПечатьюБПКлиент.ОбработкаНавигационнойСсылки(ЭтотОбъект, 
		НавигационнаяСсылкаФорматированнойСтроки,
		СтандартнаяОбработка);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПутьКФайламНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ОписаниеОповещения = Новый ОписаниеОповещения("ПутьКФайламЗавершение", ЭтотОбъект);
	ДиалогВыбораФайла.Показать(ОписаниеОповещения);
	
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
Процедура ПроверитьСуществованиеИИзменитьИмяФайла(ИмяФайла, ПервоначальноеИмяФайла="", НомерЭкземпляра = 0)
	
	Файл = Новый Файл(ИмяФайла);
	Если ПустаяСтрока(ПервоначальноеИмяФайла) Тогда
		ПервоначальноеИмяФайла = СтрЗаменить(ИмяФайла, ".pdf", "");
	КонецЕсли;
	Если Файл.Существует() Тогда
		НомерЭкземпляра = НомерЭкземпляра + 1;
		ИмяФайла = СтрШаблон(НСтр("ru='%1 (%2).pdf'"), ПервоначальноеИмяФайла, НомерЭкземпляра);
		ПроверитьСуществованиеИИзменитьИмяФайла(ИмяФайла, ПервоначальноеИмяФайла, НомерЭкземпляра);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	СохранитьПутьКФайламНаСервере();
	
	Если КомплектПечатныхФорм.НайтиСтроки(Новый Структура("Печатать", Истина)).Количество() > 0 Тогда
		
		ИменаМакетов = ПодготовитьНастройкиДляПечати();
		
		Если НЕ Предпросмотр Тогда
			
			Для Каждого Документ Из Объекты.ВыгрузитьЗначения() Цикл
				
				МассивДокументов = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Документ);
				ПечатныеФормы = УправлениеПечатьюВызовСервера.СформироватьПечатныеФормыДляБыстройПечати(
					ТипОбъекта, ИменаМакетов, МассивДокументов, Новый Структура("ФиксированныйКомплект", Истина));
				ИмяФайла = ИмяФайла(Документ);
				ПроверитьСуществованиеИИзменитьИмяФайла(ИмяФайла);
				СохранитьФайлПакета(ИмяФайла, ПечатныеФормы.ТабличныеДокументы);
				
			КонецЦикла;
		Иначе
			
			// Получим ключ уникальности открываемой формы.
			КлючУникальности = Строка(Новый УникальныйИдентификатор);
			
			ПараметрыОткрытия = Новый Структура("ИмяМенеджераПечати,ИменаМакетов,ПараметрКоманды,ПараметрыПечати,ПутьКФайлам");
			ПараметрыОткрытия.ИмяМенеджераПечати = ТипОбъекта;
			ПараметрыОткрытия.ИменаМакетов		 = ИменаМакетов;
			ПараметрыОткрытия.ПараметрКоманды	 = Объекты.ВыгрузитьЗначения();
			ПараметрыОткрытия.ПараметрыПечати	 = Неопределено;
			ПараметрыОткрытия.ПутьКФайлам		 = ПутьКФайлам;
			
			// Откроем форму печати документов.
			ОткрытьФорму("ВнешняяОбработка.КомплектДокументовВPDF.Форма.ПечатьДокументов", ПараметрыОткрытия, ЭтотОбъект, КлючУникальности);
			
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

#Область ВыводФаксимиле

&НаСервере
Процедура УправлениеКартинкойФаксимиле(РабочаяПечатнаяФорма, МассивИменПоказателей, Добавить = Истина)
	
	МассивИменОбластей = Новый Массив;
	Для Каждого ОбластьМакета ИЗ РабочаяПечатнаяФорма.Области Цикл
		Если СтрНайти(ОбластьМакета.Имя, "РасшифровкаФаксимилеМакета") <> 0 Тогда
			МассивИменОбластей.Добавить(ОбластьМакета.Имя);
		КонецЕсли;
	КонецЦикла;
	
	ЦветФонаБелый = Новый Цвет(255,255,255);
	ЦветФонаАвто  = Новый Цвет();
	
	Для Каждого ИмяОбластиМакета ИЗ МассивИменОбластей Цикл
		
		ОбластьМакета = РабочаяПечатнаяФорма.Области[ИмяОбластиМакета];
		Если НЕ ЭтоАдресВременногоХранилища(ОбластьМакета.Расшифровка) Тогда
			Продолжить;
		КонецЕсли;
		
		ДанныеФаксимиле = ПолучитьИзВременногоХранилища(ОбластьМакета.Расшифровка);
		Если ТипЗнч(ДанныеФаксимиле) <> Тип("Структура") Тогда
			Продолжить;
		КонецЕсли;
		
		Для Каждого ЗначениеПоказателя ИЗ МассивИменПоказателей Цикл
			
			Если НЕ ДанныеФаксимиле.Свойство(ЗначениеПоказателя) Тогда
				Продолжить;
			КонецЕсли;
			
			СтруктураЗначений = ДанныеФаксимиле[ЗначениеПоказателя];
			
			ИмяОбластиФаксимиле = ЗначениеПоказателя + "_" + СтруктураЗначений.ОбластьВладелец;
			
			АдресКартинки = СтруктураЗначений.ДанныеКартинки;
			
			Если Добавить И ЗначениеЗаполнено(АдресКартинки) Тогда
				
				ОбластьКартинки = РабочаяПечатнаяФорма.Области[СтруктураЗначений.ОбластьВладелец];
				
				РисунокТабличногоДокумента = РабочаяПечатнаяФорма.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Картинка);
				РисунокТабличногоДокумента.Имя = ИмяОбластиФаксимиле;
				РисунокТабличногоДокумента.Линия = Новый Линия(ТипЛинииРисункаТабличногоДокумента.НетЛинии);
				РисунокТабличногоДокумента.РазмерКартинки = РазмерКартинки.Пропорционально;
				РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].Картинка = ПолучитьИзВременногоХранилища(АдресКартинки);
				РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].Расположить(ОбластьКартинки);
				РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].Верх           = СтруктураЗначений.Верх;
				РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].Лево           = СтруктураЗначений.Лево;
				РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].Высота         = СтруктураЗначений.Высота;
				РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].Ширина         = СтруктураЗначений.Ширина;
				Если СтрНайти(РисунокТабличногоДокумента.Имя, "ФаксимильнаяПечать") > 0 Тогда
					РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].ЦветФона   = ЦветФонаБелый;
				Иначе
					РабочаяПечатнаяФорма.Рисунки[РисунокТабличногоДокумента.Имя].ЦветФона   = ЦветФонаАвто;
				КонецЕсли;
			Иначе
				
				Если РабочаяПечатнаяФорма.Области.Найти(ИмяОбластиФаксимиле) <> Неопределено Тогда
					РабочаяПечатнаяФорма.Рисунки.Удалить(ИмяОбластиФаксимиле);
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЦикла
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция МассивИменПоказателейФаксимиле()
	
	МассивИменПоказателей = Новый Массив;
	МассивИменПоказателей.Добавить("ФаксимилеПечать");
	МассивИменПоказателей.Добавить("ФаксимилеПечатьПредприниматель");
	МассивИменПоказателей.Добавить("ФаксимилеРуководитель");
	МассивИменПоказателей.Добавить("ФаксимилеРуководительНакладная");
	МассивИменПоказателей.Добавить("ФаксимилеПредприниматель");
	МассивИменПоказателей.Добавить("ФаксимилеГлавныйБухгалтер");
	МассивИменПоказателей.Добавить("ФаксимилеОтветственныйЗаОформление");
	МассивИменПоказателей.Добавить("ФаксимилеИсполнитель");
	МассивИменПоказателей.Добавить("ФаксимилеИсполнительНакладнаяУслуги");
	МассивИменПоказателей.Добавить("ФаксимилеИсполнительНакладнаяМатериалы");
	МассивИменПоказателей.Добавить("ФаксимилеКладовщик");
	// для совместимости - подвал Счета
	МассивИменПоказателей.Добавить("ФаксимильнаяПечать");
	МассивИменПоказателей.Добавить("ФаксимильнаяПечатьПредприниматель");
	
	Возврат МассивИменПоказателей;
	
КонецФункции

#Область НаличиеФаксимиле

// Собирает данные для проверки заполнения необходимых реквизитов пред печатью с факсимильной подписью.
//
// Параметры:
//  МассивДокументов - Массив - массив ссылок на документы одного типа.
//
// Возвращаемое значение:
//  Структура:
//    * НужноЗаполнить - Булево- нужно заполнить реквизиты.
//    * Организация - СправочникСсылка.Организации - организация документов.
//    * ПредложитьНастроить - Булево - у пользователя достаточно прав для настройки.
//
Функция ПроверитьЗаполнениеПечатиПодписейОрганизации(МассивДокументов, ФаксимилеДоступноДляВывода)
	
	РезультатПроверки = Новый Структура;
	РезультатПроверки.Вставить("Организация", Справочники.Организации.ПустаяСсылка());
	РезультатПроверки.Вставить("НужноЗаполнить", Ложь);
	РезультатПроверки.Вставить("ПредложитьНастроить", Ложь);
	РезультатПроверки.Вставить("ФаксимилеДоступноДляВывода", ФаксимилеДоступноДляВывода);
	
	НужноЗаполнить = НЕ ФаксимилеДоступноДляВывода;
		
	ОрганизацииДокументов = ОрганизацииДокументовДляПечати(МассивДокументов);
	Если ОрганизацииДокументов.Количество() = 1 Тогда
		
		Организация = ОрганизацииДокументов[0];
		
		РезультатПроверки.Организация = Организация;
		
		Если ФаксимилеДоступноДляВывода Тогда
			ПроверяемыеРеквизиты = Новый Массив;
			ПроверяемыеРеквизиты.Добавить("ФайлПодписьРуководителя");
			ПроверяемыеРеквизиты.Добавить("ФайлПечать");
			ПроверяемыеРеквизиты.Добавить("ФайлПодписьГлавногоБухгалтера");
			
			НужноЗаполнить = Не ЗаполненыПечатьИПодписи(Организация, ПроверяемыеРеквизиты);
		
			Если НужноЗаполнить Тогда
				НужноЗаполнить = Не ЗаполненыПечатьИПодписи(Организация,
					ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве("ФайлФаксимильнаяПечать"));
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	РезультатПроверки.НужноЗаполнить      = НужноЗаполнить;
	РезультатПроверки.ПредложитьНастроить = НужноЗаполнить 
											И ПравоДоступа("Редактирование", Метаданные.Справочники.Организации);
	
	Возврат РезультатПроверки;
	
КонецФункции

Функция ОрганизацииДокументовДляПечати(МассивДокументов)
	
	Организации = Новый Массив;
	
	Если МассивДокументов.Количество() = 0 Тогда
		Возврат Организации;
	КонецЕсли;
	
	МетаданныеДокумента = МассивДокументов[0].Метаданные();
	Если НЕ Метаданные.Документы.Содержит(МетаданныеДокумента) Тогда
		Возврат Организации;
	КонецЕсли;
		
	МетаданныеИмя = МетаданныеДокумента.ПолноеИмя();
	Если ОбщегоНазначения.ЕстьРеквизитОбъекта("ОрганизацияПолучатель", МетаданныеДокумента) Тогда
		ИмяРеквизита = "ОрганизацияПолучатель";
	Иначе
		ИмяРеквизита = "Организация";
	КонецЕсли;
	
	СхемаЗапроса = Новый СхемаЗапроса;
	
	ПакетЗапроса = СхемаЗапроса.ПакетЗапросов[0];
	Оператор = ПакетЗапроса.Операторы[0];
	Оператор.Источники.Добавить(МетаданныеИмя, "Документ");
	Оператор.ВыбиратьРазличные = Истина;
	Оператор.ВыбираемыеПоля.Добавить("Документ." + ИмяРеквизита);
	ПакетЗапроса.Колонки[0].Псевдоним = "Организация";
	Оператор.Отбор.Добавить("Документ.Ссылка В(&Документы)");
	
	Запрос = Новый Запрос;
	Запрос.Текст = СхемаЗапроса.ПолучитьТекстЗапроса();
	Запрос.УстановитьПараметр("Документы", МассивДокументов);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Организации.Добавить(Выборка.Организация);
	КонецЦикла;
	
	Возврат Организации;
	
КонецФункции

Функция ЗаполненыПечатьИПодписи(Организация, ПроверяемыеРеквизиты)
	
	РеквизитыЗаполнены = Ложь;
	
	Если ЗначениеЗаполнено(Организация) И ПроверяемыеРеквизиты.Количество() <> 0 Тогда
		
		ЗначенияРеквизитовОрганизации = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(
			Организация,
			Новый ФиксированныйМассив(ПроверяемыеРеквизиты));
		
		Для Каждого Реквизит Из ЗначенияРеквизитовОрганизации Цикл
			Если НЕ Реквизит.Значение.Пустая() Тогда
				РеквизитыЗаполнены = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат РеквизитыЗаполнены;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СохранениеПакета

&НаСервере
Процедура СохранитьФайлПакета(ИмяФайла, ТабличныеДокументы)
	
	Пакет = Новый ПакетОтображаемыхДокументов;
	Пакет.КоличествоЭкземпляров = 1;
	МассивИменПоказателей = МассивИменПоказателейФаксимиле();
	
	Для Каждого ТабличныйДокумент Из ТабличныеДокументы Цикл
		ЭлементПакета = Пакет.Состав.Добавить();
		УправлениеКартинкойФаксимиле(ТабличныйДокумент.Значение, МассивИменПоказателей, ВывестиПечатьИПодписи);
		ЭлементПакета.Данные = ПоместитьВоВременноеХранилище(ТабличныйДокумент.Значение, УникальныйИдентификатор);
	КонецЦикла;
	
	Пакет.ЗаписатьФайлДляПечати(ИмяФайла);
	
КонецПроцедуры

&НаСервере
Функция ИмяФайла(Документ)
	
	// см. функцию ИмяФайла() в модуле объекта внешней обработки.
	Возврат РеквизитФормыВЗначение("Объект").ИмяФайла(ПутьКФайлам, Документ, КомплектПечатныхФорм);
	
КонецФункции

&НаКлиенте
Процедура ПутьКФайламЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПутьКФайлам = Результат[0];
	
КонецПроцедуры

&НаСервере
Процедура СортироватьТаблицуПечатныхФормПоУмолчанию(ТаблицаПечатныхФорм)
	
	// см. функцию СортироватьТаблицуПечатныхФормПоУмолчанию() в модуле объекта внешней обработки.
	РеквизитФормыВЗначение("Объект").СортироватьТаблицуПечатныхФормПоУмолчанию(ТаблицаПечатныхФорм);
	
КонецПроцедуры

#КонецОбласти

#Область СохранениеПутейКФайлам

&НаСервере
Процедура ОграничитьМассивПутей(МассивПутей)
	
	КоличествоЭлементовВМассиве = МассивПутей.Количество();
	КоличествоОбъектовИстории = КоличествоОбъектовИстории();
	Если КоличествоЭлементовВМассиве <= КоличествоОбъектовИстории Тогда
		Возврат;
	КонецЕсли;
	
	ЭлементСКоторогоНачать = КоличествоЭлементовВМассиве - КоличествоОбъектовИстории;
	ОграниченныйМассивПутей = Новый Массив;
	
	Для Счетчик = 0 По КоличествоОбъектовИстории - 1 Цикл
		ОграниченныйМассивПутей.Добавить(МассивПутей[ЭлементСКоторогоНачать + Счетчик]);
	КонецЦикла;
	
	МассивПутей = ОграниченныйМассивПутей;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьИсториюВыбораПоУмолчанию()
	
	МассивЗначений = Элементы.ПутьКФайлам.СписокВыбора.ВыгрузитьЗначения();
	МассивЗначений.Добавить(КаталогДокументов());
	Если НЕ ПустаяСтрока(ПутьКФайлам) Тогда
		МассивЗначений.Добавить(ПутьКФайлам);
	КонецЕсли;
	ПутьКФайлам = МассивЗначений[МассивЗначений.Количество()-1]; // Установим последний элемент.
	Элементы.ПутьКФайлам.СписокВыбора.ЗагрузитьЗначения(МассивЗначений);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокВыбораПапкиДляСохранения(ОбъектыНазначения)
	
	Если ОбъектыНазначения.Количество() > 0 Тогда
		ОбъектПечати = ОбъектыНазначения[0];
		КлючНастройкиСохраненияПутей = Метаданные.НайтиПоТипу(ТипЗнч(ОбъектПечати)).Имя;
	Иначе
		КлючНастройкиСохраненияПутей = "ОбщиеОбъекты";
	КонецЕсли;
	
	СтруктураПутей = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		ИмяНастройкиХраненияФайлов(),
		ИмяКлючНастройкиХраненияФайлов(),
		Неопределено);
		
	Если СтруктураПутей = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ СтруктураПутей.Свойство(КлючНастройкиСохраненияПутей) Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.ПутьКФайлам.СписокВыбора.ЗагрузитьЗначения(СтруктураПутей[КлючНастройкиСохраненияПутей]);
	
КонецПроцедуры

&НаСервере
Функция ИмяНастройкиХраненияФайлов()

	Возврат "Расширение_ХранениеПутейКФайлам";

КонецФункции

&НаСервере
Функция ИмяКлючНастройкиХраненияФайлов()

	Возврат "МассивПутей";

КонецФункции

&НаСервере
Функция КоличествоОбъектовИстории()

	Возврат 5;

КонецФункции

&НаСервере
Процедура СохранитьПутьКФайламНаСервере()
	
	СтруктураПутей = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		ИмяНастройкиХраненияФайлов(),
		ИмяКлючНастройкиХраненияФайлов(),
		Новый Структура);
		
	Если СтруктураПутей.Свойство(КлючНастройкиСохраненияПутей) Тогда
		МассивПутей = СтруктураПутей[КлючНастройкиСохраненияПутей];
	Иначе
		МассивПутей = Новый Массив;
	КонецЕсли;
	
	НайденныйПуть = МассивПутей.Найти(ПутьКФайлам);
	Если НайденныйПуть = Неопределено Тогда
		МассивПутей.Добавить(ПутьКФайлам);
		ОграничитьМассивПутей(МассивПутей);
		СтруктураПутей.Вставить(КлючНастройкиСохраненияПутей, МассивПутей);
		
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(
			ИмяНастройкиХраненияФайлов(),
			ИмяКлючНастройкиХраненияФайлов(),
			СтруктураПутей);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

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
			КоличествоМакетовДляПечати = ?(Предпросмотр, ПечатнаяФорма.Копий, 1);
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

#КонецОбласти