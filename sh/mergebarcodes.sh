#!/bin/bash
#mergebarcodes in=<infile> out=<outfile>

usage(){
	echo "Written by Brian Bushnell"
	echo "Last modified June 25, 2014"
	echo ""
	echo "Description: Concatenates barcodes and quality onto read names."
	echo ""
	echo "Usage:	mergebarcodes.sh in=<file> out=<file> barcode=<file>"
	echo ""
	echo "Input may be stdin or a fasta or fastq file, raw or gzipped."
	echo "Output may be stdout or a file."
	echo "If you pipe via stdin/stdout, please include the file type; e.g. for gzipped fasta input, set in=stdin.fa.gz"
	echo ""
	echo ""
	echo "Optional parameters (and their defaults)"
	echo ""
	echo "Input parameters:"
	echo "in=<file>        	Input sequences to mask. 'in=stdin.fa' will pipe from standard in."
	echo "bar=<file>    	  	File containing barcodes."
	echo "interleaved=auto 	(int) If true, forces fastq input to be paired and interleaved."
	echo "qin=auto         	ASCII offset for input quality.  May be 33 (Sanger), 64 (Illumina), or auto."
	echo ""
	echo "Output parameters:"
	echo "out=<file>       	Write masked sequences here.  'out=stdout.fa' will pipe to standard out."
	echo "overwrite=t      	(ow) Set to false to force the program to abort rather than overwrite an existing file."
	echo "ziplevel=2       	(zl) Set to 1 (lowest) through 9 (max) to change compression level; lower compression is faster."
	echo "qout=auto        	ASCII offset for output quality.  May be 33 (Sanger), 64 (Illumina), or auto (same as input)."
	echo ""
	echo "Other parameters:"
	echo "pigz=t    	  	Use pigz to compress.  If argument is a number, that will set the number of pigz threads."
	echo "unpigz=t    	  	Use pigz to decompress."
	echo ""
	echo "Java Parameters:"
	echo "-Xmx       		This will be passed to Java to set memory usage, overriding the program's automatic memory detection."
	echo "				-Xmx20g will specify 20 gigs of RAM, and -Xmx200m will specify 200 megs.  The max is typically 85% of physical memory."
	echo ""
	echo "Please contact Brian Bushnell at bbushnell@lbl.gov if you encounter any problems."
	echo ""
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CP="$DIR""current/"

z="-Xmx1g"
z2="-Xms1g"
EA="-ea"
set=0

if [ -z "$1" ] || [[ $1 == -h ]] || [[ $1 == --help ]]; then
	usage
	exit
fi

calcXmx () {
	source "$DIR""/calcmem.sh"
	parseXmx "$@"
	if [[ $set == 1 ]]; then
		return
	fi
	freeRam 3200m 84
	z="-Xmx${RAM}m"
	z2="-Xms${RAM}m"
}
calcXmx "$@"

mergebarcodes() {
	#module unload oracle-jdk
	#module load oracle-jdk/1.7_64bit
	#module load pigz
	local CMD="java $EA $z -cp $CP jgi.MergeBarcodes $@"
	echo $CMD >&2
	$CMD
}

mergebarcodes "$@"
