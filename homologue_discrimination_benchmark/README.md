ROC Regression Benchmark
========================

To generate a results-set, set the appropriate environment variables:

~~~~~
setenv HOM_BNCHMK_ROOTDIR $PWD
setenv HOM_BNCHMK_SRC_EXE /the/path/to/the/old/cath-ssap
setenv HOM_BNCHMK_ARGS    
setenv HOM_BNCHMK_VN_NAME SSAP.r18631
~~~~~

...and then execute the following:

~~~~~
setenv HOM_BNCHMK_RES_DIR $HOM_BNCHMK_ROOTDIR/${HOM_BNCHMK_VN_NAME}_results_dir
setenv HOM_BNCHMK_EXE_LN  $HOM_BNCHMK_ROOTDIR/$HOM_BNCHMK_VN_NAME

echo $HOM_BNCHMK_ROOTDIR
echo $HOM_BNCHMK_SRC_EXE
echo $HOM_BNCHMK_ARGS
echo $HOM_BNCHMK_VN_NAME
echo $HOM_BNCHMK_RES_DIR
echo $HOM_BNCHMK_EXE_LN

mkdir -p $HOM_BNCHMK_RES_DIR
ln -s $HOM_BNCHMK_SRC_EXE $HOM_BNCHMK_EXE_LN
awk '{print "cd '$HOM_BNCHMK_RES_DIR' ; '$HOM_BNCHMK_ROOTDIR/$HOM_BNCHMK_VN_NAME' " $1 " " $2 " > " $1 "_" $2 ".scores"}' < $HOM_BNCHMK_ROOTDIR/pair_list.labelled > $HOM_BNCHMK_RES_DIR/ssap.commands
setenv DOMDIR                /cath/data/v4_0_0/pdb
setenv PDBDIR                /cath/data/v4_0_0/pdb
setenv SECDIR                /cath/data/v4_0_0/sec
setenv WOLFDIR               /cath/data/v4_0_0/wolf
setenv CATH_TOOLS_PDB_PATH   /cath/data/v4_0_0/pdb
setenv CATH_TOOLS_DSSP_PATH  /cath/data/v4_0_0/dssp
setenv CATH_TOOLS_WOLF_PATH  /cath/data/v4_0_0/wolf
setenv CATH_TOOLS_SEC_PATH   /cath/data/v4_0_0/sec
nohup cat $HOM_BNCHMK_RES_DIR/ssap.commands | xargs -I VAR -P 9 /bin/tcsh -c "VAR" > & $HOM_BNCHMK_ROOTDIR/${HOM_BNCHMK_VN_NAME}.ssap.commands.out &
~~~~~

When that's finished, generate data files that are sorted for joining by `join` command:

~~~~~
setenv HOM_BNCHMK_RES_DIR $HOM_BNCHMK_ROOTDIR/${HOM_BNCHMK_VN_NAME}_results_dir
cat ${HOM_BNCHMK_RES_DIR}/*.scores | awk '{print $1 "_" $2 " " $0}' | sort -k 1b,1 > $HOM_BNCHMK_ROOTDIR/results_sets/${HOM_BNCHMK_VN_NAME}.full
awk '{print $1 " " $6}' < $HOM_BNCHMK_ROOTDIR/results_sets/${HOM_BNCHMK_VN_NAME}.full > $HOM_BNCHMK_ROOTDIR/results_sets/${HOM_BNCHMK_VN_NAME}.scores_only
~~~~~~

Once you're sure that data is complete and backed up, you can delete everything except the files in `results_sets`.

Create scatter plot data and plot it:

~~~~~
awk '$3 == 0 {print $1 "_" $2}' < pair_list.labelled | sort -k 1b,1 > negative_pairs.join_sorted
awk '$3 == 1 {print $1 "_" $2}' < pair_list.labelled | sort -k 1b,1 > positive_pairs.join_sorted
join results_sets/old.scores_only results_sets/new.scores_only | grep -Fwf negative_pairs.join_sorted | awk '{print $2 " " $3}' > scatter_plot.negative_data
join results_sets/old.scores_only results_sets/new.scores_only | grep -Fwf positive_pairs.join_sorted | awk '{print $2 " " $3}' > scatter_plot.positive_data
gnuplot          scatter_plot.gnuplot
ps2pdf -DEPSCrop scatter_plot.eps
~~~~~

Create ROC / precision-recall curve data for each of the results sets and plot them:

~~~~~
awk '{print $1 "_" $2 " " $3}' < $HOM_BNCHMK_ROOTDIR/pair_list.labelled | sort -k 1b,1 > $HOM_BNCHMK_ROOTDIR/pair_list.labelled.join_sorted
join $HOM_BNCHMK_ROOTDIR/results_sets/${HOM_BNCHMK_VN_NAME}.scores_only pair_list.labelled.join_sorted | awk '{print $2 " " $3}' | sort -rg -k 1 > $HOM_BNCHMK_ROOTDIR/results_sets/${HOM_BNCHMK_VN_NAME}.sorted_roc_data
$HOM_BNCHMK_ROOTDIR/svm_rocs.pl $HOM_BNCHMK_ROOTDIR/results_sets/${HOM_BNCHMK_VN_NAME}.sorted_roc_data
vim $HOM_BNCHMK_ROOTDIR/precision_recall_curve.gnuplot
vim $HOM_BNCHMK_ROOTDIR/roc_curve.gnuplot
gnuplot precision_recall_curve.gnuplot
gnuplot roc_curve.gnuplot
~~~~~
