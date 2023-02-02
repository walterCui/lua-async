local Task = require("task")

t = Task.CreateTask()
t.result = 100
--t:Done()

t2 = Task.CreateTask()
t2.result = "my is task2"

local print1 = async(function() 
   print(123)  
   local temp = await(t)
   print(temp)
   --if true then
   --    return "this is print1xxx"
   --end
   print(await(t2))
   print(2)
   return "this is print1"
end)

local print2 = async(function (arg)
   print(arg)
   print(await(print1()))
   print("prin2",arg)
end)

print2("to print2")
print2("to print23")

print("xxx")
t:Done()
print("yyy")
t2:Done()