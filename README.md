# SStash.nvim

S(ession)Stash.nvim

> Cmon I just want to get back to my opened files for this directory

A wrapper around `mksession`

Get back to your previous session only when you need it


<!--toc:start-->
- [SStash.nvim](#sstashnvim)
  - [How it works](#how-it-works)
  - [Config](#config)
  - [Recipes](#recipes)
    - [Disable saving session on some filetypes](#disable-saving-session-on-some-filetypes)
    - [Session scoped to git branch](#session-scoped-to-git-branch)
    - [Git cwd with fallback to current](#git-cwd-with-fallback-to-current)
<!--toc:end-->

## How it works

When you leave neovim or call `SStash write`, a new session gets created with the cwd and name as the "id"

Next time you open neovim and run `SStash [source]` the plugin will traverse your cwd parents
until it finds a session (or doesn't) and then it sources that session, effectively making it just as
you left it

Session information is stored in `$data/sstash.nvim`:

![image](https://github.com/user-attachments/assets/a1b369f8-7a9f-4382-bde0-d7eec3ce80d1)


<details>
    <summary>demo</summary>

https://github.com/user-attachments/assets/7bd472a2-29f8-49f0-8cef-93362026180a

</details>

## Config

```lua
{
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

    ---function that actually writes the session
    write = function(filename)
        vim.cmd({ bang = true, cmd = "mksession", args = { filename } })
    end,

    ---function that sources the session
    source = function(filename)
        vim.cmd({ cmd = "source", args = { filename } })
    end,
}

```

## Recipes

### Disable saving session on some filetypes

```lua
write_on_leave = function()
    local disabled_ft = { gitcommit = true, oil = true }
    return not disabled_ft[vim.bo.filetype]
end,
```

### Session scoped to git branch

```lua
get_session_name = function()
    local git_branch = vim.system({ "git", "branch", "--show-current" }):wait()

    if git_branch.code == 0 then
        return "gb" .. vim.base64.encode(vim.trim(git_branch.stdout)) .. ".vim"
    end

    return "session.vim"
end,
```

### Git cwd with fallback to current

```lua
get_cwd = function()
    return vim.fs.root(0, ".git") or vim.fn.getcwd()
end,
```
