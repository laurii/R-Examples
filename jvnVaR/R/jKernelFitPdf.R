jKernelFitPdf <-
function(s,h,x){
f <- 1/h * jNormPdf((x-s)/h)
return(mean(f))
}
