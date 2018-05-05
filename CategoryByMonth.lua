Exporter{version          = 1.00,
         format           = "Category sums by month",
         fileExtension    = "csv",
         reverseOrder     = false,
         description      = "Export the transactions summed up by category for each month"}

function writeLine(line)
   assert(io.write(line, "\n"))
end

-- called once at the beginning of the export
function WriteHeader (account, startDate, endDate, transactionCount)
    -- initialize global array to store category sums
    categorySums = {}
    months = {}
    for l = 1, 12 do
        table.insert(months, l)
    end

    maxHierarchy = 0
    
    table.sort(months)
    _start = os.date('%b %d %Y', startDate)
    _end   = os.date('%b %d %Y', endDate)

    writeLine("Category sums from " .. _start .. " to " .. _end .. " (" .. transactionCount .. " transactions).")
    writeLine(os.date("File exported at %c."))
end


-- called for every booking day
function WriteTransactions (account, transactions)
    -- This method is called for every booking day.
    -- I use it to sum up all the bookings into a global categorySums variable.
    for _,transaction in ipairs(transactions) do
        month = tonumber(os.date("%m", transaction.bookingDate))
        categoryName = transaction.category
        
        if categoryName == "" then
          categoryName = "(ohne)"
        end

        level = countSubstring(categoryName, "\\")
        if level > maxHierarchy then 
            maxHierarchy = level
        end
        if (not categorySums[categoryName]) then 
            categorySums[categoryName] = {}
        end
        if (categorySums[categoryName][month]) then
            categorySums[categoryName][month] =
                categorySums[categoryName][month] + transaction.amount
        else
            categorySums[categoryName][month] = transaction.amount
        end
        -- assert(io.write("month ", month, " category ", categoryName, " amount: ", categorySums[categoryName][month], "\n"))

    end
end
function countSubstring(s1, s2)
    return select(2, s1:gsub(s2, ""))
end

function WriteTail (account)
    -- write the finished categories to CSV
    header = "";
    for l = 0, maxHierarchy do
        header = header .. "Level " .. l .. ";"
    end

    for l = 1, 12 do
        header = header .. l .. ";"
    end
    writeLine(header) 

    local sortedKeys = {}
    for k in pairs(categorySums) do table.insert(sortedKeys, k) end
    table.sort(sortedKeys)
    for _, k in ipairs(sortedKeys) do 
        -- count hierarchy level
        level = countSubstring(k, "\\")
        padding = ""
        for l = 1, (maxHierarchy - level) do
            padding = padding .. ";"
        end
        sum = ""
        for month in pairs(months) do
            if (categorySums[k][month]) then
                sum = sum .. string.gsub(tostring(categorySums[k][month] * -1), "%.", ",")
            end
            sum = sum .. ";"
        end
        writeLine(k .. padding .. ";" .. sum)

    end

end