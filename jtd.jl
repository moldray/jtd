#!/usr/local/bin/julia -q --color=yes

dataFile = "$(homedir())/.jtodo.jls"
pending = '✘'
isdone = '✔'

save(data) = begin
  open(f->serialize(f, data), dataFile, "w")
end

load() = begin
  open(deserialize, dataFile)
end

if !isfile(dataFile)
  save([])
end

todos = load()


ls(args) = begin
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

final() = begin
  ls([])
  save(todos)
end

intify(id) = begin
  parse(Int, id)
end

ad(args) = begin
  for i = 1:length(args)
    newTodo = "| $pending $(args[i])"
    push!(todos, newTodo)
  end

  final()
end

rm(args) = begin
  sort!(args, rev=true)

  for arg in args
    splice!(todos, parse(Int, arg))
  end

  final()
end

ch(args) = begin
  (id, cont) = args
  intid = intify(id)

  if search(todos[intid], pending) > 0
    todos[intid] = "| $pending $cont"
  else
    todos[intid] = "| $isdone $cont"
  end

  final()
end

sw(args) = begin
  (id1, id2) = map(intify, args)
  (todos[id1], todos[id2]) = [todos[id2], todos[id1]]

  final()
end

tg(args) = begin
  id = intify(args[1])

  if search(todos[id], pending) > 0
    todos[id] = replace(todos[id], pending, isdone)
  else
    todos[id] = replace(todos[id], isdone, pending)
  end

  final()
end

cl(args) = begin
  len = length(todos)

  while len > 0
    if(search(todos[len], isdone) > 0)
      splice!(todos, len)
    end
    len = len - 1
  end

  final()
end

usage() = begin
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

handler(args) = begin
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

main() = begin
  if length(ARGS) == 0
    usage()
  else
    handler(ARGS)
  end
end

main()