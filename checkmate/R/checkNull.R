#' Check if an argument is NULL
#'
#' @templateVar fn Null
#' @template x
#' @template checker
#' @export
#' @examples
#' testNull(NULL)
#' testNull(1)
checkNull = function(x) {
  if (!is.null(x))
    return("Must be NULL")
  return(TRUE)
}

#' @export
#' @include makeAssertion.R
#' @template assert
#' @rdname checkNull
assertNull = makeAssertionFunction(checkNull)

#' @export
#' @rdname checkNull
assert_null = assertNull

#' @export
#' @include makeTest.R
#' @rdname checkNull
testNull = makeTestFunction(checkNull)

#' @export
#' @rdname checkNull
test_null = testNull

# This function is already provided by testthat
# #' @export
# #' @include makeExpectation.R
# #' @template expect
# #' @rdname checkNull
expect_null = makeExpectationFunction(checkNull)
