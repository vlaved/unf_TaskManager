﻿
&НаСервере
Процедура уз_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	уз_СоздатьЭлементыФормы();
	
КонецПроцедуры

&НаСервере
Процедура уз_СоздатьЭлементыФормы()
	
	Форма = ЭтотОбъект;
	
	уз_РаботаСФормами.СоздатьКоманду(Форма, "ЗаполнитьЗадачами", "Заполнить задачами", "ЗаполнитьЗадачами");	уз_РаботаСФормами.СздКнопка(Форма, "ЗаполнитьЗадачами", Элементы.ЗапасыКоманднаяПанельКоманды, "Заполнить задачами", "ЗаполнитьЗадачами", 1);
	
КонецПроцедуры    

&НаКлиенте
Процедура ЗаполнитьЗадачами()
	
	Объект.Запасы.Очистить();
    ЗаполнитьЗадачамиНаСервере(); 
		
КонецПроцедуры       

&НаСервере
Процедура ЗаполнитьЗадачамиНаСервере()
	
	НоменклатураУслуга = Справочники.Номенклатура.ПолучитьСсылку(Новый УникальныйИдентификатор("8c87c58c-88d8-11ed-83b2-be845aaabf72"));
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	СУММА(уз_Задача.ЧасыФакт) КАК Количество
	               |ИЗ
	               |	Документ.уз_Задача КАК уз_Задача
	               |ГДЕ
	               |	уз_Задача.ЗаказПокупателя = &ЗаказПокупателя
	               |	И уз_Задача.Состояние = ЗНАЧЕНИЕ(Перечисление.уз_СостоянияЗадачи.Выполнена)
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена
	               |ИЗ
	               |	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
	               |			&ДатаДокумента,
	               |			ВидЦен = &ВидЦен
	               |				И Номенклатура = &Номенклатура) КАК ЦеныНоменклатурыСрезПоследних";
	Запрос.УстановитьПараметр("ЗаказПокупателя", Объект.Ссылка); 
	Запрос.УстановитьПараметр("ДатаДокумента", Объект.Дата);    
	Запрос.УстановитьПараметр("Номенклатура", НоменклатураУслуга);
	Запрос.УстановитьПараметр("ВидЦен", Справочники.ВидыЦен.Оптовая);
	
	МассивРезультатов = Запрос.ВыполнитьПакет();	
	
	ВыборкаЧасы = МассивРезультатов[0].Выбрать();
	Если ВыборкаЧасы.Следующий() Тогда
		
		НоваяСтрока = Объект.Запасы.Добавить();
		НоваяСтрока.Номенклатура = НоменклатураУслуга;
		НоваяСтрока.СтавкаНДС = Справочники.СтавкиНДС.НайтиПоНаименованию("Без НДС");
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ВыборкаЧасы);
		
		ВыборкаЦена = МассивРезультатов[1].Выбрать();
		Если ВыборкаЦена.Следующий() Тогда
			ЗаполнитьЗначенияСвойств(НоваяСтрока, ВыборкаЦена);
		КонецЕсли; 
		
		НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена;
		
	КонецЕсли;
	
КонецПроцедуры