status is-interactive || exit

set --global _calm_git _calm_git_$fish_pid

function $_calm_git --on-variable $_calm_git
    commandline --function repaint
end

function _calm_toolbox_name --on-variable TOOLBOX_PATH
    if test -e /run/.toolboxenv -a -f /run/.containerenv -a -r /run/.containerenv
        set --global _calm_toolbox_name (
            cat /run/.containerenv |
            string match --regex --groups-only -- 'name="([^"]+)"'
        )
    else
        set --global _calm_toolbox_name
    end
end

function _calm_toolbox --on-variable TOOLBOX_PATH --on-variable calm_toolbox_show_anonymous
    if set --query TOOLBOX_PATH
        # if in a toolbox, get the toolbox name
        set --query _calm_toolbox_name || _calm_toolbox_name
        if string match -q --entire 'fedora-toolbox-' $_calm_toolbox_name && test "$calm_toolbox_show_anonymous" != true
            # if the toolbox name begins with fedora-toolbox-, do not print it (it's an anonymous toolbox)
            set --global _calm_toolbox "\x1b[1m$calm_symbol_toolbox\x1b[22m "
        else
            # otherwise, print it (it's a named toolbox)
            set --global _calm_toolbox "\x1b[1m$calm_symbol_toolbox $_calm_toolbox_name\x1b[22m "
        end
    else
        # if not in a toolbox, do nothing at all
        set --global _calm_toolbox
    end
end

function _calm_pwd --on-variable PWD --on-variable calm_ignored_git_paths
    if set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null) && ! contains -- $git_root $calm_ignored_git_paths
        set --erase _calm_skip_git_prompt
    else
        set --global _calm_skip_git_prompt
    end
    set --query fish_prompt_pwd_dir_length || set --local fish_prompt_pwd_dir_length 1

    if test "$calm_pwd_currentdir_only" = true
        test "$PWD" = '/' && set --global _calm_pwd "\x1b[1m/\x1b[22m" || \
        set --global _calm_pwd (
            string replace --regex -- '^(?:/(?:[^/]+/)*)([^/]+)$' "\x1b[1m\$1\x1b[22m" $PWD
        )
    else if test "$fish_prompt_pwd_dir_length" -le 0 || test "$calm_multiline" = true
        set --global _calm_pwd (
            string replace --ignore-case -- ~ \~ $PWD |
            string replace --regex -- '([^/]+)$' "\x1b[1m\$1\x1b[22m" |
            string replace --regex --all -- '(?!^/$)/' "\x1b[2m/\x1b[22m"
        )
    else
        set --local root (command git rev-parse --show-toplevel 2>/dev/null |
            string replace --all --regex -- "^.*/" "")
        set --global _calm_pwd (
            string replace --ignore-case -- ~ \~ $PWD |
            string replace -- "/$root/" /:/ |
            string replace --regex --all -- "(\.?[^/]{"$fish_prompt_pwd_dir_length"})[^/]*/" \$1/ |
            string replace -- : "$root" |
            string replace --regex -- '([^/]+)$' "\x1b[1m\$1\x1b[22m" |
            string replace --regex --all -- '(?!^/$)/' "\x1b[2m/\x1b[22m"
        )
    end
end

function _calm_postexec --on-event fish_postexec
    test "$CMD_DURATION" -lt 1000 && set _calm_cmd_duration && return

    set --local secs (math --scale=1 $CMD_DURATION/1000 % 60)
    set --local mins (math --scale=0 $CMD_DURATION/60000 % 60)
    set --local hours (math --scale=0 $CMD_DURATION/3600000)

    set --local out

    test $hours -gt 0 && set --local --append out $hours"h"
    test $mins -gt 0 && set --local --append out $mins"m"
    test $secs -gt 0 && set --local --append out $secs"s"

    set --global _calm_cmd_duration "$out "
end

function _calm_prompt --on-event fish_prompt
    set --local last_status $pipestatus
    set --query _calm_toolbox || _calm_toolbox
    set --query _calm_pwd || _calm_pwd
    set --global _calm_prompt "$_calm_newline$_calm_color_prompt$calm_symbol_prompt"

    for code in $last_status
        if test $code -ne 0
            set _calm_prompt "$_calm_newline$_calm_color_error"[(echo $last_status)]
            break
        end
    end

    command kill $_calm_last_pid 2>/dev/null

    set --query _calm_skip_git_prompt && set $_calm_git && return

    fish --private --command "
        set branch (
            command git symbolic-ref --short HEAD 2>/dev/null ||
            command git describe --tags --exact-match HEAD 2>/dev/null ||
            command git rev-parse --short HEAD 2>/dev/null |
                string replace --regex -- '(.+)' '@\$1'
        )

        test -z \"\$$_calm_git\" && set --universal $_calm_git \"\$branch \"

        ! command git diff-index --quiet HEAD 2>/dev/null ||
            count (command git ls-files --others --exclude-standard) >/dev/null &&
            set info \"$calm_symbol_git_dirty\"

        for fetch in $calm_fetch false
            command git rev-list --count --left-right @{upstream}...@ 2>/dev/null |
                read behind ahead

            switch \"\$behind \$ahead\"
                case \" \" \"0 0\"
                case \"0 *\"
                    set upstream \" $calm_symbol_git_ahead\$ahead\"
                case \"* 0\"
                    set upstream \" $calm_symbol_git_behind\$behind\"
                case \*
                    set upstream \" $calm_symbol_git_ahead\$ahead $calm_symbol_git_behind\$behind\"
            end

            set --universal $_calm_git \"\$branch\$info\$upstream \"

            test \$fetch = true && command git fetch --no-tags 2>/dev/null
        end
    " &

    set --global _calm_last_pid (jobs --last --pid)
end

function _calm_fish_exit --on-event fish_exit
    set --erase $_calm_git
end

function _calm_uninstall --on-event calm_uninstall
    set --names |
        string replace --filter --regex -- "^(_?calm_)" "set --erase \$1" |
        source
    functions --erase (functions --all | string match --entire --regex "^_?calm_")
end

set --global calm_color_normal (set_color normal)

for color in calm_color_{toolbox,pwd,git,error,prompt,duration}
    function $color --on-variable $color --inherit-variable color
        set --query $color && set --global _$color (set_color $$color)
    end && $color
end

function calm_multiline --on-variable calm_multiline
    if test "$calm_multiline" = true
        set --global _calm_newline "\n"
    else
        set --global _calm_newline ""
    end
end && calm_multiline

set --query calm_color_error || set --global calm_color_error $fish_color_error
set --query calm_color_toolbox || set --global calm_color_toolbox 800080 # same color as used in bash
set --query calm_symbol_toolbox || set --global calm_symbol_toolbox ⬢
set --query calm_symbol_prompt || set --global calm_symbol_prompt ❱
set --query calm_symbol_git_dirty || set --global calm_symbol_git_dirty •
set --query calm_symbol_git_ahead || set --global calm_symbol_git_ahead ↑
set --query calm_symbol_git_behind || set --global calm_symbol_git_behind ↓
set --query calm_multiline || set --global calm_multiline false
set --query calm_toolbox_show_anonymous || set --global calm_toolbox_show_anonymous false
set --query calm_pwd_currentdir_only || set --global calm_pwd_currentdir_only false
