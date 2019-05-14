
BET						= 0.08 				-- Ставка 8%
EXCHANGE_COMMISSION		= 0.000006 			-- Комиссия биржы 0.0006% 
COUNT_DAY_IN_YEAR		= 365 				-- Количество дней в году
CLASS_CODE				= 'CNGD'			-- Код класса
ACCOUNT					= 'MB0005605674'	-- Код счета
PARTNER					= 'MC0005600000'	-- Код организации – партнера по РПС сделке 
SETTLE_CODE				= 'T1'				-- Код расчетов при исполнении внебиржевых заявок
TAG						= 'L'				-- ('L' - лимитированная, 'M' - рыночная)
TRANSACTION_TYPE		= 'NEW_NEG_DEAL'	-- Тип транзакции РПС сделка не редактировать
CLIENTCODE				= '2312V'			-- Код клиента(донора)
trans_id				= os.time()			-- ID транзакции*
FLAFRES					= ''				-- Флаг транзакции если пусто, то транзакции не прошла*
START 					= false				-- Флаг поддержания работы скрипта*
STOP 					= true;				-- Флаг поддержания работы скрипта*
SLEEP 					= 2000				-- Время ожидания Скрипта.
BufferClient = {};
TestTable = {}
PATH_SAVE_LOG = "S:\\boff_exe\\MMVB\\QUIK\\Colibri\\Logs" 		-- Путь сохранения лога
PATH_SAVE_TRANSACTIONS = "S:\\boff_exe\\MMVB\\QUIK\\Colibri\\Logs"  -- Путь сохранения транзакций
-- Выбор приоритет валют(Меняем Значение в [ ]  от 1 до 2)
TableSelectExchange = {
	[1] = "USD",
	[2] = "EUR",
	[3] = "SUR"
}
-- Выбор переносимой валюты 
SelectCurrency = {
	[1] = "USD",
	[2] = "EUR",
	[3] = "SUR"
}
function Init()
	-- Создает папку для логов 
		pathSaveLog = PATH_SAVE_LOG
	-- Время создания логов
	 local TIME_CREATE_LOG = os.date("%Y-%m-%d-%H-%M")
   -- Пытается открыть лог-файл в режиме "чтения/записи"
   Log = io.open(pathSaveLog.."//"..TIME_CREATE_LOG..".txt","r+");
   -- Если файл не существует
   if Log == nil then 
      -- Создает файл в режиме "записи"
      Log = io.open(pathSaveLog.."//"..TIME_CREATE_LOG..".txt","w"); 
      -- Закрывает файл
      Log:close();
      -- Открывает уже существующий файл в режиме "чтения/записи"
      Log = io.open(pathSaveLog.."//"..TIME_CREATE_LOG..".txt","r+");
   end; 
   -- Встает в конец файла
   Log:seek("end",0);
   -- Добавляет пустую строку-разрыв
   Log:flush();
   return TIME_CREATE_LOG
end;

function ToLog(str)
	if str~=nil then 
	   local datetime = os.date("*t",os.time()); -- Текущие дата/время
	   local sec_mcs_str = tostring(os.clock()); -- Секунды с микросекундами 
	   --local mcs_str = string.sub(sec_mcs_str, sec_mcs_str:find("%.") + 1);   -- Микросекунды
	   -- Записывает в лог-файл переданную строку, добавляя в ее начало время с точностью до микросекунд
	   Log:write(tostring(datetime.day).."-"
				..tostring(datetime.month).."-"
				..tostring(datetime.year).." "
				..tostring(datetime.hour)..":"
				..tostring(datetime.min)..":"
				..tostring(datetime.sec).."."
				--..mcs_str.." "
				..str.."\n");  -- Записывает в лог-файл
	   Log:flush();   -- Сохраняет изменения в лог-файле
	end;
end;
--- тестовый вариант записи в файл.
function PocketInit(name)
	local pathSaveTransaction = PATH_SAVE_TRANSACTIONS
	local TIME_CREATE_POCKET = os.date("%Y-%m-%d-%H-%M")
   -- Пытается открыть лог-файл в режиме "чтения/записи"
	Pocket = io.open(pathSaveTransaction.."//"..TIME_CREATE_POCKET..'_'..name..".tri","r+");
   -- Если файл не существует
   if Pocket == nil then 
      -- Создает файл в режиме "записи"
      Pocket = io.open(pathSaveTransaction.."//"..TIME_CREATE_POCKET..'_'..name..".tri","w"); 
      -- Закрывает файл
      Pocket:close();
      -- Открывает уже существующий файл в режиме "чтения/записи"
      Pocket = io.open(pathSaveTransaction.."//"..TIME_CREATE_POCKET..'_'..name..".tri","r+");
   end; 
   -- Встает в конец файла
   Pocket:seek("end",0);
   -- Добавляет пустую строку-разрыв
   --Log:write("\n");
   Pocket:flush(); 
end;
--  тестовый вариант записи в файл.        
function ToPocket(str)
	Pocket:write(str)
	Pocket:flush()
end;
-- Приводит переданную цену к требуемому для транзакции по инструменту виду(Не очень правильно работает с точкой)
GetCorrectPrice = function(structParam) -- STRING
   -- Получает точность цены по инструменту
    local scale = getSecurityInfo(CLASS_CODE,structParam.secCodeCurrency).scale
   -- Получает минимальный шаг цены инструмента
   local PriceStep = tonumber(getParamEx(CLASS_CODE,structParam.secCodeCurrency, "SEC_PRICE_STEP").param_value)-- Получает Доллар 
   -- Если после запятой должны быть цифры
   if scale > 0 then
      price = tostring(structParam.priseSwp)
      -- Ищет в числе позицию запятой, или точки
      local dot_pos = price:find('.')
      local comma_pos = price:find(',')
      -- Если передано целое число
      if dot_pos == nil and comma_pos == nil then
         -- Добавляет к числу ',' и необходимое количество нулей и возвращает результат
         price = price..','
         for i=1,scale do price = price..'0' end;
         return price
      else -- передано вещественное число         
         -- Если нужно, заменяет запятую на точку 
         if comma_pos ~= nil then price:gsub('.', '.') end;
         -- Округляет число до необходимого количества знаков после запятой
         price = math_round(tonumber(price),scale)
         -- Корректирует на соответствие шагу цены
         price = math_round(price/PriceStep)*PriceStep
         price = string.gsub(tostring(price),'[\.]+', '.')
         return price
      end;
   else -- После запятой не должно быть цифр
      -- Корректирует на соответствие шагу цены
      price = math_round(price/PriceStep)*PriceStep
      return tostring(math.floor(price))
   end;
end;
-- Функция определяет какая валюта не торгуется сегодня на рынке из за праздничных  дней/// Исправить не понятно как работает.
function ExchangeWeekendCalendar(currcode)-- Код Валюты)
	local flag = true
	if currcode == 'USD' then
		secCodeCurrency = 'USD000TODTOM'			
	end
	if currcode == 'EUR' then
		secCodeCurrency = 'EUR000TODTOM'
	end
	if currcode == 'SUR' or 0 ~= tonumber(getParamEx('CNGD', secCodeCurrency,'STATUS').param_value)  then	
		flag = true
	else
		flag =  false
	end
	ToLog(currcode.." ExchangeWeekendCalendar "..tostring(flag))
	return flag
end
-- функция поиска
function FindAray(items,value)
	if #items ~= 0 then
		for k,v in pairs(items) do  
			if v == value then
				return false
			end
		end
	end 
	return true
end
-- Split
function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t[1],t[2]
end
-- возвращается таблица кокантенированных значений
concatenateTables = function(Table)
	local IndexMinus = {}
	for key,val in pairs(Table) do 
		count = #IndexMinus
		for j = 1, #val do
			IndexMinus[count+j] = val[j]
		end
	end
	return IndexMinus
end

-- Округляет число до указанной точности
math_round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end;

-- Сортирует приоритетную валюту
function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      			-- iterator variable
		local iter = function ()    -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end
--Смещение по дням.
function CountDayShift(TradeData,SetyleDate)
	if TradeData ~= nil and SetyleDate ~= nil then
		local todayData = { day = 0, month = 0, year = 0}
		local nextData = { day = 0, month = 0, year = 0}
		todayData.day,todayData.month,todayData.year = string.match(TradeData,"(%d+).(%d+).(%d+)")
		nextData.day,nextData.month,nextData.year = string.match(SetyleDate,"(%d+).(%d+).(%d+)")
		local t_Day = os.time{year = todayData.year, month = todayData.month,day = todayData.day}
		local t_1Day = os.time{year = nextData.year,month = nextData.month,day = nextData.day}
		local shiftDay = math.abs((t_1Day - t_Day)/360000)		
		local tempTable = {}
		for i in string.gmatch(shiftDay, "(%d)") do
			table.insert(tempTable,i)
		end
		shiftD = tonumber(table.concat(tempTable))/24
		if  shiftD <= 1 then 
			return 1
		else
			return shiftD
		end
	end
end
-- проверка достаточности валюты обмнеа.
CheckSuffice = function(plus,minus)
	local flag = false
	if plus ~= nil and minus ~= nil then 
		if (plus ~= 0 and tonumber(plus.currentbal) > 0 ) and (minus ~= 0 and tonumber(minus.currentbal) < 0 ) then 
			ToLog(" CheckSuffice ".." ТЕКУЩИЙ ОСТАТОК "..plus.currentbal.." КОД_ВАЛЮТЫ "..plus.currcode.." ТЕКУЩИЙ ОСТАТОК "..minus.currentbal.." КОД_ВАЛЮТЫ "..minus.currcode)
			local Param = PriceSwp(plus,minus,BET,COUNT_DAY_IN_YEAR);
			if tonumber(Param.valuePlus)  > 0  then 
				flag = true
			end
		end
	end
	return flag
end
 -- возвращается !
FilterCurrency = function(Currencys,ExchangeCurrency)
	local minusCurrency = nil 	 -- надо вернуть.
	local plusCurrency = nil -- надо вернуть.
	local flagSelectCurrency = true
	local flagSelectCurrencyExchange = true
	for key, value in pairsByKeys(SelectCurrency) do
		if flagSelectCurrency then 
			for _,currency in ipairs(Currencys) do
				if currency ~= 0 and tonumber(currency.currentbal) < 0 and currency.currcode == value then
					minusCurrency = currency
					ToLog(" FilterCurrency find minus ".." КЛЮЧ "..key..value.." КОД КЛИЕНТА "..minusCurrency.client_code.." ТЕКУЩИЙ ОСТАТОК "..minusCurrency.currentbal.." КОД_ВАЛЮТЫ "..minusCurrency.currcode)-- убрать тест
					flagSelectCurrency = false
				end
			end
		end
	end
	for name, line in pairsByKeys(TableSelectExchange) do
		if flagSelectCurrencyExchange then 
			for k,v in ipairs(Currencys) do
				--FindAray(ExchangeCurrency,v.currcode) and
				if  v ~= 0 and  v.currcode == line and ExchangeWeekendCalendar(v.currcode) and CheckSuffice(v,minusCurrency) then
					plusCurrency = v;
					table.insert(ExchangeCurrency,v.currcode);
					ToLog(" FilterCurrency find plus ".." КЛЮЧ "..k.." КОД КЛИЕНТА "..plusCurrency.client_code.." ТЕКУЩИЙ ОСТАТОК "..plusCurrency.currentbal.." КОД_ВАЛЮТЫ "..plusCurrency.currcode)-- убрать тест
					flagSelectCurrencyExchange = false	
				end
			end
		end
	end
	if flagSelectCurrencyExchange then 
		plusCurrency = 0
	end
	return minusCurrency,plusCurrency,ExchangeCurrency
end

 -- возвращается таблица (SUR,EUR,USD) если валюты нет то в таблице 0;
local GetTableClient = function()
	local TableSortCarrencis = {}; 
	local TableIndexSUR = {}
	local TableIndexEUR = {}
	local TableIndexUSD = {}
	local TableIndexGBP = {} 
	local TableClientCode = {}
	local TableIndexMinus = {}
	TableIndexSUR = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,currentbal) if (tag == 'RTOD') and (currcode == "SUR") and (limit_kind == 0) and (currentbal < 0) then  return true else return false end end,"tag,currcode,limit_kind,currentbal");
	TableIndexEUR = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,currentbal) if (tag == 'RTOD') and (currcode == "EUR") and (limit_kind == 0) and (currentbal < 0) then  return true else return false end end,"tag,currcode,limit_kind,currentbal");
	TableIndexUSD = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,currentbal) if (tag == 'RTOD') and (currcode == "USD") and (limit_kind == 0) and (currentbal < 0) then  return true else return false end end,"tag,currcode,limit_kind,currentbal");
	TableIndexGBP = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,currentbal) if (tag == 'RTOD') and (currcode == "GBP") and (limit_kind == 0) and (currentbal < 0) then  return true else return false end end,"tag,currcode,limit_kind,currentbal");
	TableIndexMinus = concatenateTables({TableIndexSUR,TableIndexEUR,TableIndexUSD})
	for j = 1, #TableIndexMinus do
		ClientCode = getItem("money_limits",TableIndexMinus[j]).client_code
		if FindAray(TableClientCode,ClientCode) then 
			table.insert(TableClientCode,ClientCode)
		end 
	end
	for _,v in pairs(TableClientCode) do
		local TCarrencis = {}
		local SUR = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,client_code) if (tag == 'RTOD') and (currcode == "SUR") and (limit_kind == 0)  and (client_code == v)then  return true else return false end end, "tag,currcode,limit_kind,client_code");		
		if SUR~= nil then
			table.insert(TCarrencis,getItem("money_limits",unpack(SUR)))		
		else 
			table.insert(TCarrencis,0)
		end
		local EUR = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,client_code) if (tag == 'RTOD') and (currcode == "EUR") and (limit_kind == 0)  and (client_code == v)then  return true else return false end end, "tag,currcode,limit_kind,client_code");
		if EUR~= nil then 
			table.insert(TCarrencis,getItem("money_limits",unpack(EUR)))
		else 
			table.insert(TCarrencis,0)
		end
		local USD = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,client_code) if (tag == 'RTOD') and (currcode == "USD") and (limit_kind == 0)  and (client_code == v)then  return true else return false end end, "tag,currcode,limit_kind,client_code");
		if USD~= nil then 
			table.insert(TCarrencis,getItem("money_limits",unpack(USD)))
		else 
			table.insert(TCarrencis,0)
		end
		local GBP = SearchItems("money_limits",0,getNumberOf("money_limits")-1, function(tag, currcode, limit_kind,client_code) if (tag == 'RTOD') and (currcode == "GBP") and (limit_kind == 0)  and (client_code == v)then  return true else return false end end, "tag,currcode,limit_kind,client_code");
		if GBP~= nil then 
			table.insert(TCarrencis,getItem("money_limits",unpack(GBP)))
		else 
			table.insert(TCarrencis,0)
		end
		 TableSortCarrencis[tostring(v)] = TCarrencis
	end
	for key, val in pairs(TableSortCarrencis)  do
		for k,v in ipairs(val) do
			if v~=0 then		
				ToLog(" GetTableClient ".." КЛЮЧ "..key.." КОД КЛИЕНТА "..v.client_code.." ТЕКУЩИЙ ОСТАТОК "..v.currentbal.." КОД_ВАЛЮТЫ "..v.currcode)-- убрать тест
			end				
		end
	end
	
	return TableSortCarrencis
	
end	
-- получить значение из таблици TestTable
GetValueMoneyLimit = function(key,Table)
	for k, val in pairs(Table)  do
		if tostring(k) == tostring(key) then
			return val
		end 
	end
end
--проверка значиений в таблице отрицательного текущего остатка
CheckminusCurrency = function(Table)
	local flag = true
	for k, v in pairs(Table)  do
		if v ~= 0 and v.currentbal < 0  then 
			flag =  false		
		end
	end
	return flag
end 
---ГЛАВНАЯ ФУНКЦИЯ.	------------------
function main()	
	while STOP do
		Init()
		ToLog("START_SCRIPT")
		TestTable = GetTableClient()
		for key, val in pairs(TestTable)  do
			ToLog("NEXT_№ "..key.."\n")-- убрать тест
			local minusCurrency = nil
			local plusCurrency = nil		
			local plusExchangeCurrency = {}
			repeat
				ToLog("IN  REPEAT "..key.."\n")-- убрать тест
				local MoneyLimit = GetValueMoneyLimit(key,TestTable)
				for k, v in pairs(MoneyLimit)  do
					if v ~= 0  then 
						ToLog(" GetValueMoneyLimit ".." КЛЮЧ "..key.." КОД КЛИЕНТА "..v.client_code.." ТЕКУЩИЙ ОСТАТОК "..v.currentbal.." КОД_ВАЛЮТЫ "..v.currcode.."\n")-- убрать тест
					end
				end
				ToLog("NEXT_IN FilterCurrency".."\n")-- убрать тест				
				minusCurrency,plusCurrency,plusExchangeCurrency = FilterCurrency(MoneyLimit,plusExchangeCurrency)
				local structParam = nil				
				if plusCurrency ~= 0 and minusCurrency ~= 0 then 
					ToLog(" FilterCurrency RETURN ".." КЛЮЧ "..key.." КОД КЛИЕНТА "..minusCurrency.client_code.." ТЕКУЩИЙ ОСТАТОК "..minusCurrency.currentbal.." КОД КЛИЕНТА "..plusCurrency.client_code.." ТЕКУЩИЙ ОСТАТОК "..plusCurrency.currentbal.." КОД_ВАЛЮТЫ "..plusCurrency.currcode.."\n")-- убрать тест
				end
				if plusCurrency ~= 0 and plusCurrency.currentbal > 1 then
					ToLog("NEXT_IN PriceSwp".."\n")-- убрать тест	
					structParam = PriceSwp(plusCurrency,minusCurrency,BET,COUNT_DAY_IN_YEAR);
					ToLog("Proverca COMMISSION ".."\n")-- убрать тест!!!!!!!!!!!!!!!!!!!!!!!!!
					
				end
				if structParam ~= nil and tonumber(structParam.valuePlus) > 0 then 
					ToLog(tostring('STRUCT_PARAM'.." "..'CLIENTCODE'..'='..structParam.clientCode..";"..'SECCODE'..'='..structParam.secCodeCurrency..";"..'BASEPRICE'..'='..structParam.baseCurrency..";"..'PRICE'..'='..structParam.priseSwp..";"..'CURRENCY_MINUS'..'='..structParam.valueMinus..";"..";"..'CURRCODE_MINUS'..'='..structParam.minusCurrcode..";"..'CURRENCY_PLUS'..'='..structParam.valuePlus..";"..'CURRCODE_PLUS'..'='..structParam.plusCurrcode..";"..'COMMISSION'..'='..structParam.currentValueWithCommission..";"..structParam[1].BS..structParam[1].SB.."\n"));
					ToLog("NEXT_IN TransferOfPositionsCurrency".."\n")-- убрать тест						
					TransferOfPositionsCurrency(structParam);
					sleep(2000);
				else
					break
				end
				ToLog("Proverca ucloviy  "..minusCurrency.currentbal.." CheckminusCurrency "..tostring(CheckminusCurrency(MoneyLimit)))
			until CheckminusCurrency(MoneyLimit)
			ToLog("END  repeat")
		end
		STOP = false
		ToLog("END")
	end
end	
-- Возвращает структуру для переноса
PriceSwp = function (TableMoneySurUsdEur, -- Выбранная валюта для погашения минуса  
						 TableMoneyMinus, -- Валюта переноса
									 Bet, -- Ставка %8.5
						  CountDayInYear -- Количество дней в году
)
	local 	classCode  = 'CNGD'   	   -- Код класса
	local 	structParamTransaction = {
			clientCode = '',		-- Код клиента
			priseSwp  = 0,			-- Цена свопа
			baseCurrency = 0,		-- Базовый курс
			secCodeCurrency = '',	-- Код инструмента
			minusCurrcode = '',			-- Валюта номер
			plusCurrcode = '',			-- Валюта номер
			valuePlus  = 0,			-- Валяюта + для свопа
			valueMinus = 0,			-- Валяюта для переноса
			currentValueWithCommission = 0, -- Комисия биржы
		   {BS = '', SB = ''} -- значения покупка/продажа 
	}
	local betMinusOrPlus = Bet
	if  TableMoneySurUsdEur ~= nil and TableMoneyMinus ~= nil then
		structParamTransaction.clientCode = TableMoneyMinus.client_code	
		if TableMoneySurUsdEur.currcode == 'USD' and TableMoneyMinus.currcode == 'SUR' then 
			structParamTransaction[1].BS = 'B'
			structParamTransaction[1].SB = 'S'
			betMinusOrPlus = '+'..Bet
			structParamTransaction.minusCurrcode = 'SUR'
			structParamTransaction.plusCurrcode = 'USD'
			structParamTransaction.secCodeCurrency = 'USD000TODTOM'  -- Код инструмента USD
			local int,double = mysplit(tostring(TableMoneySurUsdEur.currentbal),'.')
			structParamTransaction.valuePlus = int
			local basePrice = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value)
			if basePrice ~= 0 then
				Commission = math_round(math.abs(tonumber(TableMoneyMinus.currentbal))*tonumber(EXCHANGE_COMMISSION),4)
				if Commission > 1.0 then 
					structParamTransaction.valueMinus = ( math.abs(TableMoneyMinus.currentbal) + Commission)/basePrice
				else
					structParamTransaction.valueMinus = ( math.abs(TableMoneyMinus.currentbal) + 1.0)/basePrice
				end
			end			
		elseif TableMoneySurUsdEur.currcode == 'EUR' and TableMoneyMinus.currcode == 'SUR' then
			structParamTransaction[1].BS = 'B'
			structParamTransaction[1].SB = 'S'
			betMinusOrPlus = '+'..Bet
			structParamTransaction.minusCurrcode = 'SUR'
			structParamTransaction.plusCurrcode = 'EUR'			
			structParamTransaction.secCodeCurrency = 'EUR000TODTOM'  -- Код инструмента EUR
			local int,double = mysplit(tostring(TableMoneySurUsdEur.currentbal),'.')
			structParamTransaction.valuePlus  =  int
			local basePrice = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value)
			if basePrice ~= 0 then
				Commission = math_round(math.abs(tonumber(TableMoneyMinus.currentbal))*tonumber(EXCHANGE_COMMISSION),4)
				if Commission > 1.0 then 
					structParamTransaction.valueMinus = ( math.abs(TableMoneyMinus.currentbal) + Commission)/basePrice
				else
					structParamTransaction.valueMinus = ( math.abs(TableMoneyMinus.currentbal) + 1.0)/basePrice
				end
			end
		elseif TableMoneySurUsdEur.currcode == 'SUR' and TableMoneyMinus.currcode == 'USD' then
			structParamTransaction[1].BS = 'S'
			structParamTransaction[1].SB = 'B'
			betMinusOrPlus = '-'..Bet
			structParamTransaction.minusCurrcode = 'USD'
			structParamTransaction.plusCurrcode = 'SUR'			
			structParamTransaction.secCodeCurrency = 'USD000TODTOM'  -- Код инструмента
			local basePrice = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value)
			if basePrice ~= 0 then
				local int,double = mysplit(tostring(TableMoneySurUsdEur.currentbal/basePrice),'.')
				structParamTransaction.valuePlus = int
				ToLog("Proverca USLOVIYA(PriceSwp) "..structParamTransaction.valuePlus)-- убрать тест!!!!!!!!!!!!!!!!!!!!!!!!!
			end
			if basePrice ~= 0 then
				ToLog("Proverca USLOVIYA(PriceSwpTableMoneyMinus) "..TableMoneyMinus.currentbal)-- убрать тест!!!!!!!!!!!!!!!!!!!!!!!!!
				local number = math.abs(tostring(TableMoneyMinus.currentbal))
				structParamTransaction.valueMinus=  math.ceil(number)
			end		
		elseif TableMoneySurUsdEur.currcode == 'EUR' and TableMoneyMinus.currcode == 'USD' then
			structParamTransaction[1].BS = 'B'
			structParamTransaction[1].SB = 'S'
			betMinusOrPlus = '+'..Bet
			structParamTransaction.minusCurrcode = 'USD'
			structParamTransaction.plusCurrcode = 'EUR'			
			structParamTransaction.secCodeCurrency = 'EURUSDTODTOM'  -- Код инструмента
			local basePrice = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value)
			if basePrice ~= 0 then
				local int,double = mysplit(tostring(TableMoneySurUsdEur.currentbal),'.')
				structParamTransaction.valuePlus = int
			end		
			if basePrice ~= 0 then
				local number  =  math.abs(TableMoneyMinus.currentbal/basePrice)			
				structParamTransaction.valueMinus = math.ceil(number)
			end
		elseif TableMoneySurUsdEur.currcode == 'SUR' and TableMoneyMinus.currcode == 'EUR' then
			structParamTransaction[1].BS = 'S'
			structParamTransaction[1].SB = 'B'
			betMinusOrPlus = '-'..Bet
			structParamTransaction.minusCurrcode = 'EUR'
			structParamTransaction.plusCurrcode = 'SUR'				
			structParamTransaction.secCodeCurrency = 'EUR000TODTOM'  -- Код инструмента
			local basePrice = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value)
			if basePrice ~= 0 then
				local int,double = mysplit(tostring(TableMoneySurUsdEur.currentbal/basePrice),'.')
				structParamTransaction.valuePlus = int
			end
			if basePrice ~= 0 then
				local number = math.abs(tostring(TableMoneyMinus.currentbal))
				structParamTransaction.valueMinus=  math.ceil(number)
			end				
		elseif TableMoneySurUsdEur.currcode == 'USD' and TableMoneyMinus.currcode == 'EUR' then
			structParamTransaction[1].BS = 'S'
			structParamTransaction[1].SB = 'B'
			betMinusOrPlus = '-'..Bet
			structParamTransaction.minusCurrcode = 'EUR'
			structParamTransaction.plusCurrcode = 'USD'			
			structParamTransaction.secCodeCurrency = 'EURUSDTODTOM'  -- Код инструмента
			local basePrice = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value)
			if basePrice ~= 0 then
				local int,double = mysplit(tostring(TableMoneySurUsdEur.currentbal/basePrice),'.')
				structParamTransaction.valuePlus = int
				ToLog(tostring(int))
			end
			if basePrice ~= 0 then
				local int,double = mysplit(tostring(TableMoneyMinus.currentbal),'.')
				structParamTransaction.valueMinus = math.abs(int)
			end			
		else 
			--f:write('волюта не выбрана'.."\n");
		end;
	end;
	if structParamTransaction.secCodeCurrency ~= '' then
		local basePrice = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value)	
		structParamTransaction.baseCurrency  = tonumber(getParamEx(classCode, structParamTransaction.secCodeCurrency, "BASEPRICE").param_value) -- Рассчитывается базовый курс валюты
		local tradeData = getParamEx(classCode, structParamTransaction.secCodeCurrency,'TRADE_DATE_CODE').param_image
		local setyleDate = getParamEx(classCode, structParamTransaction.secCodeCurrency,'SETTLEDATE').param_image
		structParamTransaction.priseSwp  = tonumber(structParamTransaction.baseCurrency)*betMinusOrPlus/CountDayInYear*CountDayShift(tradeData,setyleDate) -- Рассчитывается цена свопа сделать функцию 
		structParamTransaction.currentValueWithCommission = math_round(math.abs(tonumber(TableMoneyMinus.currentbal))*tonumber(EXCHANGE_COMMISSION),4) -- Комиссия биржи ц полученной цены в рублях
		ToLog(tostring('SECCODE'..'='..structParamTransaction.secCodeCurrency..";"..'BASEPRICE'..'='..structParamTransaction.baseCurrency..";"..'PRICE'..'='..structParamTransaction.priseSwp..";"..'CURRENCY_MINUS'..'='..structParamTransaction.valueMinus..";"..";"..'CURRCODE_MINUS'..'='..structParamTransaction.minusCurrcode..";"..'CURRENCY_PLUS'..'='..structParamTransaction.valuePlus..' NOT CEIL '..TableMoneySurUsdEur.currentbal/basePrice..";"..'CURRCODE_PLUS'..'='..structParamTransaction.plusCurrcode..";"..'COMMISSION'..'='..structParamTransaction.currentValueWithCommission..";"..'BANKBET'..'='..betMinusOrPlus..";"..'COUNTDAYSHIFT'..'='..shiftD.."\n"));	
		return structParamTransaction
	else 
		ToLog(tostring(" Error massege function priceSwp"));
	end
end;	

-- формирование  зявки на покупку/продажу волюты (своп)
TransferOfPositionsCurrency = function(structParam)
	local moneyDonarClient  =  getMoneyEx(getItem("money_limits",0).firmid,CLIENTCODE,'RTOD',structParam.minusCurrcode,0); -- Возвращает валюту 
	if structParam.minusCurrcode == 'SUR'  then
		--action должен Быть базовый курс
		local int,double = mysplit(tostring(structParam.valueMinus),'.')
		if tonumber(double) > 0 then 
			countLots = tonumber(int) + 1.0
		else
			countLots = math.ceil(structParam.valueMinus)
		end
		ToLog(tonumber(structParam.valueMinus).."valueMinus")		
		if tonumber(structParam.valuePlus) > countLots then	
			if moneyDonarClient.currentbal > (countLots*structParam.baseCurrency) then
				if SetOrder(structParam,structParam[1].BS,countLots,structParam.clientCode) == '' then
					SetOrder(structParam,structParam[1].SB,countLots,CLIENTCODE)
				else
					message('Error to open/close transaction:',2)
				end
			else 
				ToLog("CURRENTBAL DONER"..":"..tostring(moneyDonarClient.currentbal).." ".."Error, donors balance less".." "..structParam.clientCode);
				ToLog("TEST_8"..structParam.clientCode)
				table.insert(BufferClient,tostring(structParam.clientCode))
			end																									-- Продажа Части USD т.к минус SUR меньше чем наличие валюты USD
			ToLog(" TransferOfPositionsCurrency 1.1 ".." КОМИССИЯ> 1.0 ВАЛЮТЫ ОБМЕНА БОЛЬШЕ "..moneyDonarClient.currentbal.." КОД КЛИЕНТА "..structParam.clientCode.." КОЛИЧЕСТВО ЛОТОВ "..countLots.."\n")-- убрать тест
		else
			valuePlus = structParam.valuePlus + (structParam.currentValueWithCommission/structParam.baseCurrency)
			if moneyDonarClient.currentbal > (structParam.valuePlus*structParam.baseCurrency)  then
				if SetOrder(structParam,structParam[1].BS,structParam.valuePlus,structParam.clientCode) == '' then  		-- Продажа всего USD т.к минус SUR больше чем наличие валюты USD 
					SetOrder(structParam,structParam[1].SB,structParam.valuePlus,CLIENTCODE)
				else
					message('Error to open/close transaction:',2)
				end
			else
				ToLog("CURRENTBAL DONER"..":"..tostring(moneyDonarClient.currentbal).." ".."Error, donors balance less".." "..structParam.clientCode);
				ToLog("TEST_9"..structParam.clientCode)				
				table.insert(BufferClient,tostring(structParam.clientCode))					
			end
			ToLog(" TransferOfPositionsCurrency 1.2 ".." КОМИССИЯ> 1.0 ВАЛЮТЫ ОБМЕНА МЕНЬШЕ "..moneyDonarClient.currentbal.." КОД КЛИЕНТА "..structParam.clientCode.." КОЛИЧЕСТВО ЛОТОВ "..structParam.valuePlus.."\n")-- убрать тест
		end
	else 
		if tonumber(structParam.valuePlus) > structParam.valueMinus then	
			if moneyDonarClient.currentbal > (structParam.valueMinus) then
				if SetOrder(structParam,structParam[1].BS,structParam.valueMinus,structParam.clientCode) == '' then
				ToLog("Proverca USLOVIYA(TransferOfPositionsCurrency) "..structParam.valuePlus)-- убрать тест!!!!!!!!!!!!!!!!!!!!!!!!!
					SetOrder(structParam,structParam[1].SB,structParam.valueMinus,CLIENTCODE)
				else
					message('Error to open/close transaction:',2)
				end
			else 
				ToLog("CURRENTBAL DONER"..":"..tostring(moneyDonarClient.currentbal).." ".."Error, donors balance less".." "..structParam.clientCode);
				ToLog("TEST_8"..structParam.clientCode)
				table.insert(BufferClient,tostring(structParam.clientCode))
			end																									-- Продажа Части USD т.к минус SUR меньше чем наличие валюты USD
			ToLog(" TransferOfPositionsCurrency 3.1 ".." КОМИССИЯ> 1.0 ВАЛЮТЫ ОБМЕНА БОЛЬШЕ "..moneyDonarClient.currentbal.." КОД КЛИЕНТА "..structParam.clientCode.." КОЛИЧЕСТВО ЛОТОВ "..structParam.valueMinus.."\n")-- убрать тест
		else 			
			if moneyDonarClient.currentbal > tonumber(structParam.valuePlus) then
				if SetOrder(structParam,structParam[1].BS,structParam.valuePlus,structParam.clientCode) == '' then
								-- Продажа всего USD т.к минус SUR больше чем наличие валюты USD 
					SetOrder(structParam,structParam[1].SB,structParam.valuePlus,CLIENTCODE)
				else
					message('Error to open/close transaction:',2)
				end
			else
				ToLog("CURRENTBAL DONER"..":"..tostring(moneyDonarClient.currentbal).." ".."Error, donors balance less".." "..structParam.clientCode);
				ToLog("TEST_9"..structParam.clientCode)				
				table.insert(BufferClient,tostring(structParam.clientCode))					
			end
			ToLog(" TransferOfPositionsCurrency 3.2 ".." КОМИССИЯ> 1.0 ВАЛЮТЫ ОБМЕНА МЕНЬШЕ "..moneyDonarClient.currentbal.." КОД КЛИЕНТА "..structParam.clientCode.." КОЛИЧЕСТВО ЛОТОВ "..structParam.valuePlus.."\n")-- убрать тест
		end
	end
end

CalculationTransaction = function (T,Param)
ToLog("IN CalculationTransaction".."\n")
if Param.minusCurrcode == 'USD' then 
	if Param.plusCurrcode == 'SUR' or Param.plusCurrcode == 'EUR' then 
		 if T.OPERATION == 'B' then 
			for key,currencys in pairs(TestTable)  do
				ToLog(tostring(key).." TEST KEY")
				if key == Param.clientCode then
					ToLog(tostring(key).." TEST KEY IN"  ..Param.clientCode)
					for k,currency in ipairs(currencys) do				
						if currency ~= 0 and currency.currcode == Param.minusCurrcode and Param.clientCode == currency.client_code then
							ToLog(" CalculationTransaction_buy "..' TOTAL_BEFORE '..TestTable[key][k].currentbal)
							if Param.plusCurrcode == 'SUR' then
								TestTable[key][k].currentbal = currency.currentbal + tonumber(T.QUANTITY)
							else 
								local int,double = mysplit(tostring(T.QUANTITY*T.BASECURRENCY),'.')
								TestTable[key][k].currentbal = currency.currentbal + tonumber(int)
							end
							ToLog(" CalculationTransaction1 "..Param.minusCurrcode..' OR '..Param.plusCurrcode..' SUM '..currency.currentbal + tonumber(T.QUANTITY)..' TOTAL_AFTER '..TestTable[key][k].currentbal..' QUANTITY '..T.QUANTITY)
							return ''
						end
					end
				end		
			end
		elseif T.OPERATION == 'S' then
			for key,currencys in pairs(TestTable)  do
				ToLog(tostring(key).." TEST KEY")
				if key == Param.clientCode then
					ToLog(tostring(key).." TEST KEY IN"  ..Param.clientCode)
					for k,currency in ipairs(currencys) do				
						if currency ~= 0 and currency.currcode == Param.plusCurrcode and Param.clientCode == currency.client_code then
							ToLog(" CalculationTransaction_sale "..' TOTAL_BEFORE '..TestTable[key][k].currentbal)
							local number = (tonumber(T.QUANTITY)*tonumber(T.BASECURRENCY))
							if number >=  currency.currentbal then 
								TestTable[key][k].currentbal = currency.currentbal - currency.currentbal
							else
								TestTable[key][k].currentbal = currency.currentbal - number
							end						
							ToLog(" CalculationTransaction1 "..Param.minusCurrcode..' OR '..Param.plusCurrcode..' SUM '..currency.currentbal + tonumber(T.QUANTITY)..' TOTAL_AFTER '..TestTable[key][k].currentbal..' QUANTITY '..T.QUANTITY)
							return ''
						end
					end
				end		
			end
		else 
			return 'error Transaction'
		end
	end
elseif Param.minusCurrcode == 'SUR' then
	if  Param.plusCurrcode == 'USD' or Param.plusCurrcode == 'EUR' then
		if T.OPERATION == 'B' then 
			for key,currencys in pairs(TestTable)  do
				ToLog(tostring(key).." TEST KEY")
				if key == Param.clientCode then
					ToLog(tostring(key).." TEST KEY IN"  ..Param.clientCode)
					for k,currency in ipairs(currencys) do				
						if currency ~= 0 and currency.currcode == Param.minusCurrcode and Param.clientCode == currency.client_code then
							ToLog(" CalculationTransaction_buy "..' TOTAL_BEFORE '..-(tonumber(Param.valueMinus)*tonumber(T.BASECURRENCY)))
							TestTable[key][k].currentbal = (currency.currentbal - Param.currentValueWithCommission)  + (tonumber(T.QUANTITY)*tonumber(T.BASECURRENCY))
							ToLog(" CalculationTransaction "..(tonumber(Param.valueMinus)*tonumber(T.BASECURRENCY)).." = valueMinus"..Param.valuePlus.." = valuePlus"..Param.minusCurrcode..' OR '..Param.plusCurrcode..' SUM '..currency.currentbal..' TOTAL_AFTER '..TestTable[key][k].currentbal..' QUANTITY '..T.QUANTITY)
							return ''
						end
					end
				end		
			end
		elseif T.OPERATION == 'S' then
			for key,currencys in pairs(TestTable)  do
				ToLog(tostring(key).." TEST KEY")
				if key == Param.clientCode then
					ToLog(tostring(key).." TEST KEY IN"  ..Param.clientCode)
					for k,currency in ipairs(currencys) do				
						if currency ~= 0 and currency.currcode == Param.plusCurrcode and Param.clientCode == currency.client_code then
							ToLog(" CalculationTransaction_sale "..' TOTAL_BEFORE '..TestTable[key][k].currentbal)
							TestTable[key][k].currentbal = currency.currentbal - tonumber(T.QUANTITY)
							ToLog(" CalculationTransaction "..Param.minusCurrcode..' OR '..Param.plusCurrcode..' SUM '..currency.currentbal + tonumber(T.QUANTITY)..' TOTAL_AFTER '..TestTable[key][k].currentbal..' QUANTITY '..T.QUANTITY)
							return ''
						end
					end
				end		
			end
		else 
			return 'error Transaction'
		end
	end
elseif Param.minusCurrcode == 'EUR' then 
	if Param.plusCurrcode == 'USD' or Param.plusCurrcode == 'SUR' then
		if T.OPERATION == 'B' then 
			for key,currencys in pairs(TestTable)  do
				ToLog(tostring(key).." TEST KEY")
				if key == Param.clientCode then
					ToLog(tostring(key).." TEST KEY IN"  ..Param.clientCode)
					for k,currency in ipairs(currencys) do				
						if currency ~= 0 and currency.currcode == Param.minusCurrcode and Param.clientCode == currency.client_code then
							ToLog(" CalculationTransaction2 "..' TOTAL_BEFORE '..TestTable[key][k].currentbal)
							TestTable[key][k].currentbal = currency.currentbal + tonumber(T.QUANTITY)
							ToLog(" CalculationTransaction2 "..Param.minusCurrcode..' OR '..Param.plusCurrcode..' SUM '..currency.currentbal + tonumber(T.QUANTITY)..' TOTAL_AFTER '..TestTable[key][k].currentbal..' QUANTITY '..T.QUANTITY)
							return ''
						end
					end
				end		
			end
		elseif T.OPERATION == 'S' then
			for key,currencys in pairs(TestTable)  do
				ToLog(tostring(key).." TEST KEY")
				if key == Param.clientCode then
					ToLog(tostring(key).." TEST KEY IN"  ..Param.clientCode)
					for k,currency in ipairs(currencys) do				
						if currency ~= 0 and currency.currcode == Param.plusCurrcode and Param.clientCode == currency.client_code then
							ToLog(" CalculationTransaction2 "..' TOTAL_BEFORE '..TestTable[key][k].currentbal)
							if Param.plusCurrcode == 'USD' then
								local number = tonumber(T.QUANTITY)*tonumber(T.BASECURRENCY)
								if number >  currency.currentbal then 
									TestTable[key][k].currentbal = currency.currentbal - currency.currentbal
								else
									TestTable[key][k].currentbal = currency.currentbal - number
								end
							else
								TestTable[key][k].currentbal = currency.currentbal - (tonumber(T.QUANTITY)*tonumber(T.BASECURRENCY))
							end
							ToLog(" CalculationTransaction2 "..Param.minusCurrcode..' OR '..Param.plusCurrcode..' SUM '..currency.currentbal..tonumber(T.QUANTITY)..' TOTAL_AFTER '..TestTable[key][k].currentbal..' QUANTITY '..T.QUANTITY)
							return ''
						end
					end
				end		
			end
		else 
			return 'error Transaction'
		end
	end		
end
end


-- Запись транзакции.
Transaction = function(T,Param)
	local propertiTransaction = '' 	
	if T.OPERATION == 'B' then 
		propertiTransaction = tostring('TRANS_ID'.."="..T.TRANS_ID..";"..'CLASSCODE'.."="..T.CLASSCODE..";"..'ACTION'.."="..'Ввод адресной заявки'..";"..'Торговый счет'.."="..T.ACCOUNT..";"..'К/П'.."=".."Купля"..";"..'Режим'.."="..T.CLASSCODE..";"..'Инструмент'.."="..T.SECCODE..";"..'Контрагент'.."=".."MC0005600000"..";"..'Цена'.."="..T.PRICE..";"..'Лоты'.."="..T.QUANTITY..";"..'Примечание'.."="..T.CLIENT_CODE..";"..'Код расчетов'.."="..'T1'..";"..'Базовый курс'.."="..T.BASECURRENCY.."\n")
		
		
	else	
		propertiTransaction = tostring('TRANS_ID'.."="..T.TRANS_ID..";"..'CLASSCODE'.."="..T.CLASSCODE..";"..'ACTION'.."="..'Ввод адресной заявки'..";"..'Торговый счет'.."="..T.ACCOUNT..";"..'К/П'.."=".."Продажа"..";"..'Режим'.."="..T.CLASSCODE..";"..'Инструмент'.."="..T.SECCODE..";"..'Контрагент'.."=".."MC0005600000"..";"..'Цена'.."="..T.PRICE..";"..'Лоты'.."="..T.QUANTITY..";"..'Примечание'.."="..T.CLIENT_CODE..";"..'Код расчетов'.."="..'T1'..";"..'Базовый курс'.."="..T.BASECURRENCY.."\n")
		
	end		
		if T.CLIENT_CODE == CLIENTCODE..'/SW' then 
			PocketInit('Donor')
		else
			PocketInit('Client')
		end
		ToPocket(propertiTransaction)
		return CalculationTransaction(T,Param)
end	
-- Выставляет заявку
SetOrder = function(
   structParam,      -- Параметры для переноса смотри структуру structParamTransaction 
   operation,        -- Операция ('B' - buy, 'S' - sell)
   qty,              -- Количество
   clientCode        -- Код текущего клинта (-)   
)
   -- Выставляет заявку
   -- Получает ID для следующей транзакции
   trans_id = trans_id + 1
   -- Заполняет структуру для отправки транзакции
   local T = {}
   T['TRANS_ID']   = tostring(trans_id)				-- Номер транзакции
   T['ACCOUNT']    = ACCOUNT						-- Код счета
   T['CLASSCODE']  = CLASS_CODE						-- Код класса
   T['SECCODE']    = structParam.secCodeCurrency	 -- Код инструмента
   T['ACTION']     = TRANSACTION_TYPE				-- Тип транзакции ('NEW_ORDER' - новая заявка)      
   T['TYPE']       = TAG							-- Тип ('L' - лимитированная, 'M' - рыночная)
   T['OPERATION']  = operation						-- Операция ('B' - buy, или 'S' - sell)
   T['QUANTITY']   = tostring(qty)					-- Количество
   T['MATCHREF']   = '234134213'					--   
   T['PRICE']      = GetCorrectPrice(structParam)	-- Цена	
   T['CLIENT_CODE']   = tostring(clientCode..'/SW')  				-- CLIENT_CODE
   T['PARTNER']  	  =  PARTNER					-- PARTNER
   T['SETTLE_CODE']   =  SETTLE_CODE				-- SETTLE_CODE
   T['BASECURRENCY']  = structParam.baseCurrency
   -- Отправляет транзакцию
   ToLog("Proverca USLOVIYA(SetOrder) "..structParam.valuePlus.." "..qty)-- убрать тест!!!!!!!!!!!!!!!!!!!!!!!!!
   local Res = Transaction(T,structParam)
   -- Если при отправке транзакции возникла ошибка
   -- if Res ~= '' then
      -- -- Выводит сообщение об ошибке
      -- message('Error to open/close transaction:'..Res)
   -- end;
	ToLog(tostring('SENDTRANSACTION'..':'..'TRANS_ID'.."="..trans_id..";"..'CLASSCODE'.."="..CLASS_CODE..";"..'ACTION'.."="..TRANSACTION_TYPE..";"..'ACCOUNT'.."="..ACCOUNT..";"..'OPERATION'.."="..operation..";"..'SECCODE'.."="..structParam.secCodeCurrency..";"..'PARTNER'.."=".."MC0005600000"..";"..'PRICE'.."="..GetCorrectPrice(structParam)..";"..'QUANTITY'.."="..qty..";"..'CLIENT_CODE'.."="..clientCode..";"..'SETTLE_CODE'.."="..'T1'..";"..'BASEPRICE'.."="..structParam.baseCurrency.."\n"));
	--FLAFRES = Res
   return Res
end;	
	