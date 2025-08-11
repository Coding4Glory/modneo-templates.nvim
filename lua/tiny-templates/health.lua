local settings = require('tiny-templates.config').settings
local function count_files(path)
    local file_counter = 0
    for _, type in vim.fs.dir(path, {}) do
        file_counter = file_counter + (type == 'file' and 1 or 0)
    end
    return file_counter
end

return {
    check = function()
        for _, path in ipairs(settings.include) do
            if vim.fn.isdirectory(path) == 1 then
                local files = count_files(path)
                vim.health.ok(path .. ' exists (' .. files .. ' files')
            else
                vim.health.warn(path .. ' does not exist')
            end
        end
    end
}
