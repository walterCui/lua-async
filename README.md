# lua async
lua中的coroutine本身提供了强大的功能，但是它属于基础API，在实现复杂逻辑的过程中，需要将coroutine进行包装，或者将coroutine的句柄传来传去。
针对上面的问题，借鉴C#中task机制，现用纯lua的代码实现了一套async机制。

## async
凡是需要异步的方法，都需要调用async方法，async方法返回一个特殊的function，我们称之为task function，其作用类似与c#中的动态编译过程。
task function返回一个内置的task用于其它的await调用。此处的async虽然是一个function，但是行为类似与c#中的关键字。

之前在lua中定义函数方式为 funciton xxx() end,之后调用xxx()即可。如果想使用async的话，需要修改为xxx = async(function() end),之后调用
xxx()或者调用await(xxx())都可以，具体调用哪一个根据是否要block/await某个行为来决定。

我们也提供了一个便捷的asyncwarper，用于直接调用使用。如asyncWraper(function() print(12) await(xxx) end)此时funciton中的内容会立刻被
调用，但是await还是会block住的。

## await
可以await的只能是**task**，task具有以下的限制
1. task是一个table（或者说是个class）
2. task要有isCompleted变量，用来标记是否完成
3. task完成的时候必须要调用onCompleted方法
4. task如果要有返回值得话，需要有result变量

### 内置task
此代码中内置了一个task，可通过createTask来创建

## Task
### WhenAny
只要有一个task完成，整体task即完成

### WhenAll
只有等所有task完成之后，整体task才完成

### ~~WaitUntil~~
等待某一个信号量，目前未实现

## 示例

### 等待task
```lua
local task = require("task")
t = task.CreateTask()
t.result = 100
local tempAsync = async(function()
    print(123)
    local temp = await(t)
    print(temp)
    print(2)
end)
tempAsync()
print("xxx")
t:Done()
```
上述代码中展示了在执行await的时候task还没有完成的情况，最终效果如下
```
123
xxx
100
2
```
### task先行完成,且使用了asyncWraper
```lua
local task = require("task")
t = task.CreateTask()
t.result = 100
t:Done()
asyncWraper(function()
    print(123)
    local temp = await(t)
    print(temp)
    print(2)
end)
print("xxx")
```
上述代码中展示了执行await的时候task已经完成的情况，最终效果如下
```
123
100
2
xxx
```
通过上述两个的执行结果，xxx的位置可以看出其中的执行顺序发生了很大的变化

### 等待一个async方法

```lua
local task = require("task")
t = task.CreateTask()
t.result = 100

local print1 = async(function() 
    print(123)  
    local temp = await(t)
    print(temp)
    print(2)
    return "this is print1"
end)

asyncWraper(function() 
    print(await(print1))
    print("prin2")
end)

print("xxx")
t:Done()
```
从下面的执行结果中可以发现，prin2是最后执行的
```
123
xxx
100
2
this is print1
prin2
```

### Task.WhenAny
参见代码[taskTest.lua](./demo/taskTest.lua)

# 代码
主要的代码都放在了[async.lua](./source/async.lua)

