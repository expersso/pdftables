## Test environments
* ubuntu 14.04 (on travis-ci), R 3.2.2
* win-builder (devel and release)

## Third submission

* Changed "CSV, XML, or XLSX" to "'.csv', '.xml', or '.xlsx.'" in DESCRIPTION
* Added URL and description of PDFTables API in Description field of DESCRIPTION

### R CMD check results
There were no ERRORs, or WARNINGs.

1 NOTE:
"New submission

Possibly mis-spelled words in DESCRIPTION:
  API (9:67, 10:65)
  PDF (3:35, 8:41, 12:33)
  PDFTables (9:57, 11:10, 12:68)"

## Second submission

* CRAN comment on first submission: 

"Thanks, we see that all your examples are wrapped withoin \dontrun{}, can't you
unwrap these so they can be checked?"

* Response:

The reason all examples are wrapped in \dontrun{} is because all functions in
the package need a private API key as an argument, which I would rather not
supply in the examples. Also, the API key is only good for a set number of total
free requests (after which a fee is charged), which would be used up very
quickly if used in examples.
