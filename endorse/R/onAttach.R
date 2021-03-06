".onAttach" <- function(lib, pkg) {
  mylib <- dirname(system.file(package = pkg))
  title <- packageDescription(pkg, lib.loc = mylib)$Title
  ver <- packageDescription(pkg, lib.loc = mylib)$Version
  packageStartupMessage(pkg, ": ", title, "\nVersion: ", ver)
}

