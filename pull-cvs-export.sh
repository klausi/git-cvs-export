#!/bin/sh

# cvs target directory
CVS_DIR=/home/klausi/git-cvs/sandbox/klausi/cvs-export-test

# Make sure we where called correctly.
CURRENT_GIT="$(git rev-parse --git-dir 2>/dev/null)" || exit 4 "** Must be called from within a git repository **"

clean_up() {
  #cvs -d /srv/cvs/drupal up -C $GITSRV/$MODULE_BASE/$MODULE/ > /dev/null
  rm $CVS_DIR/.msg $CVSDIR/.cvsexportcommit.diff
  find $CVS_DIR -name '.#*' -exec rm '{}' \;
  echo "** CVS commit failed. Cleaning up cvs directory... **"
  exit 2
}

# pull
git pull
# get last exported commit ID
LAST_EXPORTED=`cat .cvslastexport`
echo "last exported: $LAST_EXPORTED"
# get new commit IDs
NEW_COMMITS=`git rev-list $LAST_EXPORTED..HEAD`
echo "new commits: $NEW_COMMITS"
# loop for exporting each commit
for COMMIT in $NEW_COMMITS
do
  echo $COMMIT
  echo '** Exporting commit to CVS: **'
  #git cvsexportcommit -ucpw $CVS_DIR $REF || clean_up
done

