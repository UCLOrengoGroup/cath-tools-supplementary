set terminal postscript eps enhanced color
set output  'benchmark.eps'
set xlabel  'label' font "Helvetica"
set ylabel  'label' font "Helvetica"

set size square 1,1
#set xtics  0,100000
#set ytics  0,1
set xrange  [0:0.25]
set yrange  [0.75:1]
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
plot 'benchmark.crh_data.txt' using 3:2 with points pt 5 ps 0.8 lw 2.5 lc rgb "green"  title 'CRH', 'benchmark.df3_data.txt' using 3:2 with points pt 7 ps 0.8 lw 2.5 lc rgb "orange"   title 'DF3'