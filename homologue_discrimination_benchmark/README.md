ROC Regression Benchmark
========================

Generate results for benchmark ("old") version of cath-ssap:

~~~~~
mkdir old_ssap_results
ln -s /the/path/to/the/old/cath-ssap cath-ssap.old
awk '{print "cd '$PWD'/old_ssap_results ; '$PWD'/cath-ssap.old " $1 " " $2 " > " $1 "_" $2 ".old_scores"}' < pair_list.labelled > old_ssap_results/old_ssap_results.commands
setenv DOMDIR                /cath/data/v4_0_0/pdb
setenv PDBDIR                /cath/data/v4_0_0/pdb
setenv SECDIR                /cath/data/v4_0_0/sec
setenv WOLFDIR               /cath/data/v4_0_0/wolf
setenv CATH_TOOLS_PDB_PATH   .:/cath/data/v4_0_0/pdb
setenv CATH_TOOLS_DSSP_PATH  .:/cath/data/v4_0_0/dssp
setenv CATH_TOOLS_WOLF_PATH  .:/cath/data/v4_0_0/wolf
setenv CATH_TOOLS_SEC_PATH   .:/cath/data/v4_0_0/sec
nohup cat old_ssap_results.commands | xargs -I VAR -P 9 /bin/tcsh -c "VAR" > & ssap_commands.out &
~~~~~

Generate results for modified ("new") version of cath-ssap:

~~~~~
mkdir new_ssap_results
ln -s /the/path/to/the/new/cath-ssap cath-ssap.new
awk '{print "cd '$PWD'/new_ssap_results ; '$PWD'/cath-ssap.new " $1 " " $2 " > " $1 "_" $2 ".new_scores"}' < pair_list.labelled > new_ssap_results/new_ssap_results.commands
setenv DOMDIR                /cath/data/v4_0_0/pdb
setenv PDBDIR                /cath/data/v4_0_0/pdb
setenv SECDIR                /cath/data/v4_0_0/sec
setenv WOLFDIR               /cath/data/v4_0_0/wolf
setenv CATH_TOOLS_PDB_PATH   .:/cath/data/v4_0_0/pdb
setenv CATH_TOOLS_DSSP_PATH  .:/cath/data/v4_0_0/dssp
setenv CATH_TOOLS_WOLF_PATH  .:/cath/data/v4_0_0/wolf
setenv CATH_TOOLS_SEC_PATH   .:/cath/data/v4_0_0/sec
nohup cat new_ssap_results.commands | xargs -I VAR -P 9 /bin/tcsh -c "VAR" > & ssap_commands.out &
~~~~~

Generate data files that are sorted for joining by `join` command:

~~~~~
awk '{print $1 "_" $2 " " $3}' < pair_list.labelled          | sort -k 1b,1 > pair_list.labelled.join_sorted
awk '{print $1 "_" $2 " " $5}' old_ssap_results/*.old_scores | sort -k 1b,1 > scores.old
awk '{print $1 "_" $2 " " $5}' new_ssap_results/*.new_scores | sort -k 1b,1 > scores.new
~~~~~~

Create scatter plot data and plot it:

~~~~~
join scores.old scores.new | awk '{ print $2 " " $3}' > scatter_plot.data
gnuplot          scatter_plot.gnuplot
ps2pdf -DEPSCrop scatter_plot.eps
~~~~~

Create ROC / precision-recall curve data for each of the results sets and plot them:

~~~~~
join scores.old pair_list.labelled.join_sorted | awk '{print $2 " " $3}' | sort -rg -k 1 > curve_data.old
join scores.new pair_list.labelled.join_sorted | awk '{print $2 " " $3}' | sort -rg -k 1 > curve_data.new
svm_rocs.pl curve_data.old
svm_rocs.pl curve_data.new
gnuplot precision_recall_curve.gnuplot
gnuplot roc_curve.gnuplot
~~~~~
