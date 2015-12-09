# Read from csv files of ceilometer, and process to generate matrix for time slots, then do statistical analysis
library(forecast)
library(ggthemes)
library(ggplot2)
csv_data <- read.csv(file="~/r/netflow/output/1",head=TRUE,sep=",")
src_ids <- csv_data$src_id

test_list <- c('sort1', 'dfsio3', 'sort3', 'hivebench2', 'dfsio1', 'sort2', 'dfsio2', 'terasort3', 'hivebench3', 'terasort1', 'terasort2', 'hivebench1')
file_list <- paste("~/r/netflow/output/",test_list,sep="")

read_csv <- function(file_path){
  read.csv(file=file_path,head=TRUE,sep=",")
}

test_data <- lapply(file_list, read_csv)
csv_data <- do.call("rbind", csv_data)

#get number of nodes in the cluster
node_num <- max(length(levels(csv_data$src_id)),length(levels(csv_data$dst_id)))
max_flow <- max(csv_data$network.flow.bytes)
#generate matrix as node*node
x<-matrix(nrow=node_num,ncol=node_num)
#make a list for matrix snapshot
matrix_snap <- list(x)


#get a list of node ids
node_list <- levels(factor(c(levels(csv_data$src_id), levels(csv_data$dst_id))))
#form a src_list and a dst_list to merge
src_list <- data.frame(src_key=1:node_num,src_id=node_list)
dst_list <- data.frame(dst_key=1:node_num,dst_id=node_list)

#After merge, matrix_csv is all data with right matrix key to form a matrix
matrix_csv <- merge(src_list,merge(dst_list,csv_data))
#order csv by time stamp:
matrix_csv <- matrix_csv[order(matrix_csv$time_in_secs),]
#Drop the original src/dst ID, just use number as ID
matrix_csv <- id_matrix <- matrix_csv[c("src_key","dst_key","time_in_secs","network.flow.bytes")]

#Gather the dataframe into per src/dst pair and remove duplicate meter entry

flow_data <- ddply(matrix_csv,c("src_key","dst_key","time_in_secs"),summarise, rate=max(network.flow.bytes,na.rm=TRUE))
flow_data$rate[is.na(flow_data$rate)] <- 0


flow_counts <- ddply(matrix_csv,c("src_key","dst_key"),summarise, count=length(src_key), rate=sum(network.flow.bytes,na.rm=TRUE))


p <- ggplot(data=flow_counts, aes(x = src_key, y= dst_key))
p + geom_point(aes(size=count))


src <- 6
dst <- 7
flow.entry <- subset(flow_data, src_key == src & dst_key == dst)
flow.entry$rate[is.na(flow.entry$rate)] <- 0
flow.entry$rate <- flow.entry$rate/1000000
p <- ggplot(data=flow.entry, aes(x = time_in_secs, y= rate))
p + geom_line()

plot(flow.entry$rate, type="p", col="blue")



#split one flow entry into groups 
interval <- 10
sequence_split <- function(sequence, interval){
  chunks <- as.integer(length(sequence)/interval)
  chunks
  split(sequence,rep(1:chunks,rep(interval,chunks)))
}

flow.mean <- sapply(sequence_split(flow.entry$rate, interval), mean)
flow.median <- sapply(sequence_split(flow.entry$rate, interval), median)

plot(flow.mean,col=2)
points(flow.median,col=3)
