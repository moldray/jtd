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
  for (i, todo) in enumerate(todos) 
    item = "$i $todo \n"
    len = length(args)

    if search(todo, pending) > 0 
      if len == 0 || args[1] != "-d"
        print_with_color(:red, item)
      end
    else
      if len > 0 && args[1] != "-p"
        print_with_color(:green, item)
      end
    end
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

function usage()
  str = """
    ls => list
    ad => add
    rm => remove
    ch => change
    sw => swap
    tg => toggle
    cl => clean
  """
  
  println(str)
end

function handler(args)
  cmd = args[1]
  newArgs = args[2:end]
  dict = Dict(
    "ls" => ls,
    "ad" => ad,
    "rm" => rm,
    "ch" => ch,
    "sw" => sw,
    "tg" => tg,
    "cl" => cl,
  )

  get(dict, cmd, usage)(newArgs)
end

if length(ARGS) == 0
  usage()
else
  handler(ARGS)
end
