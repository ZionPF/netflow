DIR="/home/ailzhang/ailing/netflow/dataset"
for i in $(ls $DIR)
do 
	echo $i
	cat $DIR/$i/*.txt > $DIR/$i.txt	
done
