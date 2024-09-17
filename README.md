# CRISPRmapping
Code to derive counts per guide per sample from sequencing data of pooled CRISPR screens

# Background
In pooled CRISPR screens cells are infected with viruses that harbor constructs to express guide RNAs targeting genes; the pool contains multiple constructs targeting multiple genes, usually even genome-wide. Successful transduction and subsequent gene editing leads to gene knockout in case of a knockout screen. By enumerating constructs at the start of the screen and at the end of the screen, the experiment can determine which genes are required for continued growth, or alternatively, which genes need to be lost for positive selection. The relative abundance of constructs can be determined because the constructs integrate into the genomic DNA of the target cells. The constructs can be PCR'ed in pooled fashion by using primers on the vector backbone, sequenced by massively parallel sequencing, and the resulting reads can be mapped back to the sequence of the constructs (supposedly) present in the library. The scripts in this directory can generate the counts-file starting from fastq-files: the filetype that is usually provided by the sequencing service.

# Requirements
The scripts run in a Unix-like shell and require the availability of zgrep and perl. There is also an optional R-script for sequencing and mapping stats.

# Instructions
The script will enumerate reads mapping to guides in the guide library for all fastq-files in a directory. Fastq-files are expected to be compressed with gzip, and thus end in fastq.gz. Although there is a script available for paired-end reads, I recommend only using R1 (and obviously, what a waste to do paired-end sequencing just to map guides). The library file should be a tab-separated text file with the guide sequences (20 nucleotides!) in the first column and the gene name in the second column. Last thing you need to provide is the "motif" that precedes the guide sequence. The default represents the motif for the two-component TKOv3 library. For more details see below. CRISPRmapping.bash is the only program that needs to be run. Make sure guidecount_summary.pl is in the same directory as CRISPRmapping.bash. If you like to get a short QC summarizing for each sample the total reads, reads mapped to backbone, and reads mapped to guides, run the R-script get_seqstats.R

# Details
CRISPRmapping.bash takes 3 arguments: 
1. filepath to the library file with guide sequences: required!
2. path of the directory containing the fastq.gz files: optional if a directory "fastq" exists (default = "./fastq")
3. motif to identify reads with a proper backbone: optional (default = "GGTACCG"), can be entered as second argument if directory "./fastq" exists.
The program first loops over all files ending in R1.fastq.gz in the fastq directory (currently you have to manually change the code in the program to change this). It analyzes the lines in which it finds the motif and starts a hash with the next 20 nucleotides being the key and ++1 being the value, meaning every time it finds the same sequence it adds 1 to the count of that sequence. After the last line of the file is read, it prints all key-value pairs into a "guidecount" file in the newly made "guidecounts" directory. Subsequently, these files are looped through by guidecount_summary.pl. This perl program makes a hash of arrays for all 20-nt sequences (suppose this could get too big, but I have not encountered such problems yet) and adds a 0 count if a sequence is included in the library but not present in the guidecounts file. When all files are analyzed, the hash is printed as a large table of all guides (rows) and their abundance in all samples (columns). Currently nothing is done with sequences that are not present in the library, although it is quite trivial to count these per sample as well. This is something that is also revealed by looking at the sequencing stats. This R-script is somewhat of a post-mapping QC, which lists per sample the total reads (scraped from the multiQC-file), the reads containing the correct backbone (i.e. containing the sequence motif, obtained by summing the counts in the individual guidecount file), and the reads mapping to the library (called "Mapped", obtained by summing the columns in the guidecount summary file).  

# Output
The script generates "guidecounts" for all samples, which is a table of all the unique 20-nt sequences found behind the motif and the number of times they occur. The guidecount_summary.tsv table contains the counts for all guides in the library, tabulated for all samples.  

# Examples
```
# Downnloading the files to your local directory:
wget -c -O screen.zip "https://downloadlink.zip"
gunzip screen.zip # You may have to enter a password
# It may be handy to create a directory with symbolic links to only put a subset of the data
mkdir fastq; cd fastq
for i in ../sub/dir/ectory/JP*_R1.fastq.gz; do bn=`basename $i`; ln -s $i $bn; done; cd ..
# Now I am ready to start mapping! First with a default motif
bash ~/scripts/CRISPRmapping/CRISPRmapping.bash ~/scripts/CRISPRmapping/TKOv3.tsv
# You can visually inspect what would work as motif
zgrep ^[ACGTN] fastq/sample1_R1.fastq.gz | head -n 20
# The motif can be written as regular expression: I have needed this for a library!
bash ~/scripts/CRISPRmapping/CRISPRmapping2.bash ~/scripts/CRISPRmapping/TKOv3.tsv "GAAA[CT]ACCG"
# To get the sequencing stats, you also need the file with total reads per file.
# This is usually provided by the sequencing service. This particular R-script works for a specific format of multiQC,
# but it should be easy to adapt it to a different format. The R-script requires library optparse to run. 
Rscript ~/scripts/CRISPRmapping/get_seqstats.R --multiqc sub/dir/ectory/multiqc_data/multiqc_fastqc.txt
```
