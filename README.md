# SStash.nvim

S(ession)Stash.nvim

A wrapper around `mksession`

Get back to your previous session only when you need it

## How it works

When you leave neovim or call `SStash write`, a new session gets created with the cwd as the "id"

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
    ---add the git branch to the name to scope the sessions
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

```
