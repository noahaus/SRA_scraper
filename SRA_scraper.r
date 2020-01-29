#check for dependencies
if(!require("RSelenium")){
  install.packages("RSelenium", repos = "http://cran.us.r-project.org")
  library("RSelenium")} else {
    library("RSelenium")  
  }
if(!require("optparse")){
  install.packages("optparse", repos = "http://cran.us.r-project.org")
  library("optparse")} else {
    library("optparse")
  }

#Some house keeping stuff. Basically just check if there is a SRARunTable.txt in the Download folder
wd <- getwd()
file_name <- "SraRunTable.txt"

if (Sys.info()[["sysname"]]=="Linux") {
  default_dir <- file.path("home", Sys.info()[["user"]], "Downloads")
} else {
  default_dir <- file.path("", "Users", Sys.info()[["user"]], "Downloads")
}

if(file.exists(file.path(default_dir, file_name))){
  file.remove(file.path(default_dir, file_name))
} 

#what name do you want the metadata file to be? Start with a default name
out_name <- gsub(":","-",paste0("output","_",Sys.Date(),"_",format(Sys.time(), "%X"),".csv"))

wd <- getwd()
file_name <- "SraRunTable.txt"

option_list = list(
  make_option(c("-s", "--search"), type="character", default=NULL, help="search term used in SRA", metavar="character"),
  make_option(c("-d", "--driver"), type="character", default="chrome", help="the type of webdriver to initialize", metavar="character"),
  make_option(c("-o", "--output"), type="character", default= out_name, help="name of the output file", metavar="character")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

out_name <- opt$output

#open up the browser (will try to make this silent later)
driver <- rsDriver(port = 4L, browser = "chrome", chromever = "78.0.3904.105")
remote_driver <- driver[["client"]]

#navigate to SRA
remote_driver$navigate("https://www.ncbi.nlm.nih.gov/sra")
address_element <- remote_driver$findElement(using = 'name', value = 'term')
address_element$sendKeysToElement(list(opt$search))
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

# move the file to the desired directory
file.rename(file.path(default_dir, file_name), file.path(wd, out_name))