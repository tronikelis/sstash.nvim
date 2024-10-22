local M = {}

local DATA_DIR = vim.fs.joinpath(vim.fn.stdpath("data"), "/sstash.nvim/")

M.config = {
    ---should return the cwd of nvim
    ---@return string
    get_cwd = function()
        return vim.fn.getcwd()
    end,

    ---the session file name that will get written
    ---default is session.vim, but you can for example
    ---add the git HEAD sha to the name to scope the sessions
    ---this is essentially the final filename, thus it can't have special chars like "/"
    get_session_name = function()
        return "session.vim"
    end,

    ---should write be called when leaving,
    ---setting this to false will not add autocmd
    ---you might want to return false if current filetype is gitcommit / directory etc...
    write_on_leave = function()
        return true
    end,
}

---@return string?
local function find_session_path()
    local current = M.config.get_cwd()
    local session_name = M.config.get_session_name()

    while #current > 1 do
        local maybe = vim.fs.joinpath(DATA_DIR, current, session_name)

        if vim.uv.fs_statfs(maybe) then
            return maybe
        end

        current = vim.fs.dirname(current)
    end
end

M.commands = {
    source = function()
        local path = find_session_path()
        if not path then
            return
        end

        vim.cmd({ cmd = "source", args = { path } })
    end,

    write = function()
        local data_dir = vim.fs.joinpath(DATA_DIR, M.config.get_cwd())
        local session = vim.fs.joinpath(data_dir, M.config.get_session_name())

        local mkdir = vim.system({ "mkdir", "-p", data_dir }):wait()
        if mkdir.code ~= 0 then
            print("mkdir failed", mkdir.stderr)
            return
        end

        vim.cmd({ bang = true, cmd = "mksession", args = { session } })
    end,
}

function M.setup(config)
    M.config = vim.tbl_deep_extend("force", M.config, config or {})

    vim.api.nvim_create_user_command("SStash", function(arg)
        local fargs = arg.fargs

        local cmd = M.commands[fargs[1] or "source"]

        if cmd then
            cmd()
            return
        end

        print("unknown command")
    end, {
        nargs = "?",
        complete = function()
            local candidates = vim.tbl_keys(M.commands)
            return candidates
        end,
    })

    if M.config.write_on_leave then
        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                if M.config.write_on_leave() then
                    M.commands.write()
                end
            end,
        })
    end
end

return M
