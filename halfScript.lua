ACCOUNT_DEPO		    = 'MB0005608694'	-- Код счета


function Init()
	-- Создает папку для логов 
		pathSaveLog = "C:/LUA/22052018/Log"
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


function toLog(str)
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

---ГЛАВНАЯ ФУНКЦИЯ.	------------------
function main()
    Init();
    local getLimitsTableDepo = function(depo,client)
             
        local TableIndex = SearchItems("depo_limits",0,getNumberOf("depo_limits")-1, 
        function(trdaccid,client_code)
            if (trdaccid == depo) and (client_code == client) then  
                return true; 
            else 
                return false; 
            end 
        end,"trdaccid,client_code");
        return TableIndex;
    end
end

    local Table  = getLimitsTableDepo();
    toLog("trdaccid: "..#Table);
    for j =1, #Table do
        toLog("trdaccid: "..Table[j]);
        -- ClientCode = getItem("money_limits",Table[j]).client_code;
        -- if FindAray(TableClientCode,ClientCode) then 
        --     table.insert(TableClientCode,ClientCode);
        -- end
    end 
    -- local tradeDataUsd = getParamEx("CNGD", "USD000TODTOM",'TRADE_DATE_CODE').param_image;
    -- local setyleDateUsd = getParamEx("CNGD", "USD000TODTOM",'SETTLEDATE').param_image;

    -- toLog("tradeDataUsd: "..tradeDataUsd.."setyleDateUsd: "..setyleDateUsd);

    -- local tradeDataEur = getParamEx("CNGD", "EUR000TODTOM",'TRADE_DATE_CODE').param_image
    -- local setyleDateEur = getParamEx("CNGD", "EUR000TODTOM",'SETTLEDATE').param_image

    -- toLog("tradeDataEur: "..tradeDataEur.."setyleDateEur: "..setyleDateEur);

    -- local tradeDataGbp = getParamEx("CNGD", "GBPRUBTODTOM",'TRADE_DATE_CODE').param_image
    -- local setyleDateGbp = getParamEx("CNGD", "GBPRUBTODTOM",'SETTLEDATE').param_image

    -- toLog("tradeDataGbp: "..tradeDataGbp.."setyleDateGbp: "..setyleDateGbp);

    -- local tradeDataEurUsd = getParamEx("CNGD", "EURUSDTODTOM",'TRADE_DATE_CODE').param_image
    -- local setyleDateEurUsd = getParamEx("CNGD", "EURUSDTODTOM",'SETTLEDATE').param_image

    -- toLog("tradeDataEurUsd: "..tradeDataEurUsd.."setyleDateEurUsd: "..setyleDateEurUsd);

    -- local tradeDataGbpUsd = getParamEx("CNGD", "GBPUSDTODTOM",'TRADE_DATE_CODE').param_image
    -- local setyleDateGbpUsd = getParamEx("CNGD", "GBPUSDTODTOM",'SETTLEDATE').param_image

    -- toLog("tradeDataGbpUsd: "..tradeDataGbpUsd.."setyleDateGbpUsd: "..setyleDateGbpUsd); 
    
end;
