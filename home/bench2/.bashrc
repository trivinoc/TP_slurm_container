export PS1="[\u@\h \W]$"
cd $HOME
export PATH="/usr/lib64/openmpi3/bin:$PATH"
export LD_LIBRARY_PATH="/usr/lib64/openmpi3/lib:$LD_LIBRARY_PATH"
alias sacct_='\sacct -D --format=jobid%-13,user%-12,jobname%-35,submit,timelimit,partition,qos,nnodes,start,end,elapsed,state,exitcode%-6,Derivedexitcode%-6,nodelist%-200 '
alias sinfo_='\sinfo --format="%100E %12U %19H %6t %N" '
