# ~/.profile.d/git.sh

if [ -e "/opt/homebrew/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_PREFIX="${COLOR_MAGENTA}"
    GIT_PROMPT_SEPARATOR="${COLOR_MAGENTA}:"
    GIT_PROMPT_SUFFIX="${COLOR_MAGENTA}${COLOR_RESET}"
    GIT_PROMPT_BRANCH="${COLOR_MAGENTA}"
    GIT_PROMPT_STAGED="${COLOR_MAGENTA}●"
    GIT_PROMPT_CONFLICTS="${COLOR_MAGENTA}✖"
    GIT_PROMPT_CHANGED="${COLOR_MAGENTA}✚"
    GIT_PROMPT_UNTRACKED="${COLOR_MAGENTA}…"
    GIT_PROMPT_STASHED="${COLOR_MAGENTA}⚑"
    GIT_PROMPT_VIRTUALENV=""
    GIT_PROMPT_CLEAN="${COLOR_MAGENTA}✔"
    source "/opt/homebrew/opt/bash-git-prompt/share/gitprompt.sh"
fi
