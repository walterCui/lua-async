local Task = require("task")

task = Task.CreateTask()
fly = async(function (arg)
    print(arg)
    await(task)
    print(1233,"fly end")
    return "fly"
end)

local collect = Task.CreateTask()

async(function()
    print("main start")
    local temp = Task.WhenAny(fly("fly start1"),collect);
    --local temp = Task.WhenAll(async(fly,'fly start'),collect);
    await(temp)
    print("main end")
end)()

print("task done")
task:Done()
print("collect done")
collect:Done()
print("over")