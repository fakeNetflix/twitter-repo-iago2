#!/bin/sh
#
# echo loadtest script.

THIS_DIR=$(cd $(dirname $0); pwd)
BASE_DIR=$(dirname $(dirname $THIS_DIR))

APP_NAME="echo_loadtest"
MAIN_JAR="$BASE_DIR/target/iago2-echo-package-dist.jar"

PIDFILE=$APP_NAME.pid

MAIN_CLASS="com.twitter.iago.launcher.Main"
HEAP_OPTS="-Xmx512m -Xms128m -XX:NewSize=64m"
GC_OPTS="-XX:+UseConcMarkSweepGC -verbosegc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+UseParNewGC -Xloggc:gc.log"
JAVA_OPTS="-server $GC_OPTS $HEAP_OPTS $PROFILE_OPTS"

if [ -z $JAVA_HOME ]; then
  potential=$(ls -r1d /opt/jdk /System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home /usr/java/default /usr/java/j* 2>/dev/null)f
  for p in $potential; do
    if [ -x $p/bin/java ]; then
      JAVA_HOME=$p
      break
    fi
  done
fi

${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp "${MAIN_JAR}" \
  ${MAIN_CLASS} \
  launch \
  -env.local \
  -requestRate=1 \
  -duration=5.minutes \
  -inputLog=${BASE_DIR}/src/scripts/echo-loadtest.sh \
  -reuseFile=true \
  -includeParrotHeader=false \
  -transportScheme=thrift \
  -thriftClientId=echo-client \
  -victimHostPort="localhost:8081" \
  -config=com.twitter.example.EchoLoadTestConfig \
  -jobName=${APP_NAME} \
  -yes
