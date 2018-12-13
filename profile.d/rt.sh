# shell settings for rt (request tracker)

_RT_WORKDIR="$HOME/Documents/Tickets"
_RT_PANDOC_CSS="${_RT_WORKDIR}/pandoc.css"

if [[ $(uname -s) == Darwin ]]; then
    _RT_SED="sed -E"
else
    _RT_SED="sed -r"
fi


function _rt_get_markdown() {
    md_file=$1

    if [[ $EDITOR ]]; then
        $EDITOR $md_file
    else
        vi $md_file
    fi

    return $(test -s $md_file)
}

function _rt_md2html() {
    md_file=$1
    html_file=$2

    if [[ ! -s $md_file ]]; then
        return 1
    fi

    if [[ -f $_RT_PANDOC_CSS ]]; then
        pandoc $md_file -s -H "$_RT_PANDOC_CSS" -o $html_file
    else
        pandoc $md_file -s -o $html_file
    fi

    return $(test -s $html_file)
}

function get-ticket-id {
    if [[ $1 -gt 0 ]]; then
        echo $1
    elif [[ $(ticket-from-dir "$PWD") ]]; then
        echo $(ticket-from-dir "$PWD")
    else
        read -p "Ticket ID: " id
        echo $id
    fi
}

function ticket-from-dir {
    dir=$1
    if [[ $dir =~ ^$_RT_WORKDIR ]]; then
        id="${dir##$_RT_WORKDIR/}"
        id=${id%%/*}
        echo $id
    fi
}

function rt-archive {
    id=$(get-ticket-id $1)

    if [[ -d $_RT_WORKDIR/$id ]]; then
        [[ $PWD =~ $_RT_WORKDIR/$id ]] && cd ~
        [[ -e $_RT_WORKDIR/archive ]] || mkdir -p "$_RT_WORKDIR/archive"
        [[ -d $_RT_WORKDIR/archive ]] && mv "$_RT_WORKDIR/$id" "$_RT_WORKDIR/archive/$id"
    fi
    echo -en "\\033k$(basename $SHELL)\\033\\\\"
}

function rt-cleanup-workdir {
    cd $_RT_WORKDIR

    for id in *; do
        [[ $id =~ ^[0-9]+$ ]] || continue

        local status=$(rt-status $id)
        if [[ $status != new && $status != open && $status != responded ]]; then
            echo "Archiving $status ticket $id"
            rt-archive $id
        fi
    done

    cd - &>/dev/null
}

function rt-workdir {
    id=$(get-ticket-id $1)

    if [[ -d "$_RT_WORKDIR/$id" ]]; then
        # do nothing; dir already exists
        :
    elif [[ -d $_RT_WORKDIR/archive/$id ]]; then
        # unarchive dir
        mv "$_RT_WORKDIR/archive/$id" "$_RT_WORKDIR/$id"
    else
        # no active or archive dir; create
        mkdir -p "$_RT_WORKDIR/$id"
    fi

    cd "$_RT_WORKDIR/$id"
    echo -en "\\033krt#$id\\033\\\\"
}

function rt-attachments {
    id=$(get-ticket-id $1)

    while read line; do
        attachment_id=${line%%:*}
        attachment_name=$(echo $line | $_RT_SED 's/^[0-9]+: (.+) \([^\)]+\),?$/\1/')
        echo $attachment_name
        rt show ticket/$id/attachments/$attachment_id/content > "$attachment_name"
    done < <(rt show ticket/$id/attachments | grep -Ev "(untitled|\(Unnamed\))")
}

function rt-comment {
    id=$(get-ticket-id $1)
    rt-workdir $id

    md_file="comment-$(date +%Y%m%dT%H%M%S).md"
    html_file="comment-$(date +%Y%m%dT%H%M%S).html"

    _rt_get_markdown $md_file
    _rt_md2html $md_file $html_file
    if [[ $? -ne 0 ]]; then
        echo "Error getting HTML file!  Reverting to default RT comment."
        rt comment $id
    else
        rt comment $id -ct text/html -m - < $html_file
    fi
}

function rt-delete {
    id=$(get-ticket-id $1)

    rt edit ticket/$id set Status=deleted
    rt-archive $id
}

function rt-done {
    id=$(get-ticket-id $1)

    rt edit ticket/$id set Status=done
    rt-archive $id
}

function rt-edit {
    id=$(get-ticket-id $1)

    rt edit ticket/$id
}

function rt-give {
    id=$(get-ticket-id $1)
    if [[ $1 -gt 0 ]]; then
        user=$2
    else
        user=$1
    fi

    rt edit ticket/$id set Owner=$user
    rt-archive $id
}

function rt-latest {
    id=$(get-ticket-id $1)

    rt show ticket/$id/attachments/$(rt show ticket/$id/attachments | grep "text/plain" | tail -1 | cut -d: -f1)
}

function rt-list {
    if [[ ! $1 ]]; then
        rt ls "(owner=__CurrentUser__ and (status=new or status=open))"
    elif [[ $1 == done ]]; then
        rt ls '(owner=__CurrentUser__ and status=done)'
    elif [[ $1 == resolved ]]; then
        rt ls '(owner=__CurrentUser__ and status=resolved)'
    elif [[ $1 == responded ]]; then
        rt ls '(owner=__CurrentUser__ and status=responded)'
    elif [[ $1 == stalled ]]; then
        rt ls '(owner=__CurrentUser__ and status=stalled)'
    else
        rt ls "(owner=$1 and (status=new or status=open))"
    fi
}

function rt-queue {
    id=$(get-ticket-id $1)
    if [[ $1 -gt 0 ]]; then
        queue=$2
    else
        queue=$1
    fi

    if [[ ! $queue ]]; then
        echo "Unable to determine queue."
        return
    fi

    rt edit ticket/$id set Queue=$queue Owner=nobody
    rt-archive $id
}

function rt-reply {
    id=$(get-ticket-id $1)
    rt-workdir $id

    md_file="reply-$(date +%Y%m%dT%H%M%S).md"
    html_file="reply-$(date +%Y%m%dT%H%M%S).html"

    _rt_get_markdown $md_file
    _rt_md2html $md_file $html_file
    if [[ $? -ne 0 ]]; then
        echo "Error getting HTML file!  Reverting to default RT reply."
        rt correspond $id
    else
        rt correspond $id -ct text/html -m - < $html_file
    fi
}

function rt-resolve {
    id=$(get-ticket-id $1)

    rt edit ticket/$id set Status=resolved
    rt-archive $id
}

function rt-responded {
    id=$(get-ticket-id $1)

    rt edit ticket/$id set Status=responded
}

function rt-search {
    rt ls "$@"
}

function rt-show {
    id=$(get-ticket-id $1)

    rt show $id | grep -Ev '(===> Outgoing email recorded|[0-9]+: untitled )'
}

function rt-stall {
    id=$(get-ticket-id $1)

    rt edit ticket/$id set Status=stalled
}

function rt-status {
    id=$(get-ticket-id $1)

    rt show ticket/$id -f status | awk '/^Status:/ {print $2}'
}

function rt-take {
    id=$(get-ticket-id $1)

    rt take $id
    rt-workdir $id
}

function rt-work {
    id=$(get-ticket-id $1)

    rt-workdir $id
}
