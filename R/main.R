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

get_content <- function(input_file, format, api_key) {

  response <- httr::POST("https://pdftables.com/api",
                         query = list(key = api_key, format = format),
                         body = list(files = httr::upload_file(input_file)))
  httr::stop_for_status(response)
  httr::content(response)
}

#' Convert PDF Tables to format more amenable to analysis
#'
#' @param input_file The PDF file to be converted. If this is a url
#' to a PDF rather than a file path then it is downloaded to a
#' temporary file via \code{download.file} before being sent to pdftables
#' for conversion. If \code{input_file} is a url then \code{output_file}
#' must not be \code{NULL}.
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

  if (grepl("^http://|^https://|^ftp://|^file://",input_file)){
    stopifnot(!is.null(output_file))
    tmp <- tempfile(fileext = ".pdf")
    download_check <- download.file(url = input_file,destfile = tmp)
    if (download_check != 0){
      stop("PDF download failed.")
    }
    input_file <- tmp
    on.exit(file.remove(tmp))
  }

  stopifnot(file.exists(input_file))

  format <- tolower(format)

  if(!format %in% c("csv", "xml", "xlsx-single", "xlsx-multiple")) {
    stop("format has to be one of 'csv', 'xlm', 'xlsx-single', 'xlsx-multiple'")
  }

  # If output_file is null, create file with same name as input file but
  # different file extension
  if(is.null(output_file)) {

    base <- tools::file_path_sans_ext(tools::file_path_as_absolute(input_file))

    file_ext <- regmatches(format, regexpr("[a-z]+", format))

    output_file <- paste(base, file_ext, sep = ".")
  }

  # Send input file to PDFTables and return content
  content <- get_content(input_file, format, api_key)

  # Write content to file
  if(format %in% c("xlsx-single", "xlsx-multiple")) {
    f <- file(output_file, "wb")
    writeBin(content, f)
  }

  if(format %in% c("csv", "xml")) {
    f <- file(output_file, "w")
    write(content, f)
  }

  if(message) message("Converted ", input_file, " to ", output_file)

  close.connection(f)
}
