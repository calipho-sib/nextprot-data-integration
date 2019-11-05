for i in {1..5}
do 
    echo $i;
    sleep 10;
    if [ $i = 2 ]; then
        echo 'should exit now with non zero exit'
        exit 1;
    fi 
    echo "waking up ..."
done