context("formatter")

test_that("formatter", {
  expect_is(formatter("span", style = "color:red"), "function")
  expect_equal(formatter("span", style = "color: red")(c(1,2,3)),
    sprintf('<span style="color: red">%s</span>', c(1,2,3)))
  expect_equal(formatter("span", function(x) ifelse(x, "yes", "no"))(c(1,0,0,1)),
    paste0("<span>", ifelse(c(1,0,0,1), "yes", "no"), "</span>"))
  expect_equal(formatter("span", x ~ ifelse(x, "yes", "no"))(c(1)),
    paste0("<span>", ifelse(c(1), "yes", "no"), "</span>"))
  expect_equal(local({
    yes_string <- "YES"
    no_string <- "NO"
    formatter("span", x ~ ifelse(x, yes_string, no_string))(c(TRUE, FALSE))
  }), paste0("<span>", c("YES","NO"), "</span>"))

  # dynamic scoping of formula
  expect_equal(local({
    yes <- "yes"
    no <- "no"
    formatter("span", x ~ ifelse(x, yes, no))(c(1,0,0,1))
  }), paste0("<span>", ifelse(c(1,0,0,1), "yes", "no"), "</span>"))

  df <- data.frame(x = c(-1, 0 ,1), y = c(-1, 0 ,1))
  expect_equal(formatter("span", ~ifelse(x >= 0 & y >= 0, "yes", "no"))(NULL, df),
    paste0("<span>", ifelse(df$x >= 0 & df$y >= 0, "yes", "no"), "</span>"))
})


test_that("formatters", {
  f1 <- color_tile("white", "pink")
  f1(0.1)
  f1(rnorm(10))
  f1(percent(rnorm(10)))
  f1(numeric())

  f2 <- color_bar("pink", 0.2)
  f2(0.1)
  f2(rnorm(10))
  f2(percent(rnorm(10)))
  f2(numeric())

  f3 <- color_text("green", "red")
  f3(0.1)
  f3(rnorm(10))
  f3(percent(rnorm(10)))
  f3(numeric())
})

