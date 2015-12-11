#!/usr/bin/env bash
TARGET_DIR=$1
GHQ_ROOT=$(ghq root)

if [ -z $TARGET_DIR ]; then
    echo "empty!"
    exit 1
fi

# get remote-url
echo $TARGET_DIR

N_OF_REMOTES=$(cd $TARGET_DIR;git config --get-regexp remote.*.url | wc -l)

function _remote_path_from_url {
    # git remote url may be
    # ssh://git@hoge.host:22/var/git/projects/Project
    # git@github.com:motemen/ghq.git
    # (normally considering only github is enough?)
    # remove ^ssh://
    # => remove ^hoge@ (usually git@ ?)
    #  => replace : => /
    #   => remove .git$
    REMOTE_PATH=$(echo $1 | sed -e 's!^ssh://!!; s!^.*@!!; s!:!/!; s!\.git$!!;')
    echo $REMOTE_PATH
}

if [ $N_OF_REMOTES -eq 1 ]; then
    echo "one remote!"
    REMOTE_PATH=$(_remote_path_from_url $(cd $TARGET_DIR;git config --get-regexp remote.*.url | cut -d ' ' -f 2))
    echo "move this repository to ${GHQ_ROOT}/${REMOTE_PATH}"
    if [ ${GHQ_MIGRATOR_ACTUALLY_RUN:-0} -eq 1 ]; then
        PARENT_DIR="${GHQ_ROOT}/${REMOTE_PATH}/../"
        mkdir -p $PARENT_DIR
        mv $TARGET_DIR $PARENT_DIR
    fi
else
    echo "multiple remote detected!!!"
    echo '';echo ''
    (cd $TARGET_DIR;git config --get-regexp remote.*.url)
    echo ''

    N_OF_ORIGIN_REMOTES=$(cd $TARGET_DIR;git config --get-regexp remote.origin.url | wc -l)
    if [ $N_OF_ORIGIN_REMOTES -eq 1 ] && [ ${GHQ_MIGRATOR_PREFER_ORIGIN:-0} -eq 1 ]; then
        REMOTE_PATH=$(_remote_path_from_url $(cd $TARGET_DIR;git config --get-regexp remote.origin.url | cut -d ' ' -f 2))
        echo "Use origin"
        echo "move this repository to ${GHQ_ROOT}/${REMOTE_PATH}"
        if [ ${GHQ_MIGRATOR_ACTUALLY_RUN:-0} -eq 1 ]; then
            PARENT_DIR="${GHQ_ROOT}/${REMOTE_PATH}/../"
            mkdir -p $PARENT_DIR
            mv $TARGET_DIR $PARENT_DIR
        fi
    else
        echo "We cannot decide which remote to use..."
        exit 1
    fi
fi
