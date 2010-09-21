#!/bin/sh


if [ $# -ne 2 ]
then
  echo "Usage: $0 <git dir source> <CVS dir destination>"
fi

# git source directory
GIT_DIR=`readlink -f $1`

# cvs target directory
CVS_DIR=`readlink -f $2`

# file to keep last successfully exported commit ID
LAST_EXPORT_FILE=.cvslastexport

# switch to git dir
cd $GIT_DIR

# Make sure we where called correctly.
CURRENT_GIT="$(git rev-parse --git-dir 2>/dev/null)" || exit 4 "** First argument must be a git repository **"

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

# get new commit IDs
if [ -f $LAST_EXPORT_FILE ]
then
  # get last exported commit ID
  LAST_EXPORTED=`cat $LAST_EXPORT_FILE`
  #echo "last exported: $LAST_EXPORTED"
  # get the new commits since the last export
  NEW_COMMITS=`git rev-list $LAST_EXPORTED..HEAD | tac`
else
  # no last export here, so let's export the complete history
  NEW_COMMITS=`git rev-list HEAD | tac`
fi
#echo "new commits: $NEW_COMMITS"
# loop for exporting each commit
for COMMIT in $NEW_COMMITS
do
  echo '** Exporting commit to CVS: **'
  git cvsexportcommit -kaucpw $CVS_DIR $COMMIT || clean_up
  # save successful exported commit to file
  echo $COMMIT > $LAST_EXPORT_FILE
done

