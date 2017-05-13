set terminal postscript eps enhanced color
set output  'resources_comparison.eps'
set xlabel  'Number of inputs' font "Helvetica"
set ylabel  'Memory (Gbs  / 100k inputs)' font "Helvetica"
set y2label 'CPU (seconds / 100k inputs)' font "Helvetica"

set size square 0.666,0.666
set xtics  0,100000
set ytics  0,1
set y2tics 0,1
set xrange  [0:263312]
set yrange  [0:5]
set y2range [0:5]
#set logscale y
#set logscale y2
set style line 11 lc rgb "#AAAAAA" lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb "#AAAAAA" lt 0 lw 1
set grid back ls 12
set key top right
#set key font ",11"
#set key spacing 0.7
set xtics  font "Helvetica"
set ytics  font "Helvetica"
set y2tics font "Helvetica"
plot 'resources_comparison.df3_data.txt' using 2:4 with linespoints axes x1y1 pt 5 ps 0.60 lw 2.5 lc rgb "green"  title 'DF3 memory', 'resources_comparison.df3_data.txt' using 2:3 with linespoints axes x1y2 pt 7 ps 0.75 lw 2.5 lc rgb "orange"   title 'DF3 time', 'resources_comparison.crh_data.txt' using 2:4 with linespoints axes x1y1 pt 5 ps 0.60 lw 2.5 lc rgb "#00008B" title 'CRH memory', 'resources_comparison.crh_data.txt' using 2:3 with linespoints axes x1y2 pt 7 ps 0.75 lw 2.5 lc rgb "#8B0000"    title 'CRH time'