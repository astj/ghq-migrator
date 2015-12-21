# ghq-migrator

move your local repository into [ghq](https://github.com/motemen/ghq)'s root directory with suitable URI-based path.

## DEPENDENCIES

- bash
- sed (may not work with GNU's version. Only tested with the BSD version)
- git

And you need to set ghq's root directory configuration in 'git-config'.  If you already started using ghq, you need to do nothing about it.  Read ghq's README.

## SYNOPSIS

```
$ ghq-migrator.bash ./(YOUR_REPOSITORY)/
```

## CONFIGURATION

You can customize behavior of ghq-migrator by following environmental variables.

###  `GHQ_MIGRATOR_ACTUALLY_RUN`

Unless this variable set to `1`, ghq-migrator doesn't move repository's directory (dry-run).
It's recommended to run ghq-migrator without this option at first, check output, and run with `GHQ_MIGRATOR_ACTUALLY_RUN=1` to move directory actually.

### `GHQ_MIGRATOR_PREFER_ORIGIN`

By default, ghq-migrator doesn't move a repository with more than two git-remote url.
If `GHQ_MIGRATOR_PREFER_ORIGIN=1` is set, ghq-migrator moves the repository according to url of `origin` even it has another remote.

*Note* : Even if `GHQ_MIGRATOR_PREFER_ORIGIN=1` is specified, ghq-migrator cannot move repositories which its origin has more than 2 urls, because ghq-migrator cannot decide which url to use.

### AUTHOR

astj (asato.wakisaka@gmail.com)

### LICENSE

MIT
