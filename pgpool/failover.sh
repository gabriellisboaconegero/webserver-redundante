#! /bin/sh
failed_node=$1
trigger_file=$2

echo "Fail node id $failed_node"

# node 0 é o primary (master), então realizar promote apenas nesse caso
if [ $failed_node = 1 ]; then
	exit 0
fi

touch $trigger_file
exit 0