function print_r(t)
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            Citizen.Trace(indent.."*"..tostring(t).."\n")
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        Citizen.Trace(indent.."["..pos.."] => "..tostring(t).." {".."\n")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        Citizen.Trace(indent..string.rep(" ",string.len(pos)+6).."}".."\n")
                    else
                        Citizen.Trace(indent.."["..pos.."] => "..tostring(val).."\n")
                    end
                end
            else
                Citizen.Trace(indent..tostring(t).."\n")
            end
        end
    end
    sub_print_r(t,"  ")
end