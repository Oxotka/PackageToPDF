﻿
#Область ПрограммныйИнтерфейс

// Возвращает сведения о внешней обработке.
Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиПечатнаяФорма();
	ПараметрыРегистрации.Версия = "1.0";
	ПараметрыРегистрации.Назначение.Добавить("Документ.РеализацияТоваровУслуг");
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	
	// Комплект документов в PDF
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = НСтр("ru = 'Комплект документов в PDF'");
	НоваяКоманда.Идентификатор = "КомплектДокументовВPDF";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Истина;
	НоваяКоманда.Модификатор = "ПечатьMXL";
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Функция ИмяФайла(Документ) Экспорт

	

КонецФункции

#КонецОбласти

