# comment-headers.nvim

Automatic file header management for Neovim. Inserts and maintains metadata headers in your source files.

## Features

- **Auto-insert headers** on new files
- **Auto-update** dates and file paths on save
- **Customizable** fields, labels, and date formats
- **Safe removal** with validation
- **Manual API** for batch operations
- **User commands** for quick access
- **Multi-language** support (20+ languages)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "cmRingmaker/comment-headers.nvim",
  lazy = false,  -- Load immediately for auto-insert
  opts = {
    author = "Your Name",
    license = "MIT",
    -- All configuration goes inside this 'opts' table
    -- See configuration section for more options
  },
}
```

---

## Configuration

### Default Configuration

```lua
require("comment-headers").setup({
  author = "Author",
  license = "MIT",
  date_format = "%y/%m/%d",  -- Style you want your date to appear as
  scan_lines = 15,           -- How many lines to scan for headers
  auto_insert = true,        -- Auto-insert on new files

  -- Toggle individual header fields
  fields = {
    file = true,
    date = true,
    updated = true,
    version = true,
    author = true,
    license = true,
  },

  -- Extra info about fields:
  -- File:      Auto updates if file moves directories or changes name
  -- Date:      Set once on first save, replacing the placeholder
  -- Updated:   Updates every save, assuming changes are made
  -- Version:   Never auto-updates, manual
  -- Author:    Never auto-updates, manual
  -- License:   Never auto-updates, manual

  -- Customize section labels
  purpose_label = "Purpose:",
  note_label = "Note:",

  -- Strip these paths for cleaner headers
  -- Leave empty if not needed - home directory (~/) is always stripped
  -- Example: /mnt/Projects/myapp/code.lua -> myapp/code.lua
  mount_paths = {
    -- { path = "/mnt/Projects", prefix = "" },
  },

  -- Map comment styles to filetypes
  -- If your language has a single line comment format found below, they can be added easily
  comment_styles = {
    ["//"] = { "javascript", "typescript", "c", "cpp", "rust", "go", "java" },
    ["--"] = { "lua", "sql", "haskell" },
    ["#"] = { "python", "sh", "bash", "yaml", "toml", "ruby", "perl" },
  },

  -- Skip auto-insert in these directories
  -- Can add whichever directories you NEVER want a header to possibly be added to
  skip_directories = {
    "node_modules",
    "vendor",
    ".git",
    "build",
  },
})
```

### Date Format

<details>
<summary>Click to expand</summary>

The `date_format` option uses standard [strftime](https://www.lua.org/pil/22.1.html) format codes.

**Common formats:**

```lua
date_format = "%Y-%m-%d"     -- 2025-12-02
date_format = "%y/%m/%d"     -- 25/12/02
date_format = "%m/%d/%Y"     -- 12/02/2025
date_format = "%B %d, %Y"    -- December 02, 2025
```

**Format codes:**

- `%Y` = 4-digit year (2025)
- `%y` = 2-digit year (25)
- `%m` = month (01-12)
- `%d` = day (01-31)
- `%B` = full month name (December)
- `%b` = short month name (Dec)

See [Lua os.date documentation](https://www.lua.org/pil/22.1.html) for all codes.

</details>

### Mount Paths Configuration

<details>
<summary>Click to expand</summary>

The `mount_paths` option is **optional** and only needed if you have files on separate drives/mounts that you want stripped from headers.

**Default behavior (empty mount_paths):**

```lua
mount_paths = {},  -- Home directory (~/) is always stripped automatically
```

**Example:** `/home/user/project/file.lua` → `~/project/file.lua`

**With mount paths configured:**

```lua
mount_paths = {
  { path = "/mnt/Projects", prefix = "" },
  { path = "/mnt/Media", prefix = "Media/" },
}
```

**Examples:**

- `/mnt/Projects/myapp/code.lua` → `myapp/code.lua`
- `/mnt/Media/videos/script.sh` → `Media/videos/script.sh`
- `/home/user/file.lua` → `~/file.lua` (home still works)
- `/tmp/test.lua` → `/tmp/test.lua` (full path if no match)

**When to use:**

- You have projects on mounted drives (Linux)
- You want shorter paths in headers

**Leave empty if:**

- You only work in your home directory
- You don't have mounted drives
- You want full paths in headers

</details>

## Example Customization for Config

```lua
require("comment-headers").setup({
  author = "John Doe",
  license = "Apache License 2.0",
  date_format = "%d.%m.%Y",  -- 02.12.2025


  -- Disable certain fields
  fields = {
    version = false,
    license = false,
  },

  -- Add your language
  comment_styles = {
    ["//"] = { "javascript", "typescript", "mycoollang" },
  },
})
```

---

## Usage

### Automatic Behavior

Headers are automatically:

- **Inserted** when creating new files
- **Updated** when saving (file path, update)

### Manual Behavior

Unlike auto-insert (which only works on new files), manual commands work on **any** file

- Files that already have content
- Existing files without headers
- Files with old headers you want to refresh

```vim
:CommentHeaderInsert   " Insert header in current file
:CommentHeaderUpdate   " Update header fields
:CommentHeaderRemove   " Remove header from file
```

### Lua API

```lua
-- Insert header (pushes content down if file has content)
require('comment-headers').insert_header()

-- Update header fields (file path, dates)
require('comment-headers').update_headers()

-- Remove header from buffer
require('comment-headers').remove_header()
```

### Keybindings (Optional)

```lua
vim.keymap.set('n', '<leader>hi', function()
  require('comment-headers').insert_header()
end, { desc = 'Insert header' })

vim.keymap.set('n', '<leader>hu', function()
  require('comment-headers').update_headers()
end, { desc = 'Update headers' })

vim.keymap.set('n', '<leader>hr', function()
  require('comment-headers').remove_header()
end, { desc = 'Remove header' })
```

## Example Output

```lua
-- ======================================================================
-- $File      : ~/.config/nvim/init.lua
-- $Date      : 25/12/02
-- $Updated   : 25/12/02
-- $Version   : 1.0.0
-- $Author    : John Doe
-- $License   : MIT
-- ======================================================================
-- Purpose:
--   Main Neovim configuration entry point
-- ======================================================================
-- Note:
--   Configuration is split across multiple files
-- ======================================================================
```

---

## Supported Languages

**Built-in support:**

- C/C++/C#, Rust, Go, Java, Swift, Zig
- JavaScript, TypeScript
- Python, Ruby, Perl
- Lua, SQL, Haskell
- Bash/Zsh/Fish
- YAML, TOML

**Easy to add more!** Just add to `comment_styles` in config.

---

## FAQ

### Why comment-headers.nvim?

- **Consistent headers** across your codebase
- **Automatic maintenance** - dates always up to date
- **File organization** - know what each file does at a glance
- **Version tracking** - see when files were created/modified

### What fields are auto-updated?

Only these fields update automatically on save:

- `$File` - if file path changes
- `$Date` - if still placeholder `--/--/--`
- `$Updated` - every save with new date (if file was modified)

`$Author`, `$Version`, and `$License` are set once on creation.

---

## Batch-insert headers

It is possible to batch insert, update, and remove, for your current project from within NeoVim.

```vim
:CommentHeaderInsert   " Insert header in current file
:CommentHeaderUpdate   " Update header fields
:CommentHeaderRemove   " Remove header from file
```

First, be in your correct directory

`:cd ~/projects/myapp`

Note: After running `:args *.lua`, you can type `:args` and it will display the current files that are staged for changes.

You can use any filetype, but we'll use lua. Example for all .lua files in **current directory**:

```vim
:args *.lua
:argdo :CommentHeaderInsert
```

Example for all .lua files in **current directory** and **all subdirectories**:

```vim
:args **/*.lua
:argdo :CommentHeaderInsert
```

Example for all .lua files in a **specific directory**.
Let's use the directory "src":

```vim
:args src/*.lua
:argdo :CommentHeaderInsert
```

Example for **Multiple file types**, in all directories and subdirectories:

```vim
:args **/*.{lua,py,js}
:argdo :CommentHeaderInsert
```

_Tip: Save all files at once with `:argdo w` or save individually as needed._
