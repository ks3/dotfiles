# ~/.profile.d/homebrew.sh

if [[ -d /opt/homebrew ]]; then
    alias brewLocal="HOMEBREW_NO_INSTALL_FROM_API=1 brew"
fi

if [[ -e /opt/homebrew/opt/bash/bin ]]; then
    export PATH="/opt/homebrew/opt/bash/bin:${PATH}"
fi
if [[ -e /opt/homebrew/opt/ruby/bin ]]; then
    export PATH="/opt/homebrew/opt/ruby/bin:${PATH}"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    export PATH="${PATH}:/opt/homebrew/bin:/opt/homebrew/sbin"
    export MANPATH="${MANPATH}:/opt/homebrew/share/man"
    #export INFOPATH="${INFOPATH}${INFOPATH:+:}/opt/homebrew/share/info";
fi

if [[ $BASH == /opt/homebrew/bin/bash ]]; then
    if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
        source /opt/homebrew/etc/profile.d/bash_completion.sh
    fi
fi
