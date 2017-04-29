#!/bin/bash
#
mvn --version >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
  echo "Please make sure that maven is installed and its bin directory is in PATH"
  exit 1
fi

mvn clean compile assembly:single
if [ -f "target/examineMNPFile-0.0.1-SNAPSHOT-jar-with-dependencies.jar" ]; then
  mv target/examineMNPFile-0.0.1-SNAPSHOT-jar-with-dependencies.jar ../deployment/files/
else
  echo "ERROR! Build of examinMNPFile may have been failed!"
  exit 1
fi

echo "Done! You can proceed with deployment"
