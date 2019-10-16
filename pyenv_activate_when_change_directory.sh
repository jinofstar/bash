# copy your .bash_profile 
export PYENV_PATH=$HOME/.pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# https://scotch.io/@iamjohnnym/managing-python-with-pyenv-and-direnv
# https://gitlab.com/JeffreyVdb/oh-my-zsh/blob/b0ad3d7c70d023c282cd2abb4c578695c52a3ed4/plugins/virtualenvwrapper/virtualenvwrapper.plugin.zsh
function workon_cwd {
    # check if python version is set in current dir
    if [ -f ".python-version" ] ; then
        if [ ! -d ".venv" ] ; then
            echo "Installing virtualenv for $(python -V)"
            # if we didn't install `py2venv` for python 2.x, we would need to use
            # `virtualenv`, which you would have to install separately.
            python -m venv .env
        fi
    fi

    # Check that this is a Git repo
    PROJECT_ROOT=`git rev-parse --show-toplevel 2> /dev/null`
    if [ $? != 0 ]; then
        PROJECT_ROOT="`pwd`"
    fi

    # Check for virtualenv name override
    if [ -f "$PROJECT_ROOT/.venv" ]; then
        ENV_NAME=`cat "$PROJECT_ROOT/.venv"`
    elif [ -f "$PROJECT_ROOT/.venv/bin/activate" ]; then
        ENV_NAME="$PROJECT_ROOT/.venv"
    else
        ENV_NAME=""
    fi

    if [ ! -z $ENV_NAME ]; then
        if [[ ! $VIRTUAL_ENV =~ $ENV_NAME ]]; then
            if [[ -e "$ENV_NAME/bin/activate" ]]; then
                source $ENV_NAME/bin/activate && export CD_VIRTUAL_ENV="$ENV_NAME"
            else
                source activate $ENV_NAME && export CD_VIRTUAL_ENV="$ENV_NAME"
            fi
        fi
    elif [ $CD_VIRTUAL_ENV ]; then
        # We've just left the repo, deactivate the environment
        # Note: this only happens if the virtualenv was activated automatically
        source deactivate && unset CD_VIRTUAL_ENV
    fi
}

# New cd function that does the virtualenv magic
function venv_cd {
    cd "$@" && workon_cwd
}

alias cd="venv_cd"
