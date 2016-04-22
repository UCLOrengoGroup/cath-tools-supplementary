set terminal postscript eps enhanced color
set output "scatter_plot.eps"
#set title 'Comparison of modified version of cath-ssap on identical pairs' font "Helvetica,35"
set xlabel 'Old cath-ssap scores' font "Helvetica,25"
set ylabel 'New cath-ssap scores' font "Helvetica,25"

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
plot x with lines lc rgb "#EEEEEE" notitle, 'scatter_plot.data'  with points pointtype 7 pointsize 0.2 lc rgb '#000066' notitle
