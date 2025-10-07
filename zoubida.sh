fio --name=randrw --rw=randread --bs=4k --size=1G \
    --numjobs=4 --iodepth=32 --runtime=30 --time_based \
    --filename=/tmp/testfile