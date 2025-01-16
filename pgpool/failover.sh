#! /bin/sh
failed_node=$1
trigger_file=$2

echo "Fail node id $failed_node"

if [ $failed_node = 1 ]; then
	exit 0
fi

touch $trigger_file
exit 0