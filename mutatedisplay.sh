#!/bin/bash

Help()
{
    echo "Controls display settings conveniently."
    echo
    echo "Syntax: mutatedisplay [-t|-d]"
    echo "options:"
    echo "-t        Apply tuning to display configuration."
    echo "-d        Apply the default display configuration."
    echo
}

GetDefaultConfig()
{
    # backup pre-existing config, to restore later by calling Cleanup
    cp ~/.nvidia-settings-rc ~/.nvidia-settings-rc.bak 
    
    # rewrite ~/.nvidia-settings-rc with default config
    # by running nvidia settings without loading any config (-n)
    # then writing the unconfigured state to file (-r)
    nvidia-settings -n -r
}

Cleanup()
{
    # restore pre-existing run control config file
    mv ~/.nvidia-settings-rc.bak ~/.nvidia-settings-rc
}

Tune()
{
    GetDefaultConfig
    
    # make a new, local config with minimal changes from the default
    
    # reduce contrast slightly, for red, green, and blue
    # then reduce gamma slightly, for red, green, and blue
    sed 's/Contrast=-*0\.[0-9]*/Contrast=-0\.156812/g' ~/.nvidia-settings-rc | \
    sed 's/Gamma=-*1\.[0-9]*/Gamma=0\.765601/g' > ./.nvidia-settings-rc-tuned
    
    # use, then delete the modified config
    nvidia-settings -config='./.nvidia-settings-rc-tuned' --load-config-only
    rm ./.nvidia-settings-rc-tuned

    Cleanup
}

RestoreDefault()
{
    GetDefaultConfig
    
    # loads the default config
    nvidia-settings --load-config-only

    Cleanup
}

# no arguments provided
if [ $# -eq 0 ]; then
    Help
    exit 1
fi

# some arguments provided
if [ $1 == "-t" ]; then
    Tune
    exit 0
elif [ $1 == "-d" ]; then
    RestoreDefault
    exit 0
else
    Help
    exit 1
fi
