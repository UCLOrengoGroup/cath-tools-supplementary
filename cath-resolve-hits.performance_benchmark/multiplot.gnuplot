set terminal postscript eps enhanced color size 3.9,1.75
set output  'multiplot.eps'

set xlabel font "Helvetica,13" offset 0,0.8,0
set ylabel font "Helvetica,13"
set xtics font "Helvetica,11" offset 0,0.4
set ytics font "Helvetica,11" offset 0.5,0
set style line 11 lc rgb "#999999" lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb "#999999" lt 0 lw 1
set grid back ls 12
set key top right font "Helvetica,10"
set key samplen -3


set multiplot layout 1,3 scale 1.128,1.02

set xlabel 'False positives'
set ylabel 'True positives' offset 3.5,0,0
set xtics  0,0.01
set ytics  0,0.05
set xrange [0:0.01]
set yrange [0.75:1]
set object 1 circle at 0.00571839915,  0.852273081325 size scr 0.0375 fc rgb "#EEEEEE" fs solid
set object 2 circle at 0.00328632275,  0.9277108644   size scr 0.0375 fc rgb "#EEEEEE" fs solid
set object 3 circle at 0.001114264575, 0.9740195483   size scr 0.0375 fc rgb "#EEEEEE" fs solid
#set label 1 "         10% (hardest)"  at 0.0120759020527,  0.780690340934 rotate by -90 font "Helvetica,9"
set label 2 "         30% (hardest)"  at 0.00571839915,  0.852273081325 rotate by -90 font "Helvetica,9"
set label 3 "         60%"            at 0.00328632275,  0.9277108644   rotate by -90 font "Helvetica,9"
set label 4 "         100% (easiest)" at 0.001114264575, 0.9740195483   rotate by -90 font "Helvetica,9"
set label 5 "A" at graph 0.5, 1.0 center font "Helvetica,15" offset 0, 0.5
plot 'benchmark.df3_data.txt'            using 3:2 with points pt 5 ps 0.5 lw 1.75 lc rgb "#808080" title 'DF3', 'benchmark.crh_data.txt'            using 3:2 with points pt 2 ps 0.5 lw 1.75 lc rgb "#000000" title 'CRH', 'benchmark.crh_greedy_data.txt'     using 3:2 with points pt 4 ps 0.5 lw 1.75 lc rgb "#999999" title 'Greedy (trim)', 'benchmark.crh_greedy_1_0_data.txt' using 3:2 with points pt 6 ps 0.5 lw 1.75 lc rgb "#AAAAAA" title 'Greedy'

unset label 1
unset label 2
unset label 3
unset label 4
unset label 5
unset object 1
unset object 2
unset object 3
set label 6 "B" at graph 0.5, 1.0 center font "Helvetica,15" offset 0, 0.5
set xlabel 'Num inputs'
set ylabel 'CPU (minutes / 100k inputs)' offset 2.6,0,0
set xtics  0,100000
set ytics  0,5
set xrange [0:263312]
set yrange [0:20]
set xtics format '%.0s%c'
plot '-' with points notitle pt 9 ps 1 lc rgb "#FF0000", '-' with points notitle pt 11 ps 1 lc rgb "#FF0000", 'resources_comparison.df3_data.txt' using 2:3 with linespoints pt 5 ps 0.5 lw 2 dt 3 lc rgb "#808080" title 'DF3', 'resources_comparison.crh_data.txt' using 2:3 with linespoints pt 2 ps 0.5 lw 2 dt 1 lc rgb "#000000" title 'CRH'
78367 13.2561848892
E
78367 13.2561848892
E

unset label 6
set label 7 "C" at graph 0.5, 1.0 center font "Helvetica,15" offset 0, 0.5

set xlabel 'Num inputs'
set ylabel 'Memory (Gbs  / 100k inputs)' offset 2.6,0,0
set xtics  0,100000
set ytics  0,5
set xrange [0:263312]
set yrange [0:25]
set xtics format '%.0s%c'
plot '-' with points notitle pt 9 ps 1 lc rgb "#FF0000", '-' with points notitle pt 11 ps 1 lc rgb "#FF0000", 'resources_comparison.df3_data.txt' using 2:4 with linespoints pt 5 ps 0.5 lw 2 dt 3 lc rgb "#808080" title 'DF3', 'resources_comparison.crh_data.txt' using 2:4 with linespoints pt 2 ps 0.5 lw 2 dt 1 lc rgb "#000000" title 'CRH'
78367 20.26955962
E
78367 20.26955962
E

# 65828 17.12017694598
# 75232 19.48221395151
#  9404  2.36203700553
