-- Ipe GML Exporter
-- A simple tool to export a graph represented 
-- by marks and line segments to the console  in gml format
--
--Copyright (C) 2015  Marcel Radermacher
--
-- This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.

--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.

--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.

label = "GML export"

about = "Export a graph to gml format. "


function findLabel(model, pos) 
	local l = ""
	for i, obj, sel, layer in model:page():objects() do
		if (obj:type() == "text") then
			if  (obj:matrix() * obj:position() - pos):sqLen() < 1 then
				l =  obj:text()
				break
			end
		end
	end
	return l 
end

function printNode(model, i, obj) 
	if (obj:type() == "reference") then
		print("\tnode [")
		print("\t\tid " .. tostring(i))
		local l = findLabel(model, obj:matrix() * obj:position())
		if (l  == "") then
			l = i	
		end  
		print("\t\tlabel \"" .. tostring(l) .. "\"")
		print("\t\tgraphics [")
		print("\t\t\tx " .. tostring(obj:position().x))
		print("\t\t\ty " .. tostring(obj:position().y))
		print("\t\t]")
		print("\t]")
	end
end

function printEdge(model, source, target)

	if (source >= 0 and target >= 0) then
		print("\tedge [")
		print("\t\tsource " .. tostring(source))
		print("\t\ttarget " .. tostring(target))
		print("\t]")
	end
end

function handleCurve(model, curve, obj)
	local p = model:page()
	for _, seg in ipairs(curve) do
		--print("-----------------------------------------------")
		if (seg["type"] == "segment") then
			local is_source = true
			local source = -1
			local target = -1
			
			for k, v, _, _ in p:objects() do 
				if (v:type() == "reference") then
					for _, pos in ipairs(seg) do
						if (obj:matrix() * pos - v:matrix() * v:position()):sqLen() < 1 then
						
							if (is_source) then
								source = k
								is_source = false
							else
								target = k
							end
						end
					end
				end
			end
			printEdge(model, source, target)
		end
	end
end

-- output the current graph on the console
function run(model)
	print("Creator \"IPE GML Exporter\"")	
	print("graph [")
	print("\tdirected 0")
	local p = model:page()
	for i, obj, sel, layer in p:objects() do
		printNode(model, i, obj)
	end

	for i, obj, sel, layer in p:objects() do
		-- do nothing if the object is invisible and invisible objects
		-- should not be moved
		if not p:visible(model.vno, layer) and
			not moveInvisibleObjects then
				goto continue
		end
		
		-- do nothing if it is not a path
		if obj:type() ~= "path" then
			goto continue
		end
			
		local shape = obj:shape()
		
		for _, subPath in ipairs(shape) do
			if (subPath["type"] == "curve") then
				handleCurve(model, subPath, obj)
			end
		end
	  ::continue::
	end
	print("]")
end


