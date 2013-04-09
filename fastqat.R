library(ggplot2)
library(reshape)
library(RColorBrewer)

d <- read.delim("fastqat_summary.txt", header=FALSE)
colnames(d) <- c("sample","genome","type","raw_counts")
df <- cast(d, genome * type ~ sample, value="raw_counts")
write.csv(file="fastqat_summary.csv", df, row.names=FALSE, quote=FALSE)
#ddply(d, .(sample), summarize, genome="unmapped", type="unmapped", raw_counts=raw_counts[genome=="0_reads"]-sum(raw_counts[type=="mapped"]))

d <- ddply(d, .(sample), transform, pct_of_good_reads=raw_counts/raw_counts[genome=="0_reads"])
d <- subset(d, genome != "0_rawreads" & genome != "0_reads")
d <- subset(d, type != "check")

dm <- melt(d, id.vars=c("sample","genome"), measure.vars=c("raw_counts","pct_of_good_reads"))
dm <- subset(dm, !(genome=="0_rejectedreads" & variable=="pct_of_good_reads"))
dm$genome <- factor(dm$genome)

pal <- c(brewer.pal(9, "Set1"), brewer.pal(8, "Set2"), brewer.pal(12, "Set3"))

dynamicwidth <- 800 + length(levels(dm$sample)) * 50 ## add 75 pixels for every sample

#ddply(dm, .(sample, variable), summarize, sum(value))
png("fastqat_summary.png", height=800, width=dynamicwidth, res=150)
print(ggplot(dm, aes(sample, value, fill=genome)) + geom_bar() + 
      facet_wrap(~variable, scales="free_y") + scale_fill_manual(values=pal, breaks=rev(levels(dm$genome))) + 
      opts(strip.text.x = theme_text(size = 15), axis.title.x=theme_blank(), axis.title.y=theme_blank(), axis.text.x=theme_text(angle=-90, vjust=.5, hjust=0, size=10)))
dev.off()
