source("plotSRST2data.R")
library(ape)
library(ggtree)
library(tidyr)

srst2_output <- read.delim("./*compiledResults.txt",stringsAsFactors=F)
row.names(srst2_output) <- srst2_output$Sample

mlst_columns <- 2:10
gene_columns <- 15:46

h_tree<-as.phylo(clusterByST(srst2_output[,mlst_columns]))
geneMatrix<-binaryMatrix(srst2_output[,gene_columns])
geneMatrix <- as.data.frame(geneMatrix)

p1 <- ggtree(h_tree) %<+% srst2_output[,1:2] +
geom_tiplab(aes(color=ST),size=8) +
geom_text(aes(color=ST,label=ST),hjust=1,vjust=-0.4,size=7)

width=6
offset=0.85
p2 <- gheatmap(p1,geneMatrix,offset=offset,width=width,colnames=F,low="red",high="green") 
geneMatrix$sample <- row.names(geneMatrix)
gMatrix_g <- gather(geneMatrix,variable,value,-c(sample))
gMatrix_g$variable <- factor(gMatrix_g$variable,levels=colnames(geneMatrix))
width <- width * (p1$data$x %>% range %>% diff) / ncol(geneMatrix)
start <- max(p1$data$x) + offset
colpos <- start + as.numeric(gMatrix_g$variable) * width
colnames_pos <- data.frame(label=gMatrix_g$variable,pos=colpos)
colnames_pos <- unique(colnames_pos)

pdf(file="tree_mlst_resistance_heatmap.pdf",width=35,height=35)
	p2 + geom_text(data=colnames_pos,aes(x=pos,label=label),y=-0.8,angle=45,size=6,inherit.aes=FALSE) + theme(legend.position="none")
dev.off()
