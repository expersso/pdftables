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

get_content <- function(input_file, format = format, api_key = api_key) {

  response <- httr::POST("https://pdftables.com/api",
                         query = list(key = api_key, format = format),
                         body = list(files = httr::upload_file(input_file)))
  httr::stop_for_status(response)
  httr::content(response)
}

#' Convert PDF Tables to format more amenable to analysis
#'
#' @param input_file The PDF file to be converted
#' @param output_file The desired name for the output file
#' @param format One of 'csv', 'xlm', 'xlsx-single', 'xlsx-multiple'
#' @param message If TRUE, outputs a message that conversion was successful
#' @param api_key Your API key (from https://pdftables.com)
#'
#' @return Creates an output file with the converted PDF table
#' @export
#'
#' @examples
#' \dontrun{
#' write.csv(head(iris), file = "test.csv", row.names = FALSE)
#'
#' # Open test.csv and print as PDF to "test.pdf"
#'
#' convert_pdf("test.pdf", "test2.csv")
#' }
convert_pdf <- function(input_file, output_file = NULL, format = "csv",
                      message = TRUE, api_key = Sys.getenv("pdftable_api")) {

  stopifnot(file.exists(input_file))

  if(!format %in% c("csv", "xml", "xlsx-single", "xlsx-multiple")) {
    stop("format has to be one of 'csv', 'xlm', 'xlsx-single', 'xlsx-multiple'")
  }

  if(is.null(output_file)) {

    base <- tools::file_path_sans_ext(tools::file_path_as_absolute(input_file))

    file_ext <- switch(format,
                       "csv" = "csv",
                       "xml" = "xml",
                       "xlsx-single" = "xlsx",
                       "xlsx-multiple" = "xlsx")

    output_file <- paste(base, file_ext, sep = ".")
  }

  content <- get_content(input_file, format = format, api_key = api_key)

  if(format %in% c("xlsx-single", "xlsx-multiple")) {
    f <- file(output_file, "wb")
    writeBin(content, f)
    close.connection(f)
  }

  if(format %in% c("csv", "xml")) {
    f <- file(output_file, "w")
    write(content, f)
    close.connection(f)
  }

  if(message) {
    message("Converted ", input_file, " to ", output_file)
  }
}
