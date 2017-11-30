﻿
#Область ПрограммныйИнтерфейс

// Возвращает сведения о внешней обработке.
Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиПечатнаяФорма();
	ПараметрыРегистрации.Версия = "1.0";
	ПараметрыРегистрации.Назначение.Добавить("Документ.РеализацияТоваровУслуг");
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	ПараметрыРегистрации.Наименование = НСтр("ru='Комплект документов в PDF'");
	ПараметрыРегистрации.Информация = НСтр("ru='Сохранение комплекта документов в один файл PDF'");
	
	// Комплект документов в PDF
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = НСтр("ru = 'Комплект документов в PDF'");
	НоваяКоманда.Идентификатор = "КомплектДокументовВPDF";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Истина;
	НоваяКоманда.Модификатор = "ПечатьMXL";
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Функция ИмяФайла(ПутьКФайлам, Документ, КомплектПечатныхФорм) Экспорт
	
	СтруктураОтбора = Новый Структура("Печатать", Истина);
	ТаблицаПечатныхФорм = КомплектПечатныхФорм.Выгрузить(СтруктураОтбора, "Представление");
	Префикс = "рту";
	ЕстьСчетФактура = Ложь;
	
	Для Каждого СтрокаТаблицы Из ТаблицаПечатныхФорм Цикл
		Если СтрНачинаетсяС(СтрокаТаблицы.Представление, "Счет-фактура") Тогда
			ЕстьСчетФактура = Истина;
		КонецЕсли;
		
		Если СтрНачинаетсяС(СтрокаТаблицы.Представление, "Универсальный") Тогда
			Префикс = "упд"
		ИначеЕсли СтрНачинаетсяС(СтрокаТаблицы.Представление, "Товарная накладная") И НЕ Префикс = "упд" Тогда
			Префикс = "тн"
		КонецЕсли;
		
	КонецЦикла;
	
	РеквизитыДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Документ, "Номер, Дата, Контрагент");
	
	ИмяФайла = СтрШаблон("%1 № %2 от %3 - %4.pdf", 
		Префикс,
		ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(РеквизитыДокумента.Номер, Истина, Ложь),
		Формат(РеквизитыДокумента.Дата,"ДЛФ=D"), 
		РеквизитыДокумента.Контрагент);	
		
	Возврат ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПутьКФайлам) + ИмяФайла;

КонецФункции

Процедура СортироватьТаблицуПечатныхФормПоУмолчанию(ТаблицаПечатныхФорм) Экспорт

	// Список печатных форм для РТУ:
	//
	// Товарная накладная (ТОРГ-12)
	// Товарная накладная (ТОРГ-12) с услугами
	// Акт об оказании услуг
	// Комплект документов в PDF
	// Счет на оплату
	// Счет на оплату (с печатью и подписями)
	// Счет-фактура
	// Универсальный передаточный документ (УПД)
	// Транспортная накладная
	// Товарно-транспортная накладная (1-Т)
	// Накладная на отпуск материалов на сторону (М-15)
	// Расходная накладная
	
	ТаблицаПечатныхФорм.Колонки.Добавить("ПорядокСортировки", ОбщегоНазначения.ОписаниеТипаСтрока(3));
	Для Каждого СтрокаТаблицы Из ТаблицаПечатныхФорм Цикл
		Если СтрНачинаетсяС(СтрокаТаблицы.Представление, "Универсальный") Тогда
			СтрокаТаблицы.ПорядокСортировки = 010;
		ИначеЕсли СтрНачинаетсяС(СтрокаТаблицы.Представление, "Товарная накладная") Тогда
			СтрокаТаблицы.ПорядокСортировки = 020;
		ИначеЕсли СтрНачинаетсяС(СтрокаТаблицы.Представление, "Счет-фактура") Тогда
			СтрокаТаблицы.ПорядокСортировки = 030;
		ИначеЕсли СтрНачинаетсяС(СтрокаТаблицы.Представление, "Комплект документов в PDF") Тогда
			СтрокаТаблицы.ПорядокСортировки = 990;
		Иначе
			СтрокаТаблицы.ПорядокСортировки = 900;
		КонецЕсли;
	КонецЦикла;
	
	ТаблицаПечатныхФорм.Сортировать("ПорядокСортировки");
	ТаблицаПечатныхФорм.Колонки.Удалить("ПорядокСортировки");

КонецПроцедуры

#КонецОбласти

