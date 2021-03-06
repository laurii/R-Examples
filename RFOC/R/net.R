`net` <-
function(add=FALSE, col = gray(.7), border='black', lwd=1, LIM=c(-1,-1, +1, +1)  )
  {
    ###   net(add=FALSE, col = gray(.7), border='black', lwd=1)
    ###   net(add=FALSE, col = "brown" , border='black', lwd=.4)
    ##  lambert azimuthal Equal area Schmidt formula from Snyder p 185-186
    
    if(missing(add))  { add=FALSE }  
    if(missing(col))  { col = gray(.7) }  
    if(missing(lwd))  { lwd=1 }
    if(missing(border))  { border='black' }
    if(missing(LIM))  {LIM=c(-1,-1, +1, +1) }
    
    if(add==FALSE)
      {
        plot(c(LIM[1],LIM[3]),c(LIM[2],LIM[4]), type='n', xlab='', ylab='', asp=1, axes=FALSE, ann=FALSE) 
      }
    pcirc(gcol=col, border=border, ndiv=72)
    
    lam = pi*seq(from=0, to=180, by=5)/180
    lam0 = pi/2
    for(j in seq(from=-80, to=80, by=10))
      {
        phi = j*pi/180
        R = sqrt(2)/2
        kp = sqrt(2/(1+cos(phi)*cos(lam-lam0)))
        x = R*kp*cos(phi)*sin(lam-lam0)
        y = R * kp*sin(phi)
        lines(x,y, col=col, lwd=lwd)
      }

    phi = seq(from=-90, to=90, by=5)*pi/180
    for(j in seq(from=10, to=170, by=10))
      {
        lam = j*pi/180
        R = sqrt(2)/2
        kp = sqrt(2/(1+cos(phi)*cos(lam-lam0)))
        x = R*kp*cos(phi)*sin(lam-lam0)
        y = R * kp*sin(phi)
        lines(x,y, col=col, lwd=lwd)
   

      }

    segments(c(-.02, 0), c(0, -0.02), c(0.02, 0), c(0, 0.02), col='black' )
  }

