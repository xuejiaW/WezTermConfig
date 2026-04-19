local platform = require 'platform'

local M = {}

local function first_existing(paths)
    for _, path in ipairs(paths) do
        local f = io.open(path, 'r')
        if f then
            f:close()
            return path
        end
    end
    return nil
end

local function split_path(path)
    local parts = {}
    if not path or path == '' then
        return parts
    end

    for entry in path:gmatch('[^:]+') do
        table.insert(parts, entry)
    end

    return parts
end

local function join_path(parts)
    return table.concat(parts, ':')
end

local function prepend_unique_path_entries(existing_path, entries)
    local parts = split_path(existing_path)
    local seen = {}

    for _, entry in ipairs(parts) do
        seen[entry] = true
    end

    for i = #entries, 1, -1 do
        local entry = entries[i]
        if entry ~= '' and not seen[entry] then
            table.insert(parts, 1, entry)
            seen[entry] = true
        end
    end

    return join_path(parts)
end

function M.apply_to_config(config)
    if platform.is_windows then
        config.default_prog = {'pwsh.exe', '-NoLogo'}
        return
    end

    -- GUI apps on macOS do not inherit your interactive shell PATH, so WezTerm
    -- often starts with a reduced PATH. Prepend the common package-manager paths
    -- we rely on, but keep anything the launch environment already provided.
    config.set_environment_variables = {
        PATH = prepend_unique_path_entries(os.getenv('PATH'), {'/opt/homebrew/bin', '/usr/local/bin', '/usr/bin',
                                                               '/bin', '/usr/sbin', '/sbin'})
    }

    local pwsh = first_existing({'/opt/homebrew/bin/pwsh', '/usr/local/bin/pwsh',
                                 '/Applications/PowerShell.app/Contents/MacOS/pwsh'})

    config.default_prog = {pwsh or 'pwsh', '-NoLogo'}
end

return M
