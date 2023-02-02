local co = coroutine
local awaitable = require("awaitable")
local isFunction = function(fun)
    return "function" == type(fun);
end

async = function(fun)
    return function(...)
        if not isFunction(fun) then
            return
        end

        local thread = co.create(fun)
        local next = nil
        local awaiter = awaitable.GetAwaiter()
        next = function(...)
            local state, moveNext = co.resume(thread,...)
            if "dead" ~= co.status(thread) then
                if isFunction(moveNext) then
                    moveNext(next)
                end
            else
                awaiter.result = moveNext
                awaiter:Done()
            end
        end

        next(...)

        return awaiter
    end
end

await = function(awaiter)

    if not co.isyieldable() then
        error("not yield")
        return
    end
    
    if awaiter == nil or "table" ~= type(awaiter) then
        return
    end

    if awaiter.isCompleted == nil or awaiter.isCompleted then
        return awaiter.result
    end
    
    return co.yield(function(continuation)
        if awaiter.isCompleted then
            continuation(awaiter.result)
        else
            awaiter:OnCompleted(continuation)
        end
    end)
end

asyncWraper = function(fun,...)
    async(fun)(...)
end
