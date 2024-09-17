#!/bin/bash
mkdir guidecounts

if [ -z "$1" ]
then
  echo ERROR: specify guide sequences in first argument
  exit
fi
if [ ! -d fastq ]
then
  if [ -z "$2" ]
  then
    echo ERROR: no fastq directory found
    exit
  else
    fastq=$2
    if [ -z "$3" ]
    then
      motif="GGTACCG"
    else
      motif=$3
    fi
  fi
else
  fastq="./fastq"
  if [ -z "$2" ]
  then
    motif="GGTACCG"
  else
    motif=$2
  fi
fi
export motif

for i in $fastq/*R1.fastq.gz
	do
	bn=`basename $i`
	sname=${bn/_*/}	
	echo "Analyzing $sname"
	fname=guidecounts/$sname"_guidecounts.tsv"
	zgrep $motif $i | perl -ne 'if($_ =~ /$ENV{motif}([ATCG]{20})/) {$count{$1}++;}if(eof()){foreach (sort keys %count){ print $_,"\t";print $count{$_},"\n";}}' > $fname
done
echo "Making guidecount summary"
dir="$(dirname "${BASH_SOURCE[0]}")"
perl $dir/guidecount_summary.pl $1
echo "This program was kindly provided to you by your friendly neighborhood bioinformatician Jos Poell"

