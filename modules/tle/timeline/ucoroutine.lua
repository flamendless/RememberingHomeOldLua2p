-- MIT License
-- 
-- Copyright (c) 2020 moo-sama
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


local ucoroutine = { }

local PATH = (...):gsub("%.", "/")

local err_msg
local err_traceback


local debug_traceback = debug.traceback
function debug.traceback(msg, level)
  if err_traceback then
    local tcb = debug_traceback(msg or "", (level or 0) + 3)
    local full_msg = tcb:sub(1, tcb:find("stack traceback") - 1)
    local _, i = tcb:find(PATH .. "[^\n]*'do_ucoroutine_error'")
    if i then
      tcb = tcb:sub(i + 2)
      tcb = tcb:sub(tcb:find("\n") + 1)
      tcb = "stack traceback:\n" .. err_traceback .. "\n" .. tcb
      return full_msg .. tcb
    else
      err_msg, err_traceback = nil, nil
    end
  end
  return debug_traceback(msg or "", level)
end


local function do_ucoroutine_error(...)
  error(..., 3)
end
local function coalesce(success, ...)
  if not success then
    do_ucoroutine_error(err_msg)
  end
  return ...
end
function ucoroutine.resume(cr, ...)
  return coalesce(coroutine.resume(cr, ...))
end

function ucoroutine.traceback(level)
  level = (level or 1) + 2
  if err_traceback then level = level + 3 end
  local tcb = debug_traceback("", level)
        tcb = tcb:sub(select(2, tcb:find("stack traceback[^\n]\n")) + 1)
        tcb = tcb:sub(1, tcb:find("[^\n]*\n[^\n]*$") - 2)
  
  local i = tcb:find("function[^\n]*$")
  tcb = tcb:sub(1, i - 1) .. "coroutine" .. tcb:sub(i + 8)

  return tcb
end

function ucoroutine.errorevent(msg)
end

local function errhand(msg)
  if not err_msg then
    err_msg = msg:sub(select(2, msg:find(":")) + 4)
  end

  local tcb = ucoroutine.traceback()

  if err_traceback then err_traceback = err_traceback .. "\n" .. tcb
  else
    err_traceback = tcb 
    ucoroutine.errorevent(msg)
  end
end
local function safe_wrap(f)
  return function(...)
    return coalesce(xpcall(f, errhand, ...))
  end
end
function ucoroutine.create(f)
  return coroutine.create(safe_wrap(f))
end

function ucoroutine.wrap(f)
  local cr = ucoroutine.create(f)
  return function(...)
    return ucoroutine.resume(cr, ...)
  end
end


return ucoroutine