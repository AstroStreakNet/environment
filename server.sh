#!/usr/bin/env bin

#-- Define repositories ------------------------------------------------------#

repositories=(
    "telescope git@github.com:AstroStreakNet/telescope.git"
    "streak git@github.com:AstroStreakNet/streak.git"
    "backend git@github.com:AstroStreakNet/web-back.git"
    "frontend git@github.com:AstroStreakNet/astro-streak-net-react.git"
    "database git@github.com:AstroStreakNet/database.git"
)


#-- Functions ----------------------------------------------------------------#

# clone repositories
clone_repositories() {
    for repo in "${repositories[@]}"; do
        local name
        local url
        local path

        # Split repository info into name, url, and optional path
        IFS=' ' read -r name url path <<< "$repo"

        # If path is not provided, use the repository name
        if [ -z "$path" ]; then
            path="$name"
        fi

        git clone "$url" "$path"
    done
}

# update repositories
update_repositories() {
    if [ -n "$1" ]; then
        # If repository name is provided, update only that repository
        cd "$1" || exit
        git pull
    else
        # Otherwise, update all repositories
        for repo in */.git; do
            repo="${repo%/.git}"
            (cd "$repo" || exit; git pull)
        done
    fi
}

# switch to a branch in a repository
switch_branch() {
    cd "$1" || exit
    git checkout "$2"
}


#-- Main ---------------------------------------------------------------------#

main() {
    case "$1" in
        init)
            clone_repositories
            ;;
        update)
            update_repositories "$2"
            ;;
        switch)
            switch_branch "$2" "$3"
            ;;
        *)
            echo "Usage: $0 {init|update [repository]|switch repository branch}"
            exit 1
            ;;
    esac
}

# Execute main function with provided arguments
main "$@"

