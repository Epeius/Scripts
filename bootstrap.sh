#!/bin/bash
set +x

###############################################################

for cmd in s2ecmd s2eput choose_file cgccmd; do
    rm -f "$cmd"
    ./s2eget "guest-tools32/$cmd"
    chmod +x "$cmd"
done

./s2eget wrjpgcom 

./s2ecmd message "Using kernel $(uname -a)"

# Don't print crashes in the syslog.
# This prevents unnecessary forking
sudo sysctl -w debug.exception-trace=0


ulimit -c 0

# Check that /tmp is mounted in memory
if ! mount | grep 'none on /tmp type tmpfs'; then
    ./s2ecmd kill -1 '/tmp must be mounted as a RAM disk'
fi

###############################################################

prepare_file()
{
    
        chmod +x wrjpgcom 
    
}

get_binaries()
{
    find . -maxdepth 1 -perm -111 -type f
}

###############################################################

run_cb()
{
    # We need to redirect binary output to place where it will not be concretised.
    # Do not redirect to /dev/null. Write to /dev/null always succeeds regardless
    # if source buffer address (and even if it is symbolic).
    ./wrjpgcom >/tmp/out 2>&1
}

run_cb_concolic()
{
    while true; do
        seed_file=$(./s2ecmd get_seed_file 0) # add 1 to args to enable BitmapSearcher
        result=$?
        echo "get_seed_file returned $result and printed \"$seed_file\""

        if [ $result -eq 255 ]; then
            # Avoid flooding the log with messages if we are the only
            # runnable state in the s2e instance.
            sleep 1
            continue
        fi

        break
    done

    if [ "x$seed_file" = "x" ]; then
        
        run_cb
        
    else
        ./s2eget "$seed_file"
        seed_file="$(basename $seed_file)"

        ./s2ecmd symbfile $seed_file
        ./wrjpgcom -comment "test.comment" $seed_file >/tmp/out 2>&1
        
    fi
}


###############################################################
# Main entry point
###############################################################

prepare_file

run_cb_concolic

###############################################################
# Code common for all types of CBs
###############################################################


./s2ecmd kill 0 "done"
