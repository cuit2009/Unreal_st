function foo(a)
    print("foo", a)
    return coroutine.yield(2 * a)
end

co = coroutine.create(function ( a, b )
    print("co-body", a, b)
    local r = foo(a + 1)
    print("co-body", r)
    local r, s = coroutine.yield(a + b, a - b)
    print("co-body", r, s, a, b)
    return b, "end"
end)

-- print("main", coroutine.resume(co, 1, 10))
-- print("main", coroutine.resume(co, "r"))
-- print("main", coroutine.resume(co, "x", "y"))
-- print("main", coroutine.resume(co, 2, 11))


---16进制转 str----

--将16进制串转换为字符串
function hex2str(hex)
    --判断输入类型
    if (type(hex)~="string") then
        return nil,"hex2str invalid input type"
    end
    --拼接字符串
    local index=1
    local ret=""
    for index=1,hex:len() do
        ret=ret..string.format("%02X",hex:sub(index):byte())
    end

    return ret
end

-- print(" str to 16 bit test ",tonumber("ffff", 16), 0xffff)
-- print("16 bit to str test ", tostring("ffff", 16))
function table.tostring(t, usen)
    if t == nil then return nil end

    if type(t) ~= "table" then return tostring(t) end
    if t.tostring and type(t.tostring)=="function" then
        return t:tostring();
    end
    local str, _type = "";
    local nchar = usen and "\n" or "";
    for k, v in pairs(t) do
        _type = type(v);
        if _type == "nil" then
            str = str .. k .. "=nil, " .. nchar;
        elseif _type == "table" then
            if(v.class) then
                str = str .. k .. "={" .. (v.tostring and v.tostring(v) or ("class="..tostring(v.class.__cname))).. "}, " .. nchar;
            else
                str = str .. k .. "={" .. (v.tostring and v.tostring(v) or table.tostring(v, usen)).. "}, " .. nchar;
            end
        else
            str = str .. k .. "=" .. tostring(v) .. ", " .. nchar;
        end
    end
    return str;
end

function tostring_table_2(obj)
  local retStr = ""
    function make(obj)
        local szType = type(obj);
        if szType == "number" then
            retStr = retStr..obj
        elseif t == "boolean" then  
            retStr = retStr .. tostring(obj) 
        elseif szType == "string" then
            retStr = retStr..string.format("%q", obj)
        elseif szType == "table" then
            retStr = retStr.."{"
            for i, v in pairs(obj) do
                retStr = retStr.."["
                make(i);
                retStr = retStr.."]="
                make(v);
                retStr = retStr..", "
            end
            -- local metatable = getmetatable(obj)  
            --     if metatable ~= nil and type(metatable.__index) == "table" then  
            --     for k, v in pairs(metatable.__index) do  
            --         lua = lua .. "[" .. make(k) .. "]=" .. make(v) .. ",\n"  
            --     end  
            -- end  

            retStr = retStr.."}"
        else
            print("can't serialize a "..szType);
        end
    end
    make(obj)
    retStr = retStr

    return retStr
end
function table_to_string(obj)
    local retStr = "return "
    function make(obj)
        local szType = type(obj);
        if szType == "number" then
            retStr = retStr..obj
        elseif szType == "string" then
            retStr = retStr..string.format("%q", obj)
        elseif szType == "table" then
            retStr = retStr.."{\n"
            for i, v in pairs(obj) do
                retStr = retStr.."["
                make(i);
                retStr = retStr.."]=\n"
                make(v);
                retStr = retStr..", \n"
            end
            retStr = retStr.."}\n"
        else
            logError("can't serialize a "..szType);
        end
    end
    make(obj)
    retStr = retStr
    return retStr
 end

function serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
    for k, v in pairs(obj) do  
        lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
        end  
    end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        print("can not serialize a " .. t .. " type.") 
        -- lua = lua .. tostring(obj)  
    end  
    return lua  
end 


local w = {a=2,b=3}
-- w.property = function()
--     return "a test"
-- end
--test 1--
local luaStr =  "return "..serialize(w)
print(" table test 2 ", luaStr)

-- local luatable = loadstring(luaStr)
-- local luatotable = nil
-- if luatable then
--     luatotable = luatable()
-- end

-- local test_str = "return {a=1, b=2}";
local str_table = nil
 str_table = loadstring(luaStr)
 local str_table2 = str_table()
 print(" String to table ", table_to_string(str_table2))
-- function foo_hand()
--  str_table = loadstring(luaStr)
--  local str_table2 = str_table()
--  print(" String to table ", table_to_string(str_table2))
-- end
-- r, msg = pcall(foo_hand)
-- if r then
--     print("This is ok 2.")
-- else
--     print("This is error 2 .")
--     print(msg)
-- end

---test 2---
-- function errorFunc()
--      local a = 20
--      print(a[10])
--  end
 
-- function errorHandle()
--  print(debug.traceback())
-- end
 
--  if xpcall(foo_hand,errorHandle) then
--      print("This is OK.")
--  else
--      print("This is error.")
--  end

---test 3----

-- function square(a)
--   return a * "a"
-- end

-- local status, retval = pcall(square,10);

-- print ("Status: ", status)        -- 打印 "false" 
-- print ("Return Value: ", retval)  