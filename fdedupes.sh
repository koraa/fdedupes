#! /bin/sh
#
# fdedupes
# ========
#
# This is a little script to deduplicate a directory structure
# using the output of `fdupes`.
#
# Be carefull not to have multiple mountpoints under your dedup path,
# otherwise fdedupes might try to create cross-device links and exit failing.
#
# There is currently no option to create non-verbose output.
#
# The return value of this script is 0 if it succeeded, or 1 if
# one hardlink creation failed.
#
# Invocation
# ==========
#
# You first should create a list of duplicates (see man fdupes):
#
#     $ fdupes -r . > /tmp/duplicates
#
# If you want to dedup your root you can use:
#
#     $ fdupes -r / > /tmp/duplicates
#
# The file created by fdedupes is relative to the wrking directory.
# To create canonical references you might give canonical paths to fdupes:
#
#     $ fdupes -r "`readlink -f .`" >/tmp/duplicates
#
# Then you can use this output to deduplicate your disk:
#
#     $ fdedupes < /tmp/duplicates
#
# Or using a pipe
#
#     $ fdupes -r . | fdedupes
#
# COPYING
# =======
#
# Written 9.4.2012 by Karolin Varner
#
# fdedupes is licensed under the therms of the CC0 Universal/Public Domain (https://creativecommons.org/publicdomain/zero/1.0/).
# Although you might still buy me a beer...
#

erro() {
    erro "$@" >&2
}

while read l; do
    if [ -z "$l" ]; then
        REF=""
        erro "NULLREF!"
    elif [ -z "$REF" ]; then
        REF="$l"
        erro "SETREF! $l"
    else
        erro "LINKREF:"
        rm -v "$l"
        ln -v "$REF" "$l" || {
            erro "LINKING FAILED! Restoring a copy."
            cp -v "$REF" "$l";
            erro "Goodbye"
            exit 1
        }
    fi
done
