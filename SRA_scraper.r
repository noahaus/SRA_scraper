install.packages("RSelenium")
library("RSelenium")

wd <- getwd()
file_name <- "SraRunTable.txt"

#open up the browser (will try to make this silent later)
driver <- rsDriver(port = 4L, browser = "chrome", chromever = "78.0.3904.105")
remote_driver <- driver[["client"]]

#navigate to SRA
remote_driver$navigate("https://www.ncbi.nlm.nih.gov/sra")
address_element <- remote_driver$findElement(using = 'name', value = 'term')
address_element$sendKeysToElement(list('Mycobacterium bovis'))
button_element <- remote_driver$findElement(using = 'id', value = "search")
button_element$clickElement()

#go to run selector page
run_selector <- remote_driver$findElement(using = 'link text', value = "Send results to Run selector")
run_selector$clickElement()

#Sleep for 10 seconds
Sys.sleep(10)

#download the metadata
metadata <- remote_driver$findElement(using = 'id', value = 't-rit-all')
metadata$clickElement()

#end session
Sys.sleep(3)
driver[["server"]]$stop()


if (Sys.info()[["sysname"]]=="Linux") {
  default_dir <- file.path("home", Sys.info()[["user"]], "Downloads")
} else {
  default_dir <- file.path("", "Users", Sys.info()[["user"]], "Downloads")
}

# move the file to the desired directory
file.rename(file.path(default_dir, file_name), file.path(wd, file_name))