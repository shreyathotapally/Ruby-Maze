#!/usr/local/bin/ruby

# ########################################
# CMSC 330 - Project 1
# ########################################

#-----------------------------------------------------------
# FUNCTION DECLARATIONS
#-----------------------------------------------------------

def num_open_cells(file)
  open_cells = 0

  while line = file.gets 
    if line == nil then return end

    if line[0...4] != "path"
      x, y, ds, w = line.split(/\s/,4)
      ds = ds.chars
      if(ds.length() == 4)
        open_cells+=1
      end
    end
  end
  return open_cells
end
#***************************************# 
def num_bridges(file)
  line = file.gets
  bridges = 0
  dirs = Array.new
  i = 0

  if line == nil then return end

  sz, sx, sy, ex, ey = line.split(/\s/)

  while line = file.gets 
    if line[0...4] != "path" 
      x, y, ds, w = line.split(/\s/, 4)
      dirs.push(ds)
    end
  end

  while i < dirs.length()
    if dirs[i].include?('d') && dirs[i + 1].include?('d')
      bridges += 1
    elsif dirs[i].include?('r') && dirs[i + sz.to_i].include?('r')
      bridges +=1 
    end
    i+=1
  end
  return bridges
end 
#***************************************# 
def sort_cells(file)
  dirs = 0
  xy_hash = Hash.new {|key,val| key[val] = []}
  sorted_cells = []
  temp = []
  line = file.gets

  if line == nil then return end

  sz, sx, sy, ex, ey = line.split(/\s/)

  while line = file.gets do
    if line[0...4] != "path" 
      x, y, ds, w = line.split(/\s/, 4)
      xy_hash[ds.size()].push("(#{x},#{y})")
      temp.push("(#{x},#{y})") 
    end
  end

  i = 0
  j = 0
  while i < sz.to_i
    while j < sz.to_i
      if !temp.include?("(#{i},#{j})") 
        xy_hash[0].push("(#{i},#{j})")
      end
      j+=1
    end
    i+=1
  end

  xy_hash.sort.to_h

  i = 0
  while i <= sz.to_i 
    if xy_hash[i] != [] 
      sorted_cells.push "#{i},#{xy_hash[i].join(",")}"
    end
    i+=1
  end

  if temp == nil 
    return 
  else
    return sorted_cells
  end
end
#***************************************# 
def paths(file)
  lines = Hash.new {|key,val| key[val] = []}
  path = Hash.new {|key,val| key[val] = []}
  cost = []
  none = 0
  line = file.gets

  if line == nil then return end

  sz, sx, sy, ex, ey = line.split(/\s/)

  while line = file.gets 
    if line == nil then return end
    if line[0...4] == ("path") 
      p, name, x, y, ds = line.split(/\s/)
      temp = [x.to_i, y.to_i]
      if ds != nil 
        dirs = ds.chars
      end

      if dirs != nil && dirs != "" 
        path["#{name}"].push(temp)
        path["#{name}"].push(dirs)
      end
      none = 1
    else
      x, y, ds, w = line.split(/\s/,4)
      temp = [x.to_i, y.to_i]
      ws = []
      if w != nil && !w.eql?("") 
        ws = w.split(/\s/)
      end
      lines[temp].push(ds)
      lines[temp].push(ws)
    end
  end

  lines = line_sort(lines, sz.to_i)
  if none != 1
     return "none"
  end

  for key in path.keys do
    check = 0
    weights = 0
    i = 0
    x_y = path[key][0]
    dirs = path[key][1]
    while i < dirs.length
      if lines[x_y][0].include?("#{dirs[i]}") 
        temp = lines[x_y][0].index("#{dirs[i]}")
        weights += lines[x_y][1][temp].to_f
      else
        check = 1
      end
      
      if check != 1
        case dirs[i]
        when "u"
          x_y[1] -= 1
        when "d"
          x_y[1] += 1
        when "r"
          x_y[0] += 1
        when "l"
          x_y[0]  -= 1
        end
      end
      i += 1
    end

    if check != 1 
      str = ""
      str += "%10.4f #{key}" % weights
      cost.push(str)
    end
  end

  if cost == [] || cost == nil
    return "none"
  else
    cost = cost.sort_by {|word| word.scan(/\d+/).first.to_f}
    return cost
  end
end
#***************************************# 
def distance(file)
  lines = []
  queue = Queue.new
  path = Hash.new

  while(line = file.gets) 
    if line == nil then return end
    lines.push(line)
  end

  sz, sx, sy, ex, ey = lines[0].split(/\s/)

  i = 1
  while lines[i].index(/^#{sx} #{sy}/) == nil 
    i += 1
  end

  queue.push(i)

  cell = Hash.new
  cell[i] = 0
  while queue.empty? != true 
    a = queue.pop
    x, y, ds, w = lines[a].split(/\s/,4)
    path[a] = cell[a]
    j = 0
    while j < ds.length 
      temp = ds[j]
      b = a
      if temp == "u" 
        b -= 1
        if path.key?(b) == false 
          queue.push(b)
          cell[b] = cell[a] + 1
        end
      elsif temp == "d" 
        b += 1
        if path.key?(b) == false 
          queue.push(b)
          cell[b] = cell[a] + 1
        end
      elsif temp == "r" 
        b += sz.to_i
        if path.key?(b) == false 
          queue.push(b)
          cell[b] = cell[a] + 1
        end
      else
        b -= sz.to_i
        if path.key?(b) == false 
          queue.push(b)
          cell[b] = cell[a] + 1
        end
      end
      j += 1
    end
  end

  max = 0
  path.each do |key,val|
    if val > max 
      max = val
    end
  end

  distance = Array.new(max + 1)
  i = 0
  while i < distance.length 
    str = "#{i}"
    distance[i] = str
    i += 1
  end

  path = path.sort
  path.each do |key,val|
    x, y, ds, w = lines[key].split(/\s/,4)
    distance[val] += ",(#{x},#{y})"
  end
  return distance.join("\n")
end
#***************************************# 
def solve(file)
  lines = []
  dist = distance(file)
  
  file.rewind
  
	while(line = file.gets)
	  if line == nil then return end
    lines.push line
  end

  sz, sx, sy, ex, ey = lines[0].split(/\s/)
   
  if dist.include?("(#{sx},#{sy})") 
    if dist.include?("(#{ex},#{ey})") 
      return true
    else
      return false
    end
  else
    return false
  end
end
#***************************************# 
def parse(file)
  puts "Not yet implemented"    
end
#***************************************# 
def line_sort(lines, sz)
  if lines == nil 
    i = 0
    j = 0
    size_arr = sz.to_i

    while i < size_arr
      while j < size_arr  
        temp = [i, j]
        lines[temp].push("")
        lines[temp].push("")
      end
      j+=1
    end
    i+=1
  end

  k = 0
  l = 0
  size_arr = sz.to_i

  while k < size_arr
    while l < size_arr
      temp = [k, l]
      if !lines.keys.include?(temp) 
        lines[temp].push("")
      end
      l+=1
    end
    k+=1
  end
  return lines.sort.to_h
end
#***************************************#  
def pretty_print(file)
  lines = Hash.new {|key,val| key[val] = []}
  path_hash = Hash.new {|key,val| key[val] = []}
  line = file.gets
  pretty_print = []
  shortest = []
  border = "+"
  start_path = 0
  end_path = 0

  if line == nil then return end 

  sz, sx, sy, ex, ey = line.split(/\s/)

  while line = file.gets do

    if line[0...4]==("path") 
      p, name, x, y, ds = line.split(/\s/)
      temp = [x.to_i, y.to_i]
      if ds != nil && !ds.eql?("")
        dirs = ds.chars
      end
      path_hash["#{name}"].push(temp)
      path_hash["#{name}"].push(dirs)
      flag = 1
    else
      x, y, ds, w = line.split(/\s/,4)
      temp = [x.to_i, y.to_i]
      lines[temp].push(ds)
    end
  end

  j = 0
  while j < sz.to_i
    border += "-+"
    j += 1
  end

  pretty_print.push(border)

  lines = line_sort(lines, sz.to_i)
  file.rewind

  if flag == 1 
    arr = paths(file)
    if arr != "none"
      short_path = arr[0].split(" ")[1]

      i = 0
      x_y = path_hash["#{short_path}"][0]
      dir = path_hash["#{short_path}"][1]
      shortest.push ["#{x_y}"]

      while i < dir.length 
        if lines[x_y][0].include?("#{dir[i]}")
          case dir[i]
          when "u"
            x_y[1] -= 1
          when "d"
            x_y[1] += 1
          when "r"
            x_y[0] += 1
          when "l"
            x_y[0]  -= 1
          end
        end
        i += 1
        shortest.push ["#{x_y}"]
      end
    else 
      flag = 0
    end
  end

  start_i = [sx.to_i, sy.to_i]
  end_i = [ex.to_i, ey.to_i]

  temp_arr = []
  arr_temp = []
  
  for key in lines.keys do
    temp = key
    arr_temp.push temp
  end

  s = 0
  k = 0
  for i in (0...sz.to_i) do
    for j in (s...arr_temp.length).step(sz.to_i)
      temp_arr[k] = arr_temp[j]
      k += 1
    end
    s += 1
  end

  short_size = (shortest.length() - 1)
  size = (sz.to_i * sz.to_i)
  
  k = 0
  i = 0
  
  while i < sz.to_i 
    str = "|"
    wall = "+"
    j = 0
    while j < size && k < size 
      num = 0
      l = 0
      while l < shortest.length() 
        if shortest[l].include?("#{temp_arr[k]}") 
          num = 1
        end
        l += 1
      end

      if temp_arr[k] == start_i 
        if flag == 1 
          if shortest[0].include?("#{start_i}") || 
            shortest[short_size].include?("#{start_i}")
            str += "S"
            start_path = 1
          else
            str += "s"
          end
        else
          str += "s"
        end

        if lines[temp_arr[k]].fetch(0) == nil
          str += "|"
        else
          if lines[temp_arr[k]].fetch(0).include?("r") 
            if num == 1 && flag == 1 && start_path != 1 
              str += "*"
            else
              str += " "
            end
          else
            str += "|"
          end
        end
      elsif temp_arr[k] == end_i 
        if flag == 1 
          if shortest[0].include?("#{end_i}") || 
            shortest[short_size].include?("#{end_i}") 
            str += "E"
            end_path = 1
          else
            str += "e"
          end
        else
          str += "e"
        end

        if lines[temp_arr[k]].fetch(0) == nil 
          str += "|"
        else
          if lines[temp_arr[k]].fetch(0).include?("r") 
            if num == 1 && flag == 1 && end_path != 1 
              str += "*"
            else
              str += " "
            end
          else
            str += "|"
          end
        end
      elsif lines[temp_arr[k]].fetch(0).include?("r") 
        if num == 1 && flag == 1
          str += "* "
        else
          str += "  "
        end
      else
        if num == 1 && flag == 1 
          str += "*|"
        else
          str += " |"
        end
      end
      
      if lines[temp_arr[k]].fetch(0) == nil 
        wall += "-+"
      else
        if lines[temp_arr[k]].fetch(0).include?("d") 
          wall += " +"
        else
          wall += "-+"
        end
      end
      j += sz.to_i
      k += 1
    end
    i += 1
    pretty_print.push(str)
    if(i < sz.to_i)
      pretty_print.push(wall)
    end
  end
  pretty_print.push(border)
  return pretty_print.join("\n")
end

#-----------------------------------------------------------
# the following is a parser that reads in a simpler version
# of the maze files.  Use it to get started writing the rest
# of the assignment.  You can feel free to move or modify 
# this function however you like in working on your assignment.


def read_and_print_simple_file(file)
  line = file.gets
  if line == nil then return end

  # read 1st line, must be maze header
  sz, sx, sy, ex, ey = line.split(/\s/)
  puts "header spec: size=#{sz}, start=(#{sx},#{sy}), end=(#{ex},#{ey})"

  # read additional lines
  while line = file.gets do

    # begins with "path", must be path specification
    if line[0...4] == "path"
      p, name, x, y, ds = line.split(/\s/)
      puts "path spec: #{name} starts at (#{x},#{y}) with dirs #{ds}"

    # otherwise must be cell specification (since maze spec must be valid)
    else
      x, y, ds, w = line.split(/\s/,4)
      puts "cell spec: coordinates (#{x},#{y}) with dirs #{ds}"
      ws = w.split(/\s/)
      ws.each {|w| puts "  weight #{w}"}
    end
  end
end

#----------------------------------
def main(command_name, file_name)
  maze_file = open(file_name)

  # perform command
  case command_name
  when "parse"
    parse(maze_file)
  when "print"
    pretty_print(maze_file)
  when "open"
    num_open_cells(maze_file)
  when "bridge"
    num_bridges(maze_file)
  when "sortcells"
    sort_cells(maze_file)
  when "paths" 
    paths(maze_file) 
  when "distance"
    distance(maze_file) 
  when "solve"
    solve(maze_file)
  else
    fail "Invalid command"
  end
end

