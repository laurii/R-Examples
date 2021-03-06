GA4StratificationP4x <-
function(crossoverGeneration,bestGeneration,dataName,numberOfStrata,sampleSize,fitnessValueGeneration,cumTotal,sumSquares,lengthData,dd,nocrom,fitp1,fit,N,means,s,n,vars,mas,NN,k,p,t)
 {
   fitnessValueParents=fitnessValueGeneration
   parents=cbind(crossoverGeneration,fitnessValueParents)
   crossoverGenerationp=crossoverGeneration
   rowCrossoverGenerationp=nrow(crossoverGenerationp)
   colCrossoverGenerationp=ncol(crossoverGenerationp)

	tableData=as.data.frame(table(dataName))
 	randomnumRange=cumsum(tableData[,2])
	lengthRandomnum=length(randomnumRange)


   randomNumbers=array(0,dim=c(rowCrossoverGenerationp,3))
   
   for (i in 1:rowCrossoverGenerationp)
   {
	randomNumbers[i,]=randomnumGenerator((1:rowCrossoverGenerationp),(rowCrossoverGenerationp+1),3)
   }
   mother=father=NULL
   for (i in 1:rowCrossoverGenerationp)
   {
	  mother=randomNumbers[i,1]
	  father=randomNumbers[i,2]
   
     	  crossoverPoint=sample((randomnumRange[1:lengthRandomnum-1]),1)
        while ( sum(crossoverGenerationp[mother,c(1:crossoverPoint)])!=sum(crossoverGenerationp[father,c(1:crossoverPoint)]) )
        {
	     	  crossoverPoint=sample((randomnumRange[1:lengthRandomnum-1]),1)
	  }
    	  crossoverGeneration[i,c(1:crossoverPoint)]=crossoverGenerationp[mother,c(1:crossoverPoint)]
        crossoverGeneration[i,c((crossoverPoint+1):colCrossoverGenerationp)]=crossoverGenerationp[father,c((crossoverPoint+1):colCrossoverGenerationp)]
   }
      s=GA4StratificationP4fit(crossoverGeneration,dataName,numberOfStrata,sampleSize,cumTotal,sumSquares,lengthData,dd,nocrom,fitp1,fit,N,means,s,n,vars,mas,NN,k,p,t)
      crossoverGenerationx=cbind(crossoverGeneration,s)
      GA4StratificationP4x=rbind(parents, crossoverGenerationx)
      GA4StratificationP4x=GA4StratificationP4x[order(GA4StratificationP4x[,(colCrossoverGenerationp+1)]),]
      GA4StratificationP4x=GA4StratificationP4x[c((rowCrossoverGenerationp+1):(rowCrossoverGenerationp*2)),c(1:colCrossoverGenerationp)]
	return(GA4StratificationP4x)
 }

