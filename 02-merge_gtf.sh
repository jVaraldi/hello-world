#PBS -S /bin/bash
#PBS -e /pandata/varaldi/RNAseq_fev2018/logs/merge.error
#PBS -o /pandata/varaldi/RNAseq_fev2018/logs/merge.out
#PBS -N merge
#PBS -l nodes=1:ppn=4 -l mem=10gb
#PBS -q q1day
hostname
uname -a

# Script that merges the gtf obtained for the 32 samples to obtain the most comprehensive view of the transcriptome of L. boulardi. The loci of LbFV are removed and the gtf of LbFV (108 ORFs) is added to get an hybrid gtf Lb+LbFV. This gtf will be used to perform the mapping. 

###############################################
# GENOME Lb + LbFV
###############################################
GENOME=/pandata/varaldi/RNAseq_fev2018/Lb_LbFV.fa

###############################################
#LbFV GTF
###############################################
LbFV_GTF=/pandata/varaldi/RNAseq_fev2018/LbFV.gtf

###############################################
# softwares
###############################################
STRINGTIE=~/TOOLS/stringtie-1.3.4b.Linux_x86_64/stringtie
GFFREAD=~/TOOLS/gffread-0.9.11.Linux_x86_64/gffread
GFFCOMPARE=~/TOOLS/gffcompare-0.10.2.Linux_x86_64/gffcompare

###############################################
# list of gtf files to merge
###############################################

LISTE=/pandata/varaldi/RNAseq_fev2018/liste_gtf.txt

###############################################
# where to write 
###############################################
OUT=/pandata/varaldi/RNAseq_fev2018/
cd $OUT

###############################################
# MERGE GTFs 
###############################################
$STRINGTIE --merge -p 4 $LISTE -m 100 -o $OUT'merged.gtf'
# -m : minimum input transcript length to include in the merge
###############################################
# basic extract of the transcripts
###############################################
$GFFREAD -w $OUT'transcripts_Lb.fa' -g $GENOME $OUT'merged.gtf'

###############################################
# remove Lb loci from gtf
###############################################
grep -v LbFV $OUT'merged.gtf' > $OUT'merged_without_LbFV.gtf'

###############################################
# add LbFV 108 orfs to the GTF
###############################################
cat $LbFV_GTF $OUT'merged_without_LbFV.gtf' > $OUT'merged_Lb_plus_LbFV.gtf'

###############################################
# extract the transcripts Lb + LbFV
###############################################
$GFFREAD -w $OUT'transcripts.fa' -g $GENOME $OUT'merged_Lb_plus_LbFV.gtf'

