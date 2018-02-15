#!/bin/bash
# Copyright 2018, Oracle and/or its affliates. All rights reserved. 

# check that all of the required parameters were provided
# note that wercker does not enforce this for us, so we have to check
if [[ -z "$WERCKER_SPOTBUGS_OUTPUT" || -z "$WERCKER_SPOTBUGS_FORMAT" ]]; then
  fail "$(date +%H:%M:%S): All required parameters: output and format MUST be specified"
fi

# try to find Java
if [ -z "$JAVA_HOME" ] ; then
  JAVACMD=`which java`
else
  JAVACMD="$JAVA_HOME/bin/java"
fi

# find the real location of java - in case it is a symlink
if [ -z "$JAVA_HOME" ] ; then
  # resolve links - $JAVACMD may be a link
  PRG="$JAVACMD"

  # need this for relative symlinks
  while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
      PRG="$link" else
      PRG="`dirname "$PRG"`/$link"
    fi
  done

  saveddir=`pwd`

  JAVA_HOME=`dirname "$PRG"`/..

  # make it fully qualified
  JAVA_HOME=`cd "$JAVA_HOME" && pwd`

  cd "$saveddir"
fi

if [[ -z "$JAVA_HOME" ]]; then
  fail "$(date +%H:%M:%S): Could not find Java in this box - please make sure you have Oracle JDK installed"
fi
echo "$(date +%H:%M:%S): Found JAVA_HOME at $JAVA_HOME"

########################### Install SpotBugs ########################### 
ENV SPOTBUGS_VERSION=3.1.1 WORKDIR /usr/workdir 
RUN apk add --update \ curl \ && rm -rf /var/cache/apk/* 
# Download the latest spotbugs release 
RUN curl -sL http://repo.maven.apache.org/maven2/com/github/spotbugs/spotbugs/i${SPOTBUGS_VERSION}/spotbugs-${SPOTBUGS_VERSION}.tgz | tar -xz | \ tar -xz && \ 
mv spotbugs-* /usr/bin/spotbugs 

#
# Get ready to start the SpotBugs
#

if [[ -z "$WERCKER_SPOTBUGS_OUTPUT" ]]; then
  OUTPUT=""
else
  OUTPUT="-output $WERCKER_SPOTBUGS_OUTPUT"
fi

if [[ -z "$WERCKER_SPOTBUGS_FORMAT" ]]; then
  FORMAT=""
else
  FORMAT="-$WERCKER_SPOTBUGS_FORMAT"
fi
