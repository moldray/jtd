#!/usr/local/bin/julia -q --color=yes

using JLD

dataFile = "$(homedir())/.jtodo.jld"
pending = '✘'
isdone = '✔'

if !isfile(dataFile)
  todos = []
  save(dataFile, "todos", todos)
end

todos = load(dataFile, "todos")


function ls(args)
  len = length(args)

  function lsP()
    for (i, todo) in enumerate(todos) 
      item = "$i $todo \n"
      if search(todo, pending) >0 
        print_with_color(:red, item)
      end
    end
  end

  if len ==0
    return lsP()
  end

  arg = args[1]

  function lsD()
    for (i, todo) in enumerate(todos) 
      item = "$i $todo \n"
      if search(todo, isdone) >0 
        print_with_color(:green, item)
      end
    end
  end

  function lsA()
    for (i, todo) in enumerate(todos) 
      item = "$i $todo \n"
      if search(todo, pending) >0 
        print_with_color(:red, item)
      else
        print_with_color(:green, item)
      end
    end
  end

  if arg == "-p"
    lsP()
  elseif arg == "-d"
    lsD()
  else
    lsA()
  end
end


function final()
  ls([])
  save(dataFile, "todos", todos)
end

function intify(id)
  return parse(Int, id)
end

function ad(args)
  for i = 1:length(args)
    newTodo = "| $pending $(args[i])"
    push!(todos, newTodo)
  end

  final()
end

function rm(args)
  sort!(args, rev=true)

  for arg in args
    splice!(todos, parse(Int, arg))
  end

  final()
end

function ch(args)
  (id, cont) = args
  intid = intify(id)

  if search(todos[intid], pending) > 0
    todos[intid] = "| $pending $cont"
  else
    todos[intid] = "| $isdone $cont"
  end

  final()
end

function sw(args)
  (id1, id2) = map(intify, args)
  (todos[id1], todos[id2]) = [todos[id2], todos[id1]]

  final()
end

function tg(args)
  id = intify(args[1])

  if search(todos[id], pending) > 0
    todos[id] = replace(todos[id], pending, isdone)
  else
    todos[id] = replace(todos[id], isdone, pending)
  end

  final()
end

function cl(args)
  i = 0

  while i < length(todos)
    i = i + 1
    if(search(todos[i], isdone) > 0)
      splice!(todos, i)
      i = i - 1
    end
  end

  final()
end


function handler(args)
  cmd = args[1]
  newArgs = args[2:end]

  if cmd == "ls"
    ls(newArgs)
  elseif cmd== "ad"
    ad(newArgs)
  elseif cmd == "rm"
    rm(newArgs)
  elseif cmd == "ch"
    ch(newArgs)
  elseif cmd == "sw"
    sw(newArgs)
  elseif cmd == "tg"
    tg(newArgs)
  elseif cmd == "cl"
    cl(newArgs)
  else
    println("ls:list, ad:add, rm:remove, ch:change, sw:swap, tg:toggle, cl:clean")
  end
end

if length(ARGS) == 0
  println("args is needed.")
else
  handler(ARGS)
end
