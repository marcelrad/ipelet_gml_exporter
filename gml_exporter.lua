-- Ipe GML Exporter
-- A simple tool to export a graph represented 
-- by marks and line segments to the console  in gml format
--
--The MIT License (MIT)
--
--Copyright (c) 2015 Marcel Radermacher
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in
--all copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--THE SOFTWARE.

label = "GML export"

about = "Export a graph to gml format. "


function findLabel(model, pos) 
	local l = ""
	for i, obj, sel, layer in model:page():objects() do
		if (obj:type() == "text") then
			if  (obj:position() - pos):sqLen() < 1 then
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
		local l = findLabel(model, obj:position())
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
function handleCurve(model, curve)
	local p = model:page()
	for _, seg in ipairs(curve) do
		if (seg["type"] == "segment") then
			local is_source = true
			local source = -1
			local target = -1
			
			for k, v, _, _ in p:objects() do 
				if (v:type() == "reference") then
					for j, p in ipairs(seg) do
						if (p - v:position()):sqLen() < 1 then
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
				handleCurve(model, subPath)
			end
		end
	  ::continue::
	end
	print("]")
end


