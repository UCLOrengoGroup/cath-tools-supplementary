set terminal postscript eps enhanced color
set output  'benchmark.eps'
set xlabel  'label' font "Helvetica"
set ylabel  'label' font "Helvetica"

set size square 1,1
set xlabel 'False positives'
set ylabel 'True positives'
set xrange [0:0.02]
set yrange [0.75:1]
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
plot 'benchmark.crh_data.txt'              using 3:2 with points pt 5 ps 0.8 lw 2.5 lc rgb "green"  title 'CRH', 'benchmark.df3_data.txt'              using 3:2 with points pt 7 ps 0.8 lw 2.5 lc rgb "orange" title 'DF3', 'benchmark.crh_greedy_data.txt'     using 3:2 with points pt 7 ps 0.8 lw 2.5 lc rgb "blue"   title 'Naive', 'benchmark.crh_greedy_1_0_data.txt' using 3:2 with points pt 7 ps 0.8 lw 2.5 lc rgb "red"    title 'Naive 1\_0', 'benchmark.crh_data.first_version.txt'         using 3:2 with points pt 7 ps 0.8 lw 2.5 lc rgb "black"  title 'CRH prev', 'benchmark.df3_data.first_version.txt'         using 3:2 with points pt 7 ps 0.8 lw 2.5 lc rgb "purple" title 'DF3 prev'