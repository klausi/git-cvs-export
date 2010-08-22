#!/bin/sh

# cvs target directory
CVS_DIR=/home/klausi/git-cvs/contributions/sandbox/klausi/cvs-export-test

# file to keep last successfully exported commit ID
LAST_EXPORT_FILE=.cvslastexport

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
git pull -q
if [ $? -ne 0 ]
then
 echo "** git pull failed **"
 exit 1
fi

# get last exported commit ID
LAST_EXPORTED=`cat $LAST_EXPORT_FILE`
#echo "last exported: $LAST_EXPORTED"
# get new commit IDs
NEW_COMMITS=`git rev-list $LAST_EXPORTED..HEAD | tac`
#echo "new commits: $NEW_COMMITS"
# loop for exporting each commit
for COMMIT in $NEW_COMMITS
do
  echo '** Exporting commit to CVS: **'
  git cvsexportcommit -ucpw $CVS_DIR $COMMIT || clean_up
  # save succeddful exported commit to file
  echo $COMMIT > $LAST_EXPORT_FILE
done

