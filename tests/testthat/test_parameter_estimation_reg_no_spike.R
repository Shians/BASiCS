context("Parameter estimation and denoised data (no-spikes+regression)\n")

test_that("Estimates match the given seed (no-spikes+regression)", 
{
  # Data example
  Data <- makeExampleBASiCS_Data(WithSpikes = FALSE, WithBatch = TRUE)
  sce <- SingleCellExperiment(assays = list(counts = counts(Data)),
                      colData = data.frame(BatchInfo = colData(Data)$BatchInfo))
  
  # Fixing starting values
  n <- ncol(Data)
  k <- 12
  PriorParam <- list(s2.mu = 0.5, s2.delta = 0.5, a.delta = 1,
                     b.delta = 1, p.phi = rep(1, times = n),
                     a.s = 1, b.s = 1, a.theta = 1, b.theta = 1)
  PriorParam$m <- rep(0, k); PriorParam$V <- diag(k)
  PriorParam$a.sigma2 <- 2; PriorParam$b.sigma2 <- 2  
  PriorParam$eta <- 5
  set.seed(2018)
  Start <- BASiCS:::HiddenBASiCS_MCMC_Start(Data, PriorParam,
                                            WithSpikes = FALSE)

  # Running the sampler
  set.seed(14)
  Chain <- BASiCS_MCMC(Data, N = 1000, Thin = 10, Burn = 500,
                       PrintProgress = FALSE, WithSpikes = FALSE,
                       Regression = TRUE)
  set.seed(14)
  ChainSCE <- BASiCS_MCMC(sce, N = 1000, Thin = 10, Burn = 500,
                       PrintProgress = FALSE, WithSpikes = FALSE,
                       Regression = TRUE)

  # Calculating a posterior summary
  PostSummary <- Summary(Chain)
  PostSummarySCE <- Summary(ChainSCE)
  
  # Checking parameter names
  ParamNames <- c("mu", "delta", "s", "nu", "theta",
                  "beta", "sigma2", "epsilon", "RefFreq")
  ParamNames1 <- c("mu", "delta", "s", "nu", "theta",
                  "beta", "sigma2", "epsilon")
  expect_that(all.equal(names(Chain@parameters), ParamNames), is_true())
  expect_that(all.equal(names(PostSummary@parameters), ParamNames1), is_true())
            
  # Check if parameter estimates match for the first 5 genes and cells
  Mu <- c(12.309, 10.771,  6.854, 10.717, 30.529)
  MuObs <- as.vector(round(displaySummaryBASiCS(PostSummary, "mu")[1:5,1],3))
  MuObsSCE <- as.vector(round(displaySummaryBASiCS(PostSummarySCE, 
                                                "mu")[1:5,1],3))
  expect_that(all.equal(MuObs, Mu), is_true())
  expect_that(all.equal(MuObsSCE, Mu), is_true())
            
  Delta <- c(1.112, 1.196, 1.640, 1.246, 0.496)
  DeltaObs <- as.vector(round(displaySummaryBASiCS(PostSummary, 
                                                   "delta")[1:5,1],3))
  DeltaObsSCE <- as.vector(round(displaySummaryBASiCS(PostSummarySCE, 
                                                   "delta")[1:5,1],3))
  expect_that(all.equal(DeltaObs, Delta), is_true())
  expect_that(all.equal(DeltaObsSCE, Delta), is_true())
            
  S <- c(0.806, 1.567, 0.233, 0.548, 1.357)
  SObs <- as.vector(round(displaySummaryBASiCS(PostSummary, "s")[1:5,1],3))
  SObsSCE <- as.vector(round(displaySummaryBASiCS(PostSummarySCE, 
                                                  "s")[1:5,1],3))
  expect_that(all.equal(SObs, S), is_true())
  expect_that(all.equal(SObsSCE, S), is_true())
  
  Theta <- c(0.197, 0.283)
  ThetaObs <- as.vector(round(displaySummaryBASiCS(PostSummary, "theta")[,1],3))
  ThetaObsSCE <- as.vector(round(displaySummaryBASiCS(PostSummarySCE, 
                                                   "theta")[,1],3))
  expect_that(all.equal(ThetaObs, Theta), is_true())
  expect_that(all.equal(ThetaObsSCE, Theta), is_true())
  
  Beta <- c(0.289, -0.365,  0.413,  0.161,  0.277)
  BetaObs <- as.vector(round(displaySummaryBASiCS(PostSummary, "beta")[1:5,1],3))
  BetaObsSCE <- as.vector(round(displaySummaryBASiCS(PostSummarySCE, 
                                                  "beta")[1:5,1],3))
  expect_that(all.equal(BetaObs, Beta), is_true())
  expect_that(all.equal(BetaObsSCE, Beta), is_true())
  
  Sigma2 <- 0.321
  Sigma2Obs <- round(displaySummaryBASiCS(PostSummary, "sigma2")[1],3)
  Sigma2ObsSCE <- round(displaySummaryBASiCS(PostSummarySCE, "sigma2")[1],3)
  expect_that(all.equal(Sigma2Obs, Sigma2), is_true())
  expect_that(all.equal(Sigma2ObsSCE, Sigma2), is_true())
  
  # Obtaining denoised counts     
  DC <- BASiCS_DenoisedCounts(Data, Chain)
  DCSCE <- BASiCS_DenoisedCounts(sce, ChainSCE)
  # Checks for an arbitrary set of genes / cells
  DCcheck0 <- c(4.164,  1.388,  0.000,  8.328, 9.716)
  DCcheck <- as.vector(round(DC[1:5,1], 3))
  DCSCEcheck <- as.vector(round(DCSCE[1:5,1], 3))
  expect_that(all.equal(DCcheck, DCcheck0), is_true())
  expect_that(all.equal(DCSCEcheck, DCcheck0), is_true())
  
  # Obtaining denoised rates
  DR <- BASiCS_DenoisedRates(Data, Chain)
  DRSCE <- BASiCS_DenoisedRates(sce, ChainSCE)
  # Checks for an arbitrary set of genes / cells
  DRcheck0 <- c(5.019,  3.062, 10.691,  1.584,  4.785)
  DRcheck <- as.vector(round(DR[10,1:5], 3))
  DRSCEcheck <- as.vector(round(DRSCE[10,1:5], 3))
  expect_that(all.equal(DRcheck, DRcheck0), is_true())
  expect_that(all.equal(DRSCEcheck, DRcheck0), is_true())
})

test_that("Chain creation works when regression, no spikes, and StoreAdapt=TRUE", {
  # Data example
  Data <- makeExampleBASiCS_Data(WithSpikes = FALSE, WithBatch = TRUE)
  # Fixing starting values
  n <- ncol(Data)
  k <- 12
  PriorParam <- list(s2.mu = 0.5, s2.delta = 0.5, a.delta = 1,
                     b.delta = 1, p.phi = rep(1, times = n),
                     a.s = 1, b.s = 1, a.theta = 1, b.theta = 1)
  PriorParam$m <- rep(0, k); PriorParam$V <- diag(k)
  PriorParam$a.sigma2 <- 2; PriorParam$b.sigma2 <- 2
  PriorParam$eta <- 5
  set.seed(2018)
  Start <- BASiCS:::HiddenBASiCS_MCMC_Start(Data, PriorParam, 
                                            WithSpikes = FALSE)
  # Running the sampler
  set.seed(42)
  Chain <- BASiCS_MCMC(Data, N = 50, Thin = 10, Burn = 10,
                     PrintProgress = FALSE, WithSpikes = FALSE,
                     Regression = TRUE, StoreAdapt = TRUE,
                     Start = Start, PriorParam = PriorParam)
  expect_s4_class(Chain, "BASiCS_Chain")
})
