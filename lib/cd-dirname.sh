# Pass a filepath, cd to the containing dircetory
# Useful with fzf, for example:
#
#   cdd ^T

function cdd-run {
	cd $(dirname $1)
}

alias cdd='cdd-run'

