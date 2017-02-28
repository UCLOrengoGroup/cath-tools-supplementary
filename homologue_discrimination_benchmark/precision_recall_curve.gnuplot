set   terminal postscript eps enhanced color
set   output "precision_recall_curve.eps"
set xlabel 'Recall' font "Helvetica,20"
set ylabel 'Precision' font "Helvetica,20"

set size square 2,2
set xtics 0,10
set ytics 0,10
set xrange [0:100]
set yrange [0:100]
set style line 11 lc rgb "#808080" lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb "#808080" lt 0 lw 1
set grid back ls 12
set key bottom right
set key font ",11"
set key spacing 0.7
set xtics font "Helvetica,18"
set ytics font "Helvetica,18"
plot 50 with filledcurves y1 = 0 lc rgb "#EEEEEE" notitle, 'results_sets/SSAP.r18631.sorted_roc_data.prec_rec' with lines  linetype 1 linecolor rgb "green" linewidth 3  title 'SSAP r18631 (WOLF+SEC)', 'results_sets/v0.12.24-21-g06fbfeb_PDB_DSSP_SEC.sorted_roc_data.prec_rec'  with lines  linetype 1 linecolor rgb "red"  linewidth 3  title 'cath-ssap v0.12.24-21-g06fbfeb using PDB+DSSP+SEC',  'results_sets/v0.12.24-21-g06fbfeb_PDB_DSSP.sorted_roc_data.prec_rec'  with lines  linetype 1 linecolor rgb "blue" linewidth 3  title 'cath-ssap v0.12.24-21-g06fbfeb using PDB+DSSP',  'results_sets/v0.12.24-55-g7be7ae4_PDB.sorted_roc_data.prec_rec'  with lines  linetype 1 linecolor rgb "orange" linewidth 3  title 'cath-ssap v0.12.24-55-g7be7ae4 using PDB'
