pdv_fp <- c(6,2,2,1,1)
pdv_fn <- c(2,3,2,1,0)
time_fp <- c(13,16,18,9,8)
time_fn <- c(5,1,2,3,1)
index <- c(30,40,50,60,70)

df <- data.frame(index,pdv_fp,pdv_fn,time_fp,time_fn)

make_dataframe <- function(x,method_name, error_type){
  data.frame(index, x, method=rep(method_name,length(x)), error=rep(error_type,length(x)))
}

pdv.p <- make_dataframe(pdv_fp,"PDV","False Positive")
pdv.n <- make_dataframe(pdv_fn,"PDV","False Negative")
time.p <- make_dataframe(time_fp,"ARIMA","False Positive")
time.n <- make_dataframe(time_fn,"ARIMA","False Negative")

df <- rbind(pdv.p,pdv.n,time.p,time.n)

false_positive <- rbind(pdv.p,time.p)

ggplot(data=false_positive, aes(x = index,fill=method)) +
  geom_bar(aes(y=x),stat="identity",position="dodge") +
  xlab("Threshold Persentage (%)") +
  ylab("False Positive Error (%)")
#theme_economist()


false_negative <- rbind(pdv.n,time.n)

ggplot(data=false_negative, aes(x = index,fill=method)) +
  geom_bar(aes(y=x),stat="identity",position="dodge") +
  xlab("Threshold Persentage (%)") +
  ylab("False Positive Error (%)")
#theme_economist()

perf_err + theme_economist_white()



#Read from experiment result csv file

exp_csv <- read.csv(file="~/r/netflow/experiment_results.csv",row.names=NULL,head=TRUE,sep=",")
exp_csv <- exp_csv*7/136
exp_csv$percentage <- exp_csv$percentage * 136 /7

make_dataframe <- function(x,method_name,error_type){
  data.frame(percentage=exp_csv$percentage, error=x, method=rep(method_name,length(x)), error=rep(error_type,length(x)))
}

pdv_fp <- make_dataframe(exp_csv$PDV.FP, "PDV Prediction", "False Positive")
pdv_fn <- make_dataframe(exp_csv$PDV.FN, "PDV Prediction", "False Negative")
time_fp <- make_dataframe(exp_csv$Time.FP, "Time Series Prediction", "False Positive")
time_fn <- make_dataframe(exp_csv$Time.FN, "Time Series Prediction", "False Negative")

false_positive <- rbind(pdv_fp,time_fp)
fp_plot <- ggplot(data=false_positive, aes(x = percentage, y=error, color=method, shape=method, group=method)) +
  geom_line(aes(linetype=method), size=1) + 
  geom_point(size=4, fill="white") +
  theme_classic()+
  xlab("Threshold Persentage (%)") +
  ylab("False Positive Error (%)") +
  theme(legend.justification=c(1,1), legend.position=c(1,1)) +
  theme(legend.title=element_blank()) 

false_negative <- rbind(pdv_fn,time_fn)
fn_plot <- ggplot(data=false_negative, aes(x = percentage, y=error, color=method, shape=method, group=method)) +
  geom_line(aes(linetype=method), size=1) + 
  geom_point(size=4, fill="white") +
  theme_classic()+
  xlab("Threshold Persentage (%)") +
  ylab("False Negative Error (%)") +
  theme(legend.justification=c(1,1), legend.position=c(1,1)) +
  theme(legend.title=element_blank()) 