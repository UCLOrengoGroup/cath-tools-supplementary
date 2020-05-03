# `orengoftp`

~~~sh
ssh orengoftp
scl enable devtoolset-3 bash
cd /ftp/software/cath-tools/
git pull
touch source/cath_tools_git_version.hpp.in
git log --oneline | tac
git status
git branch -vv
make -C gcc_relwithdebinfo -k -j1
~~~

~~~sh
/ftp/software/cath-tools/gcc_relwithdebinfo/cath-superpose -v
# rsync -av orengoftp:/ftp/software/cath-tools/gcc_relwithdebinfo/ 
~~~
