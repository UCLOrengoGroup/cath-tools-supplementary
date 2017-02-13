set terminal postscript eps enhanced color
set output "scatter_plot.eps"
#set title 'Comparison of versions of SSAP on identical pairs' font "Helvetica,35"
set xlabel 'cath-ssap v0.12.24-21-g06fbfeb using PDB+DSSP+SEC' font "Helvetica,25"
set ylabel 'cath-ssap v0.12.24-21-g06fbfeb using PDB+DSSP' font "Helvetica,25"

set size square 3
#set xtics 0,0.1
#set ytics 0,0.1
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
plot x with lines lc rgb "#EEEEEE" notitle, 'scatter_plot.positive_data'  with points pointtype 7 pointsize 0.2 lc rgb '#006600' title 'Homologue pairs', 'scatter_plot.negative_data'  with points pointtype 7 pointsize 0.2 lc rgb '#660000' title 'Non-homologue pairs'
