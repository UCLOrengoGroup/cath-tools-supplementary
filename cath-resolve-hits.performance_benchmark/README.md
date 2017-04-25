# cath-resolve-hits performance benchmark

@jonglees has provided the titin data provided here (thanks Jon!).

The original motivation was for comparing CRH's performance to DF3's. However it's also showing CRH running quite a bit slower than previously seen: ~300k hits/s rather than ~1m-2m hits/s. On investigation, it appears that this is just due to this titin data being more interesting, structured data was previously being used. This makes it a good example for benchmarking performance.

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


| commit        | Build time           | runtime on titin
|:--|:--|:--|
| [ecb7c6f](https://github.com/UCLOrengoGroup/cath-tools/commit/ecb7c6f6fc9eceb3207db62495a80268307a8048) | 20170425 12:34:52 | ???

## Comparing DF3

~~~
limit memoryuse  8Gb
limit vmemoryuse 8Gb
limit

/usr/bin/time -v /cath-tools/resolve_stuff/df3/DomainFinder3 -i titin.ssf -o titin.df3_out
~~~
