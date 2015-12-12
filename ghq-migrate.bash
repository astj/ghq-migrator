#!/usr/bin/env bash
TARGET_DIR=$1
GHQ_ROOT=$(ghq root)

if ! [ -d $TARGET_DIR ]; then
    echo "directory needed! : ${TARGET_DIR}"
    exit 1
fi

# get remote-url
echo $TARGET_DIR

N_OF_REMOTES=$(cd $TARGET_DIR;git config --get-regexp remote.*.url | wc -l)
if [ ${N_OF_REMOTES:-0} -eq 0 ]; then
    echo 'obtain remote url failed. is this really git repository?'
    exit 1
fi

function _remote_path_from_url {
    # git remote url may be
    # ssh://git@hoge.host:22/var/git/projects/Project
    # git@github.com:motemen/ghq.git
    # (normally considering only github is enough?)
    # remove ^.*://
    # => remove ^hoge@ (usually git@ ?)
    #  => replace : => /
    #   => remove .git$
    REMOTE_PATH=$(echo $1 | sed -e 's!^.*://!!; s!^.*@!!; s!:!/!; s!\.git$!!;')
    echo $REMOTE_PATH
}

function _move_repository_directory {
    TARGET_DIR=$1
    REMOTE_PATH=$2

    echo "move this repository to ${GHQ_ROOT}/${REMOTE_PATH}"
    if [ ${GHQ_MIGRATOR_ACTUALLY_RUN:-0} -eq 1 ]; then
        NEW_REPO_DIR="${GHQ_ROOT}/${REMOTE_PATH}"
        if [ -e $NEW_REPO_DIR ]; then
            echo "${NEW_REPO_DIR} already exists!!!!"
            exit 1
        fi
        mkdir -p "${NEW_REPO_DIR%/*}"
        mv ${TARGET_DIR%/} $NEW_REPO_DIR
    else
        echo 'specify GHQ_MIGRATOR_ACTUALLY_RUN=1 to work actually'
    fi
}

if [ $N_OF_REMOTES -eq 1 ]; then
    REMOTE_PATH=$(_remote_path_from_url $(cd $TARGET_DIR;git config --get-regexp remote.*.url | cut -d ' ' -f 2))
    _move_repository_directory $TARGET_DIR $REMOTE_PATH
else
    echo "multiple remote detected!!!"
    echo '';echo ''
    (cd $TARGET_DIR;git config --get-regexp remote.*.url)
    echo ''

    N_OF_ORIGIN_REMOTES=$(cd $TARGET_DIR;git config --get-regexp remote.origin.url | wc -l)
    if [ $N_OF_ORIGIN_REMOTES -eq 1 ] && [ ${GHQ_MIGRATOR_PREFER_ORIGIN:-0} -eq 1 ]; then
        REMOTE_PATH=$(_remote_path_from_url $(cd $TARGET_DIR;git config --get-regexp remote.origin.url | cut -d ' ' -f 2))
        echo "Use origin"
        _move_repository_directory $TARGET_DIR $REMOTE_PATH
    else
        echo "We cannot decide which remote to use..."
        exit 1
    fi
fi
