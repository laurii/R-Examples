goTest <- function(par, fnName=c("Ackleys", "AluffiPentini",
                          "BeckerLago", "Bohachevsky1",
                          "Bohachevsky2", "Branin", "Camel3",
                          "Camel6", "CosMix2", "CosMix4",
                          "DekkersAarts", "Easom", "EMichalewicz",
                          "Expo", "GoldPrice", "Griewank", "Gulf",
                          "Hartman3", "Hartman6", "Hosaki", "Kowalik",
                          "LM1", "LM2n10", "LM2n5", "McCormic",
                          "MeyerRoth", "MieleCantrell",
                          "Modlangerman", "ModRosenbrock",
                          "MultiGauss", "Neumaier2", "Neumaier3",
                          "Paviani", "Periodic", "PowellQ",
                          "PriceTransistor", "Rastrigin",
                          "Rosenbrock", "Salomon", "Schaffer1",
                          "Schaffer2", "Schubert", "Schwefel",
                          "Shekel10", "Shekel5", "Shekel7",
                          "Shekelfox5", "Wood", "Zeldasine10",
                          "Zeldasine20"),  checkDim = TRUE){

  fnName <- match.arg(fnName)
  if(checkDim)
    if(length(par) != getProblemDimen(fnName))
      stop(paste("Parameter vector should be length",getProblemDimen(fnName)))
  out <- .C(fnName, sum = as.double(0), x=as.double(par), N=length(par), 
            PACKAGE = "globalOptTests")
  out$sum
}

getDefaultBounds <- function(fnName=c("Ackleys", "AluffiPentini",
                          "BeckerLago", "Bohachevsky1",
                          "Bohachevsky2", "Branin", "Camel3",
                          "Camel6", "CosMix2", "CosMix4",
                          "DekkersAarts", "Easom", "EMichalewicz",
                          "Expo", "GoldPrice", "Griewank", "Gulf",
                          "Hartman3", "Hartman6", "Hosaki", "Kowalik",
                          "LM1", "LM2n10", "LM2n5", "McCormic",
                          "MeyerRoth", "MieleCantrell",
                          "Modlangerman", "ModRosenbrock",
                          "MultiGauss", "Neumaier2", "Neumaier3",
                          "Paviani", "Periodic", "PowellQ",
                          "PriceTransistor", "Rastrigin",
                          "Rosenbrock", "Salomon", "Schaffer1",
                          "Schaffer2", "Schubert", "Schwefel",
                          "Shekel10", "Shekel5", "Shekel7",
                          "Shekelfox5",  "Wood", "Zeldasine10",
                          "Zeldasine20")) {
  fnName <- match.arg(fnName)
  switch(fnName, 
         "Ackleys"=list(lower=rep(-35,10),upper=rep(30,10)),
         "AluffiPentini"=list(lower=rep(-12,2),upper=rep(10,2)),
         "BeckerLago"=list(lower=rep(-12,2),upper=rep(10,2)),
         "Bohachevsky1"=list(lower=rep(-55,2),upper=rep(50,2)),
         "Bohachevsky2"=list(lower=rep(-55,2),upper=rep(50,2)),
         "Branin"=list(lower=c(-5,0),upper=c(10,15)),
         "Camel3"=list(lower=rep(-8,2),upper=rep(5,2)),
         "Camel6"=list(lower=rep(-8,2),upper=rep(5,2)),
         "CosMix2"=list(lower=rep(-2,2),upper=rep(1,2)),
         "CosMix4"=list(lower=rep(-2,4),upper=rep(1,4)),
         "DekkersAarts"=list(lower=rep(-25,2),upper=rep(20,2)),
         "Easom"=list(lower=rep(-12,2),upper=c(10,2)),
         "EMichalewicz"=list(lower=rep(0,5),upper=rep(pi,5)),
         "Expo"=list(lower=rep(-12,10),upper=rep(10,10)),
         "GoldPrice"=list(lower=rep(-3,2),upper=rep(2,2)),
         "Griewank"=list(lower=rep(-550,10),upper=rep(500,10)),
         "Gulf"=list(lower=c(.1,0,0),upper=c(100,25.6,5)),
         "Hartman3"=list(lower=rep(0,3),upper=rep(1,3)),
         "Hartman6"=list(lower=rep(0,6),upper=rep(1,6)),
         "Hosaki"=list(lower=rep(0,2),upper=c(5,6)),
         "Kowalik"=list(lower=rep(0,4),upper=rep(.42,4)),
         "LM1"=list(lower=rep(-15,3),upper=rep(10,3)),
         "LM2n5"=list(lower=rep(-10,5),upper=rep(5,5)),
         "LM2n10"=list(lower=rep(-10,10),upper=rep(5,10)),
         "McCormic"=list(lower=c(-1.5,-3),upper=c(4,3)),
         "MeyerRoth"=list(lower=rep(-10,3),upper=rep(10,3)),
         "MieleCantrell"=list(lower=rep(-1.5,4),upper=rep(1,4)),
         "Modlangerman"=list(lower=rep(0,10),upper=rep(10,10)),
         "ModRosenbrock"=list(lower=c(-7,-2),upper=c(5,2)),
         "MultiGauss"=list(lower=c(-3,-2),upper=c(2,2)),
         "Neumaier2"=list(lower=rep(0,4),upper=c(1,2,3,4)),
         "Neumaier3"=list(lower=rep(-115,10),upper=rep(100,10)),
         "Paviani"=list(lower=rep(2,10),upper=rep(10,10)),
         "Periodic"=list(lower=rep(-15,2),upper=rep(10,2)),
         "PowellQ"=list(lower=rep(-15,4),upper=rep(10,4)),
         "PriceTransistor"=list(lower=rep(0,9),upper=rep(10,9)),
         "Rastrigin"=list(lower=rep(-525,10),upper=rep(512,10)),
         "Rosenbrock"=list(lower=rep(-40,10),upper=rep(30,10)),
         "Salomon"=list(lower=rep(-120,5),upper=rep(100,5)),
         "Schaffer1"=list(lower=rep(-120,2),upper=rep(100,2)),
         "Schaffer2"=list(lower=rep(-120,2),upper=rep(100,2)),
         "Schubert"=list(lower=rep(-15,2),upper=rep(10,2)),
         "Schwefel"=list(lower=rep(-500,10),upper=rep(500,10)),
         "Shekel10"=list(lower=rep(0,4),upper=rep(10,4)),
         "Shekel5"=list(lower=rep(0,4),upper=rep(10,4)),
         "Shekel7"=list(lower=rep(0,4),upper=rep(10,4)),
         "Shekelfox5"=list(lower=rep(0,5),upper=rep(10,5)),
         "Wood"=list(lower=rep(-14,4),upper=rep(10,4)),
         "Zeldasine10"=list(lower=rep(0,10),upper=rep(pi,10)),
         "Zeldasine20"=list(lower=rep(0,20),upper=rep(pi,20)))
}
getProblemDimen <- function(fnName=c("Ackleys", "AluffiPentini",
                          "BeckerLago", "Bohachevsky1",
                          "Bohachevsky2", "Branin", "Camel3",
                          "Camel6", "CosMix2", "CosMix4",
                          "DekkersAarts", "Easom", "EMichalewicz",
                          "Expo", "GoldPrice", "Griewank", "Gulf",
                          "Hartman3", "Hartman6", "Hosaki", "Kowalik",
                          "LM1", "LM2n10", "LM2n5", "McCormic",
                          "MeyerRoth", "MieleCantrell",
                          "Modlangerman", "ModRosenbrock",
                          "MultiGauss", "Neumaier2", "Neumaier3",
                          "Paviani", "Periodic", "PowellQ",
                          "PriceTransistor", "Rastrigin",
                          "Rosenbrock", "Salomon", "Schaffer1",
                          "Schaffer2", "Schubert", "Schwefel",
                          "Shekel10", "Shekel5", "Shekel7",
                          "Shekelfox5", "Wood", "Zeldasine10",
                          "Zeldasine20")) {
  fnName <- match.arg(fnName)
  length(getDefaultBounds(fnName)$lower)
}
getGlobalOpt <- function(fnName=c("Ackleys", "AluffiPentini",
                          "BeckerLago", "Bohachevsky1",
                          "Bohachevsky2", "Branin", "Camel3",
                          "Camel6", "CosMix2", "CosMix4",
                          "DekkersAarts", "Easom", "EMichalewicz",
                          "Expo", "GoldPrice", "Griewank", "Gulf",
                          "Hartman3", "Hartman6", "Hosaki", "Kowalik",
                          "LM1", "LM2n10", "LM2n5", "McCormic",
                          "MeyerRoth", "MieleCantrell",
                          "Modlangerman", "ModRosenbrock",
                          "MultiGauss", "Neumaier2", "Neumaier3",
                          "Paviani", "Periodic", "PowellQ",
                          "PriceTransistor", "Rastrigin",
                          "Rosenbrock", "Salomon", "Schaffer1",
                          "Schaffer2", "Schubert", "Schwefel",
                          "Shekel10", "Shekel5", "Shekel7",
                          "Shekelfox5", "Wood", "Zeldasine10",
                          "Zeldasine20")) {
  fnName <- match.arg(fnName)
  switch(fnName, 
         "Ackleys"=0,
         "AluffiPentini"=-.3523,
         "BeckerLago"=0,
         "Bohachevsky1"=0,
         "Bohachevsky2"=0,
         "Branin"=.3979,
         "Camel3"=0,
         "Camel6"=-1.0316,
         "CosMix2"=-.2,
         "CosMix4"=-.4,
         "DekkersAarts"=-24776.5183,
         "Easom"=-1,
         "EMichalewicz"=-4.6877,
         "Expo"=-1,
         "GoldPrice"=3,
         "Griewank"=0,
         "Gulf"=0,
         "Hartman3"=-3.8628,
         "Hartman6"=-3.3224,
         "Hosaki"=-2.3458,
         "Kowalik"=0.0003,
         "LM1"=0,
         "LM2n5"=0,
         "LM2n10"=0,
         "McCormic"=-1.9133,
         "MeyerRoth"=4.355628e-05,
         "MieleCantrell"=0,
         "Modlangerman"=-0.9650,
         "ModRosenbrock"=0,
         "MultiGauss"=-1.2970,
         "Neumaier2"=0,
         "Neumaier3"=-210,
         "Paviani"=-45.7784,
         "Periodic"=0.9000,
         "PowellQ"=0,
         "PriceTransistor"=0,
         "Rastrigin"=0,
         "Rosenbrock"=0,
         "Salomon"=0,
         "Schaffer1"=0,
         "Schaffer2"=0,
         "Schubert"=-186.7309,
         "Schwefel"=-4189.8289,
         "Shekel10"=-10.5364,
         "Shekel5"=-10.1532,
         "Shekel7"=-10.4029,
         "Shekelfox5"=-10.4056,
         "Wood"=0,
         "Zeldasine10"=-3.5000,
         "Zeldasine20"=-3.5000)
}
