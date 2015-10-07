## LOADING DATA

temp <- tempfile()                                        # set a temporary file
download.file('http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip',
              temp)                  # download (zip) file in the temporary file

content.name <- unzip(temp, list=TRUE)[1]            # whatch inside the archive

content.name                                            # there is only one file

data <- readLines(                                       # inspect lines of data
            unz(temp,                                         # archive to unzip
                content.name                   # the (only) file which is inside
            ),
            n=5                 # reading only the first 5 lines to inspect data
        )

data                                            # is a standard csv2 file format

data <- read.csv2(                            # data from the csv2 unzipped file
            unz(temp,
                content.name
            ),
            stringsAsFactors = FALSE
        )

unlink(temp)                                             # remove temporary file
rm(content.name, temp)


## CREATE USEFUL STRUCTURES

library(dplyr)                                # upgrade data.frame to data_frame
library(stringr)

data <- as_data_frame(data)                                # create a data_frame

glimpse(data)                                                     # inspect data

data <- data %>%
    filter(grepl('^0*[12]{1}/2/2007$', Date)) %>%       # filter interested case
    mutate_each(
        funs(
            str_replace_all(.,'\\?', 'NA')
        )
    ) %>%  # convert ? to NA
    transmute(
        Time=paste(Date, Time),           # we need e "continuum" temporal field
        Date=as.Date(Date, format='%d/%m/%Y'),
        Gap=as.numeric(Global_active_power),
        Grp=as.numeric(Global_reactive_power),
        V=as.numeric(Voltage),
        Gi=as.numeric(Global_intensity),
        S1=as.numeric(Sub_metering_1),
        S2=as.numeric(Sub_metering_2),
        S3=as.numeric(Sub_metering_3)
    ) %>%  # create date structure
    mutate(Week=as.factor(weekdays(Date)))

data$Time <- strptime(                            # convert string as time class
    data$Time,                                       # from our time
    format='%d/%m/%Y %H:%M:%S'                    # whith its format
)      # note: this step cannot be performed into a dplyr's "mutate"

summary(data)                                     # Note: here there aren't NAs!


## CREATE PLOT 1 on device PNG: plot1.png

png('plot1.png')             # switch-on output on PNG device named as requested

hist(                                                      # create an histogram
    x = data$Gap,              # of the frequencies of Global Active Power (Gap)
    col = 'red',                                                   # red colored
    main = 'Global Active Power',                               # with its title
    xlab = 'Global Active Power (kilowatts)',                 # and axes' labels
    ylab = 'Frequency'
)

dev.off()                                      # finaly we switch-off the Device

## THE END
