if(getRversion() < "2.2")
    ## R 2.2.0 and later contain this in 'utils'
glob2rx <- function(pattern, trim.head = FALSE, trim.tail = TRUE)
{
    ## Purpose: Change "ls" aka "wildcard" aka "globbing" _pattern_ to
    ##	      Regular Expression (as in grep, perl, emacs, ...)
    ## -------------------------------------------------------------------------
    ## Author: Martin Maechler ETH Zurich, ~ 1991
    ##	       New version using [g]sub() : 2004
    p <- gsub('\\.','\\\\.', paste0('^', pattern, '$'))
    p <- gsub('\\?',	 '.',  gsub('\\*',  '.*', p))
    ## these are trimming '.*$' and '^.*' - in most cases only for esthetics
    if(trim.tail) p <- sub("\\.\\*\\$$", '', p)
    if(trim.head) p <- sub("\\^\\.\\*",  '', p)
    p
}
