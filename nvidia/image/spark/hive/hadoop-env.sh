# Prepend/Append plugin parcel classpaths

if [ "$HADOOP_USER_CLASSPATH_FIRST" = 'true' ]; then
  # HADOOP_CLASSPATH={{HADOOP_CLASSPATH_APPEND}}
  :
else
  # HADOOP_CLASSPATH={{HADOOP_CLASSPATH}}
  :
fi
# JAVA_LIBRARY_PATH={{JAVA_LIBRARY_PATH}}

export HADOOP_MAPRED_HOME=$( ([[ ! '/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce' =~ CDH_MR2_HOME ]] && echo /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce ) || echo ${CDH_MR2_HOME:-/usr/lib/hadoop-mapreduce/}  )
export YARN_OPTS="-Xmx2147483648 -Djava.net.preferIPv4Stack=true -XX:+UseGCOverheadLimit  -XX:+UseConcMarkSweepGC -XX:MaxHeapFreeRatio=36 -XX:MinHeapFreeRatio=16 -XX:NewRatio=12 $YARN_OPTS"
export HADOOP_CLIENT_OPTS="-Djava.net.preferIPv4Stack=true $HADOOP_CLIENT_OPTS"
