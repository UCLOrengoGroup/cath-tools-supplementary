set   terminal postscript eps enhanced color
set   output "roc_curve.eps"
set xlabel 'False Positive Rate' font "Helvetica,20"
set ylabel 'True Positive Rate' font "Helvetica,20"

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
plot 1-x with lines               lc rgb "#EEEEEE" notitle, x   with filledcurves y1 = 0 lc rgb "#EEEEEE" notitle,  'curve_data.old.roc'  with lines  linetype 1 linecolor rgb "red"  linewidth 3  title 'Old cath-ssap results',  'curve_data.new.roc'  with lines  linetype 1 linecolor rgb "blue" linewidth 3  title 'New cath-ssap results'
