#!/bin/sh
#
# This script is used by the git publish actions to get build version information
# Expected inputs to this script are:  <major version> <minor version>

NEXT_MAJOR=$1
NEXT_MINOR=$2
TAGSTR="Build-$NEXT_MAJOR.$NEXT_MINOR*"

# Find the latest build tag for the current <major>.<minor> version
LAST_BUILD_TAG=$(echo $(git tag --list $TAGSTR --sort -v:refname | head -1))
LAST_VER=$(echo $LAST_BUILD_TAG | cut -d'-' -f2)
MAJOR_TAG=$(echo $LAST_VER | cut -d'.' -f1)
MINOR_TAG=$(echo $LAST_VER | cut -d'.' -f2)
PATCH_TAG=$(echo $LAST_VER | cut -d'.' -f3)

# Increment the patch version accordingly
# If either the major or minor versions have changed since the last version, the patch version should be reset to 0
# otherwise just increment it.
if [ "$MAJOR_TAG" != "$NEXT_MAJOR" ] || [ "$MINOR_TAG" != "$NEXT_MINOR" ]
then
  NEXT_PATCH=0
else
  NEXT_PATCH=$((PATCH_TAG +1))
fi

# Construct the next build version string, this will be used for the build tag and the build artifcat name
NEXT_VER=$NEXT_MAJOR.$NEXT_MINOR.$NEXT_PATCH

#Make the environment variables available to the GITHUB_ENV
echo "NEXTVER=$NEXT_VER" >> $GITHUB_ENV
echo "PATCH=$NEXT_PATCH" >> $GITHUB_ENV

#GitHub action only exposes the long sha, but we want to tag the docker image with the short sha as that is better for helm
SHORT_SHA=$(git log --pretty=format:'%h' -n 1)
echo "SHORT_SHA=$SHORT_SHA" >> $GITHUB_ENV
