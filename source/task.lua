require("async")
local awaitable = require("awaitable")
local IsAwaiter = awaitable.IsAwaiter
local CreateTask = awaitable.GetAwaiter
local Task = {CreateTask=CreateTask}

Task.WhenAny = function(...)
    local task = CreateTask()
    local awaiters = {...}
    
    if #awaiters == 0 then
        task:Done()
        return task
    end
    local done = function()
        task:Done()
    end
    for i, v in ipairs(awaiters) do
        if IsAwaiter(v) then
            if v.isCompleted then
                task:Done()
            else
                v:OnCompleted(done)
            end
        end
    end
    
    return task
end

Task.WhenAll = function(...)
    local task = CreateTask()
    local awaiters = {...}
    local taskLen = #awaiters
    
    if taskLen == 0 then
        task:Done()
        return task
    end
    
    local doneCount = 0
    local done = function()
        doneCount = doneCount + 1
        if doneCount >= taskLen then
            task:Done()
        end
    end
    for i, v in ipairs(awaiters) do
        if IsAwaiter(v) then
            if v.isCompleted then
                done()
            else
                v:OnCompleted(done)
            end
        end
    end

    return task
end

--[[
predicate: function:bool
--]]
Task.WaitUntil = function(predicate)
    
end

Task.Delay = function(time)
    
end

return Task;