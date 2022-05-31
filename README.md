# Calm

Fish prompt based on Hydro, with added support for Fedora [Toolbox].

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```console
fisher install vermarine/calm
```

## Features

One prompt symbol to rule them all. [Change it](#configuration).

<pre>
<b>~</b> % ⎢
</pre>

Show Git branch name and status—prompt repaints asynchronously! ✨

<pre>
<b>calm</b> main % touch Solution
<b>calm</b> main<b style="color:red">*</b> % ⎢
</pre>

> `*` indicates that there are staged, unstaged or untracked files.

Show how many commits you're ahead and/or behind of your upstream—prompt repaints asynchronously! ✨

<pre>
<b>calm</b> main* -2 % git commit -am Hotfix
<b>calm</b> main +1 -2 % git pull --rebase && git push
<b>calm</b> main % ⎢
</pre>

Show `$CMD_DURATION` if > `1` second.

<pre>
<b>calm</b> main % git push --quiet
<b>calm</b> main 1.1s % ⎢
</pre>

Show the last `$pipestatus`.

<pre>
<b>calm</b> main % false
<b>calm</b> main % [<b>1</b>]
<b>calm</b> main % true | false | false
<b>calm</b> main [<b>0</b>ǀ<b>1</b>ǀ<b>1</b>] ⎢
</pre>

Show current bindings mode.

<pre>
<i>I</i> <b>~</b> % <kbd>Esc</kbd>
<i>N</i> <b>~</b> % <kbd>R</kbd>
<i>R</i> <b>~</b> % ⎢
</pre>

Show the current [Toolbox] name when operating inside of a [toolbox].

<pre>
<b style="color:#800080">⬢ devel</b> ~/p/<b>calm</b> % ⎢
</pre>

We even set the terminal title to `$PWD` and the currently running command for you.

```
fish ~/projects/calm
```

## Performance

Blazing fast would be an understatement considering that the [LLVM repo](https://github.com/llvm/llvm-project) has over 375,000 commits!

<pre>
<b>llvm-project</b> main % time fish_prompt
<b>llvm-project</b> main %
________________________________________________________
Executed in   79.00 micros    fish           external
   usr time   71.00 micros   71.00 micros    0.00 micros
   sys time    9.00 micros    9.00 micros    0.00 micros
</pre>

## Configuration

Modify variables using `set --universal` from the command line or `set --global` in your `config.fish` file.

### Symbols

| Variable                  | Type   | Description                     | Default |
| ------------------------- | ------ | ------------------------------- | ------- |
| `calm_symbol_prompt`      | string | Prompt symbol.                  | %       |
| `calm_symbol_git_dirty`   | string | Dirty repository symbol.        | *       |
| `calm_symbol_git_ahead`   | string | Ahead of your upstream symbol.  | +       |
| `calm_symbol_git_behind`  | string | Behind of your upstream symbol. | -       |
| `calm_symbol_toolbox`     | string | Inside of a toolbox.            | ⬢       |

### Colors

> Any argument accepted by [`set_color`](https://fishshell.com/docs/current/cmds/set_color.html).

| Variable               | Type  | Description                    | Default              |
| ---------------------- | ----- | ------------------------------ | -------------------- |
| `calm_color_toolbox`   | color | Color of the toolbox segment.  | `800080`             |
| `calm_color_pwd`       | color | Color of the pwd segment.      | `$fish_color_normal` |
| `calm_color_git`       | color | Color of the git segment.      | `$fish_color_normal` |
| `calm_color_error`     | color | Color of the error segment.    | `$fish_color_error`  |
| `calm_color_prompt`    | color | Color of the prompt symbol.    | `$fish_color_normal` |
| `calm_color_duration`  | color | Color of the duration section. | `$fish_color_normal` |

### Flags

| Variable                       | Type    | Description                                  | Default |
| ------------------------------ | ------- | -------------------------------------------- | ------- |
| `calm_fetch`                   | boolean | Fetch git remote in the background.          | `false` |
| `calm_multiline`               | boolean | Display prompt character on a separate line. | `false` |
| `calm_toolbox_show_anonymous`  | boolean | Do not hide the name of anonymous toolboxes  | `false` |

### Misc

| Variable                     | Type    | Description                                                         | Default |
| ---------------------------- | ------- | ------------------------------------------------------------------- | ------- |
| `fish_prompt_pwd_dir_length` | numeric | The number of characters to display when path shortening            | 1       |
| `calm_ignored_git_paths`     | strings | Space separated list of paths where no git info should be displayed | `""`    |



[toolbox]: https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/