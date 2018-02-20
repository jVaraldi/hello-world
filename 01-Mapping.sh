#PBS -S /bin/bash
#PBS -e /pandata/varaldi/RNAseq_fev2018/logs/FICHIER_R1.error
#PBS -o /pandata/varaldi/RNAseq_fev2018/logs/FICHIER_R1.out
#PBS -N FICHIER_R1
#PBS -l nodes=1:ppn=2 -l mem=10gb
#PBS -q q1day
hostname
uname -a

# the script take 2 fastq paired-end files 
# map the reads on a reference genome using Hisat2 
# and generates a gtf file using STRINGTIE


################################################################################
#  executable path
################################################################################

# HISAT2
HISAT2_HOME=/panhome/varaldi/TOOLS/hisat2-2.1.0/
# StringTie
STRINGTIE=~/TOOLS/stringtie-1.3.4b.Linux_x86_64/stringtie
# SAMTOOLS
SAMTOOLS=/panusr/bin/samtools

################################################################################
# INPUT FILES
################################################################################

# file names of data (clean reads)
data1=FICHIER_R1
data2=FICHIER_R2

### les donnees sont la:
FOLDER_init=/pandata/varaldi/RNAseq_fev2017/TRIMMED_DATA


# where is the genome index 
GENOME=/pandata/varaldi/RNAseq_fev2018/Lb_LbFV.fa
GENOME_INDEX=/pandata/varaldi/RNAseq_fev2018/Lb_LbFV
# make an index of the genome
#$HISAT2_HOME/hisat2-build $GENOME $GENOME_INDEX Lb_LbFV


# trimming performed with fastq-mcf
# fastqc on raw data :/pandata/varaldi/RNAseq_fev2017/FASTQC_0
# fastqc on trimmed data :/pandata/varaldi/RNAseq_fev2017/FASTQC_trimmed

################################################################################
#   destination folder
################################################################################

# where to put the output data?
FOLDER=/pandata/varaldi/RNAseq_fev2018/OUT
mkdir $FOLDER'/'$data1

############################################################################
#    map the reads on the genome file (Lb+ LbFV)
############################################################################

# run hisat2 to map reads
$HISAT2_HOME/hisat2 -p 2 --dta -x $GENOME_INDEX -1 $FOLDER_init'/'$data1 -2 $FOLDER_init'/'$data2 -S ./alns.sam  --summary-file ./hisat2_summary_stats.txt

# sort and convert to bam using samtools
$SAMTOOLS view -Su alns.sam | $SAMTOOLS sort - alns.sorted

############################################################################
#    STRINGTIE to generate a gtf for insect genes in particular
############################################################################

$STRINGTIE alns.sorted.bam -o transcripts.gtf

mv alns.sorted.bam $FOLDER'/'$data1
mv transcripts.gtf $FOLDER'/'$data1
mv hisat2_summary_stats.txt $FOLDER'/'$data1
