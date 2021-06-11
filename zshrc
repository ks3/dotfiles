# automatically remove duplicates from path
typeset -U path
typeset -U PATH

function aws_info() {
    typeset -g aws_info_msg=""
    if [[ -n $AWS_PROFILE ]]; then
        aws_info_msg=" aws:${AWS_PROFILE}"
    fi
    return 0
}

autoload -Uz add-zsh-hook vcs_info
add-zsh-hook precmd aws_info
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ':*'
zstyle ':vcs_info:*' stagedstr ':+'
zstyle ':vcs_info:*' formats ' %s:%b%u%c'
zstyle ':vcs_info:*' actionformats ' %s:%b:%a%u%c'
setopt prompt_subst
export PS1='%F{blue}%n@${(L)HOST%%.*}:%~%F{208}${aws_info_msg}%F{230}${vcs_info_msg_0_}%f %# '

[[ -d ~/Scripts ]] && path+=(~/Scripts)
[[ -d ~/.local/bin ]] && path+=(~/.local/bin)

alias ls="ls -F"
