local isFunction = function(fun)
    return "function" == type(fun);
end

local GetAwaiter = function()
    local task = {
        isCompleted = false,
        onCompletedList = {},
        result = nil
    };
    
    function task:OnCompleted(fun)
        if isFunction(fun) then
            table.insert(self.onCompletedList,fun)
        end
    end
    
    function task:Done ()
        if self.isCompleted then
            return
        end
        self.isCompleted = true;
        for i, v in ipairs(self.onCompletedList) do
            pcall(v,self.result)
        end
    end
    return task;
end

local IsAwaiter = function(awaiter)
    if awaiter == nil or "table" ~= type(awaiter) or awaiter.isCompleted == nil then
        return false
    end

    if awaiter.OnCompleted == nil or "function" ~= type(awaiter.OnCompleted) then
        return false
    end
    return true
end

return {
    GetAwaiter=GetAwaiter,
    IsAwaiter=IsAwaiter
}