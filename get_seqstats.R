# This script runs some QC on your raw CRISPR screen sequencing files.

library(optparse)

option_list <- list(
  make_option(c("--multiqc"), type = "character", default = "multiqc_fastqc.txt", help = "Multi QC file with info on total reads. Default = [%default]"),
  make_option(c("--guidecounts"), type = "character", default = "guidecounts/", help = "Directory with individual guidecounts files. Default = [%default]"),
  make_option(c("--guidecount_summary"), type = "character", default = "guidecount_summary.tsv", help = "Guidecount summary output file. Default = [%default]"),
  make_option(c("--dirout"), type = "character", default = "seqstats/", help = "Guidecount summary output file. Default = [%default]")
)

parseobj <- OptionParser(option_list=option_list)
opt <- parse_args(parseobj)

mqc <- read.delim(opt$multiqc)
dir <- opt$guidecounts
dat <- read.delim(opt$guidecount_summary)
dirout <- opt$dirout
if (!dir.exists(dirout)) {
  dir.create(dirout)
}

files <- list.files(dir)
backbone <- integer(length(files))
total <- integer(length(files))
for (f in seq_along(files)) {
  dit <- read.delim(paste0(dir, files[f]), header = F)
  backbone[f] <- sum(dit[,2])
  i <- grep(paste0(gsub("_.*", "", files[f]), ".*_R1$"), mqc$Sample)
  if (length(i) == 0) {
    warning(paste0(files[f], " not represented in multiqc file"))
    total[f] <- NaN
  } else if (length(i) > 1) {
    warning(paste0(files[f], " represented multiple times in multiqc file"))
    total[f] <- NaN
  } else {
    total[f] <- mqc$Total.Sequences[i]
  }
}
mapped <- colSums(dat[,-c(1,2)])
df <- data.frame(Sample = gsub("_.*", "", files), Reads = total, 
                 Backbone = backbone, Mapped = mapped)
write.table(df, paste0(dirout, "/seqstats.tsv"), row.names = F, quote = F, sep = "\t")
mat <- rbind(mapped, backbone = backbone-mapped, total = total-backbone)
pdf(paste0(dirout, "/seqstats.pdf"), width = 10, height = 6)
barplot(mat, legend.text = rownames(mat), las = 2,
        args.legend = list(x = "topright", inset = c(0, -0.1)))
dev.off()
