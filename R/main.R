api_key <- "sxmc6jioozgp"

#' Retrieve the number of pages left on your account
#'
#' @param api_key Your API key (from https://pdftables.com)
#'
#' @return A numeric vector of length 1
#' @export
#'
#' @examples
#' \dontrun{get_remaining()}
get_remaining <- function(api_key = Sys.getenv("pdftable_api")) {

  response <- httr::GET("https://pdftables.com/api/remaining",
                        query = list(key = api_key))

  httr::stop_for_status(response)

  as.numeric(httr::content(response, "text", encoding = "UTF-8"))
}

#' Convert PDF Tables to format more amenable to analysis
#'
#' @param file The PDF file to be converted
#' @param format One of 'csv', 'xlm', 'xlsx-single', 'xlsx-multiple'
#' @param api_key Your API key (from https://pdftables.com)
#'
#' @return A string (format = 'csv', or format = 'xml') or raw vector (format =
#'   'xlsx-single' or 'xlsx-multiple`)
#' @export
#'
#' @examples
#' \dontrun{
#' write.csv(iris, file = "test.csv", row.names = FALSE)
#'
#' # Open test.csv and print as PDF
#'
#' test_xlsx <- get_table(file = "test.pdf", format = "xlsx-multiple")
#'
#' f <- file("test.xlsx", "wb")
#' writeBin(test_xlsx, f)
#' close(f)
#' }
get_table <- function(file, format, api_key = Sys.getenv("pdftable_api")) {

  if(!format %in% c("csv", "xml", "xlsx-single", "xlsx-multiple")) {
    stop("format has to be one of 'csv', 'xlm', 'xlsx-single', 'xlsx-multiple'")
  }

  response <- httr::POST("https://pdftables.com/api",
                         query = list(key = api_key, format = format),
                         body = list(files = httr::upload_file(file)))
  httr::stop_for_status(response)
  content <- httr::content(response)
  content
}
