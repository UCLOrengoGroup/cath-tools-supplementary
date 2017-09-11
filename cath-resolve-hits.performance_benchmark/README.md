# cath-resolve-hits performance benchmark

@jonglees has provided the titin data provided here (thanks Jon!).

The original motivation was for comparing CRH's performance to DF3's. However it has also guided improvements to CRH's speed because it showed CRH running substantially slower than previously seen and this was apparently due to this titin data being more interesting, structured data was previously being used. This makes it a good example for benchmarking performance.

## General benchmarking advice

 * Do timings using executables and data in `/dev/shm` to minimise the effect of loading.
 * Time using the release version because the relwithdebinfo can be huge and larger executable binaries can take longer.
 * Increasing trimming can substantially increase runtime because it means more combinations of hits are possible and must be explored.
 * Consider testing CRH with `--overlap-trim-spec 1/0` to keep consistent if comparing with older versions different versions (because very old had no trimming; slightly old had some 50/30; current has 30/10)

## Example Commands

~~~
mkdir -p /dev/shm/cath-resolve-hits-perf-test
cp titin.crh /dev/shm/cath-resolve-hits-perf-test/
cp titin.ssf /dev/shm/cath-resolve-hits-perf-test/
cp /cath-tools/ninja_gcc_relwithdebinfo/cath-resolve-hits   /dev/shm/cath-resolve-hits-perf-test/cath-resolve-hits.gcc_withdebinfo
cd /dev/shm/cath-resolve-hits-perf-test
/usr/bin/time ./cath-resolve-hits.gcc_withdebinfo titin.crh --output-file titin.crh_out
~~~

## Performance benchmarks

~~~~~
/usr/bin/time ./cath-resolve-hits --overlap-trim-spec 1/0 titin.crh > /dev/null
~~~~~

| commit        | Build time           | runtime on titin
|:--|:--|:--|
| [1298bbc](https://github.com/UCLOrengoGroup/cath-tools/commit/1298bbcc636bd096d5fd00ff8c9286916f6e677d) | 20170428 18:18 | 0.26user

## Comparing DF3

~~~
limit memoryuse  8Gb
limit vmemoryuse 8Gb
limit

/usr/bin/time -v ./DomainFinder3 -i titin.ssf -o titin.df3_out
~~~







~~~
ls -1 *.gnuplot | xargs -I VAR gnuplot VAR
convert -background white -alpha off -trim -density 6000 -quality 100 -resize 25% multiplot.eps multiplot.jpg
~~~

