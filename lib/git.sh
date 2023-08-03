function git_branch_ps1 {
        BR=$(git branch 2> /dev/null | grep '^*' | cut -d' ' -f2-)
        BR=${BR:-''}
        echo $BR
}

alias g=git-wrapper.sh
