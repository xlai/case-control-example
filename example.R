# This is a toy example of using future package to set up
# a nested parralel framework for any generic package that
# uses %dopar% for _internal_, i.e. within-package parall-
# elisation

# load package
library(future) # included in base R
library(glmnet)
library(doFuture) # an adapter for %dopar% in _future_ framework

# adopted example from glmnet doc
n = 1000
p = 100
nzc = trunc(p/10)
x = matrix(rnorm(n * p), n, p)
beta = rnorm(nzc)
fx = x[, seq(nzc)] %*% beta
eps = rnorm(n) * 5
y = drop(fx + eps)
px = exp(fx)
px = px/(1 + px)
ly = rbinom(n = length(px), prob = px, size = 1)

#setting up plans for the future
nworker = 10
nworker_cv = 4
plan(list(
    tweak(multisession, workers=nworker),
    tweak(multicore, workers=nworker_cv)
)
)

pid = Sys.getpid() #get pid of the process for monitoring

xs = 1:10

# declare future (not executed yet)
f <- list()
for (i in seq_along(xs)){
    f[[i]] = future({
        doFuture::registerDoFuture()
        cv.glmnet(x = x,y = y, parallel=TRUE)
    }, globals=list(x = x, y = y),
   packages=c('glmnet'),
   seed=TRUE  #explicit global declaration
)
}
#do some other things
x = 2
y = 3

# evaluate the future, notice the future wasn't affected by 
# re-assignment of x, y values
z = lapply(f, value)
