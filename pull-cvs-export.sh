#!/bin/sh
# TODO Someday support:
# [--branch <branch name> | --calculate-branches] 
#

if [ -z "$1" ]; then
  REF="HEAD"
else
  REF=$1
fi

# Make sure we where called correctly.
CURRENT_GIT="$(git rev-parse --git-dir 2>/dev/null)" || exit 4 "** Must be called from within a git repository **"
COMMIT_REF=$(git name-rev --name-only $REF) || exit 5 "** Must provide a single, valid sha-1 commit id **"
#BRANCH=${COMMIT_REF/~[0-9]*/}
BRANCH=

#if [ $BRANCH = "" ]; then
#  exit
#fi

# Include or general drupal sync config.
. /home/klausi/git-cvs/drupal-git-scripts/drupal_sync.conf

# Figure out what our module name is.
#if [ "$CURRENT_GIT" == '.git' ]; then
#  MODULE=`pwd | sed 's@/.*/@@'`
#else
#  # TODO I think this is broken
#  MODULE=`git rev-parse --git-dir | sed 's@/.*/\(.*\)/\.git@\1@'`
#fi

# varibale hacking
MODULE=sandbox/klausi/cvs-export-test
GITSRV=/home/klausi/git-cvs

clean_up() {
  #cvs -d /srv/cvs/drupal up -C $GITSRV/$MODULE_BASE/$MODULE/ > /dev/null
  rm $GITSRV/$MODULE_BASE/$MODULE/.msg $GITSRV/$MODULE_BASE/$MODULE/.cvsexportcommit.diff
  find $GITSRV/$MODULE_BASE/$MODULE -name '.#*' -exec rm '{}' \;
  echo "** CVS commit failed. Cleaning up cvs directory... **"
  exit 2
}

#if [ $MODULE = 'core' ]; then
#  MODULE_BASE="drupal"
#else
#  MODULE_BASE="contrib"
#fi
MODULE_BASE=contributions

echo '** Exporting commit to CVS: **'
git cvsexportcommit -ucpw $GITSRV/$MODULE_BASE/$MODULE $REF  || clean_up

