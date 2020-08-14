RegisterCommand(
  "addprio",
  function(source, args, raw)
    if source ~= 0 then
      return
    end

    if #args ~= 2 then
      Utils.DebugPrint("Arguments must be [identifier] [donationLevel]")
      return
    end

    local manualIdentifier = tostring(args[1])

    local donationLevel = tonumber(args[2])

    if donationLevel > 3 then
      donationLevel = 3
    end

    local priority = 50

    if donationLevel == 2 then
      priority = 51
    elseif donationLevel == 3 then
      priority = 52
    end

    local identifier = manualIdentifier:gsub(".*:", "")
    local results =
      exports["ggsql"]:QueryResult(
      "SELECT id FROM users WHERE licenseId=@lid OR steamId=@lid OR discordId=@lid",
      {
        lid = identifier
      }
    )

    local userId = 0

    if results[1] then
      local user = results[1]
      userId = tonumber(user.id)
      manualIdentifier = ""
    end

    exports["ggsql"]:QueryAsync(
      "REPLACE INTO queue (userId,donatorLevel,priority,manualIdentifier) VALUES (NULLIF(@uid, 0),@dl, @p,NULLIF(@mid,''))",
      {
        uid = userId,
        dl = donationLevel,
        p = priority,
        mid = manualIdentifier
      },
      function(result)
        if result == 1 then
          Utils.DebugPrint("Successfully added player into queue DB")
        elseif result > 1 then
          Utils.DebugPrint("Updated player queue priority in DB")
        end
      end
    )

    Queue.AddPriority(manualIdentifier, priority)
  end,
  true
)
