#!/bin/sh

NODES_FILE="/etc/edh/nodes.csv"
HOSTNAME=`hostname`

echo "[INFO]:Install hadoop rpm"
mussh -m -u -b -t 6 -H $NODES_FILE -c "
		yum install -y -q hadoop hadoop-debuginfo hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-resourcemanager  hadoop-yarn-nodemanager hive hive-metastore hive-server2 hive-jdbc zookeeper-server zookeeper hbase hbase-master hbase-regionserver
"

echo "Config hadoop alternatives ..."
mussh -m -u -b -t 6 -H $NODES_FILE -c "
		rm -rf /etc/{hadoop,hive,hbase,zookeeper}/{conf,conf.edh}
		mkdir -p /etc/{hadoop,hive,hbase,zookeeper}/conf.edh

		alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.edh 50
		alternatives --set hadoop-conf /etc/hadoop/conf.edh

		alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.edh 50
		alternatives --set hive-conf /etc/hive/conf.edh

		alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/conf.edh 50
		alternatives --set hbase-conf /etc/hbase/conf.edh

		alternatives --install /etc/zookeeper/conf zookeeper-conf /etc/zookeeper/conf.edh 50
		alternatives --set zookeeper-conf /etc/zookeeper/conf.edh

		touch /var/lib/hive/.hivehistory
		chown -R hive:hive  /var/lib/hive/.hivehistory

		rm -rf /usr/lib/hive/lib/hive-hbase-handler.jar
		ln -s /usr/lib/hive/lib/hive-hbase-handler-0.10.0-cdh4.3.0.jar /usr/lib/hive/lib/hive-hbase-handler.jar
"

echo "Copy hadoop conf files to /etc/XXX/conf ..."

cp -u /etc/edh/conf-template/hadoop/conf/* /etc/hadoop/conf
cp -u /etc/edh/conf-template/hive/conf/* /etc/hive/conf
cp -u /etc/edh/conf-template/hbase/conf/* /etc/hbase/conf
cp -u /etc/edh/conf-template/zookeeper/conf/* /etc/zookeeper/conf

echo "Update hadoop conf files ..."
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/core-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/hdfs-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/mapred-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/yarn-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hive/conf/hive-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hbase/conf/hbase-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/slaves
sed -i "s|localhost|$HOSTNAME|g" /etc/hbase/conf/regionservers

pscp -h $NODES_FILE /etc/edh/postgresql-9.1-901.jdbc4.jar /usr/lib/hive/lib/postgresql-jdbc.jar

echo "Install hadoop rpm finish ..."


