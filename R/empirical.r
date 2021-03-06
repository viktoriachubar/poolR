empirical <- function(R, method, type, size = 10000, seed, emp.loop, ...) {
  
  # match method argument
  method <- match.arg(method, c("fisher", "stouffer", "invchisq", "binotest", 
                                "bonferroni", "tippett"))

  # check type argument
  if (!type %in% c(1, 2))
      stop("argument 'type' must be either 1 or 2.")
  
  if(missing(emp.loop))
    emp.loop <- FALSE

  k <- nrow(R)

  # check that R is symmetric
  if (!isSymmetric(R))
      stop("R is not symmetric.")

  # checking if the correlation matrix is positive definite by testing if all 
  # eigen-values are positive.
  if(!all(eigen(R)$values > 0)) {
    
    R <- nearPD(R)$mat
    warning("the correlation matrix is not positive definite. empirical() used Matrix::nearPD to make the correlation matrix positive definite.")
    
  }
  
  if (!missing(seed))
    set.seed(seed)
  
  if (emp.loop == FALSE) {
    
    Z <- mvrnorm(size, mu = rep(0, k), Sigma = R)
    
    if (type == 1)
      P <- pnorm(Z, lower.tail = FALSE)
    if (type == 2)
      P <- 2 * pnorm(abs(Z), lower.tail = FALSE)
    
    if (method == "fisher")
      emp.dist <- apply(P, 1, function(x) fisher(x)$testStat)
    
    if (method == "stouffer")
      emp.dist <- apply(P, 1, function(x) stouffer(x)$testStat)
    
    if (method == "invchisq")
      emp.dist <- apply(P, 1, function(x) invchisq(x)$testStat)
    
    if (method == "binotest")
      emp.dist <- apply(P, 1, function(x) binotest(x)$testStat)
    
    if (method == "bonferroni")
      emp.dist <- apply(P, 1, function(x) bonferroni(x)$testStat)
    
    if (method == "tippett")
      emp.dist <- apply(P, 1, function(x) tippett(x)$testStat)
    
  } else {
    
    emp.dist <- NULL
    
    for (i in 1:size) {
      
      Z <- mvrnorm(1, mu = rep(0, k), Sigma = R)
      
      if (type == 1)
        P <- pnorm(Z, lower.tail = FALSE)
      if (type == 2)
        P <- 2 * pnorm(abs(Z), lower.tail = FALSE)
      
      if (method == "fisher")
        emp.dist <- append(emp.dist, fisher(P)$testStat)
      
      if (method == "stouffer")
        emp.dist <- append(emp.dist, stouffer(P)$testStat)
      
      if (method == "invchisq")
        emp.dist <- append(emp.dist, invchisq(P)$testStat)
      
      if (method == "binotest")
        emp.dist <- append(emp.dist, binotest(P)$testStat)
      
      if (method == "bonferroni")
        emp.dist <- append(emp.dist, bonferroni(P)$testStat)
      
      if (method == "tippett")
        emp.dist <- append(emp.dist, tippett(P)$testStat)
      
    }
    
  }

  return(emp.dist)
  
}
