context("sample")

## Generate test data without littering the environment with temporary
## variables
x <- NULL
y <- NULL
local({
    set.seed(123)
    f <- -1:1
    N <- 3
    T <- 2
    beta <- .5
    rho <- .5

    ## $x_i = 0.75 f + N(0, 1)$:
    x <- aperm(array(.75*f + rnorm(N*(T+1)), dim = c(N, 1, T+1)), 3:1)

    ## $y_{i,t} = \rho y_{i,t-1} + \beta x_{i,t} + f_i + N(0,1)$:
    y <- matrix(rep(beta*x[1,,] + f + rnorm(N), each = T+1), T+1, N)
    for (t in seq_len(T)+1) {
        y[t,] <- rho*y[t-1,] + f + beta*x[t,,] + rnorm(N)
    }

    x <<- x
    y <<- y
})


## Sanity check
test_that('data', {
    expect_equal(x, array(c(-1.31047564655221, -0.679491608575424, -0.289083794010798, 
                            -0.23017748948328, 0.129287735160946, -1.26506123460653,
                            2.30870831414912, 2.46506498688328, 0.0631471481064739),
                           dim = c(3, 1, 3)))
    expect_equal(y, matrix(c(-2.10089979337606, 1.10899305269782, 2.51416798413193,
                             -1.98942425038169, 0.729823109874504, 2.93377535075353,
                             -0.352340885393167, 0.230231415863224, 0.531844092800363),
                           nrow = 3, ncol = 3, byrow=TRUE))
})


test_that('rho', {
    set.seed(123)
    expect_equal(sample_rho(10, x, y, rho = c(0, .5, 1)),
                 c(1.0, 0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.5, 1.0))
})


test_that('sig', {
    set.seed(123)
    expect_equal(sample_sig(x, y, rho = c(1.0, 0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.5, 1.0)),
                 c(3.47057973968515, 3.76533958631778, 5.05616904090221, 0.319511980843401,
                   2.97344640702733, 1.25384839880482, 0.888201360379622, 2.84216255450146,
                   1.35200519668826, 0.0434125237806975))
})


test_that('beta', {
    set.seed(123)
    expect_equal(sample_beta(x, y,
                             rho = c(1, 0.5, 1, 0),
                             v = c(0.237091661226817, 2.60818150317784, 2.10900711686825, 4.29265963681323)),
                 as.matrix(c(2.57282485588875, 0.859094481853702, 0.983136793340975, 0.766863519235555)))
})


test_that('all', {
    set.seed(123)
    expect_equal(sample_all(x, y, n = 10, pts = c(0, .5, 1)),
                 list(rho = c(1.0, 0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.5, 1.0),
                      sig2 = 1 / c(3.18533847052255, 4.10251890097103, 1.25384839880482,
                                   0.0585040460504101, 0.442255004862561, 0.035105570425539,
                                   0.434297339273836, 2.30355584438599, 1.70033255494056,
                                   0.594859533302164),
                      beta = as.matrix(c(1.08887764629632, 1.56039942659895, 1.06592668114779,
                                         1.94115360819053, 0.64932639228806, -0.723483839828413,
                                         1.64356407596858, 1.1762269273108, 1.14516329636659,
                                         1.14599625391133))))
})
