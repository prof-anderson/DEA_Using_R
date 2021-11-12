# Web scraping of team salary data from Baseball Prospectus
# Inspired by example of web scraping
# https://towardsdatascience.com/tidy-web-scraping-in-r-tutorial-and-resources-ac9f72b4fe47

# The Lahman R Package table of player salaries from 2016 onwards.
# This function is a web scraper of team salary data from Baseball Prospectus
# The data for this goes back to Cot's Baseball Contracts.
# The Lahman package on salaries is based on player salaries.  This function
# focuses on team payrolls.

library(rvest)
library(dplyr)

year <- 2016

webpage <- paste0("https://legacy.baseballprospectus.com/compensation/?cyear=",as.character(year),"&team=&pos=")
# tmsal2019page <- "https://legacy.baseballprospectus.com/compensation/?cyear=2006&team=&pos="
sal_by_team <- read_html(webpage)
sal_by_team

str(sal_by_team)

#body_nodes <- salary_by_team %>%
#   html_node("body") %>%
#   html_children ()

sal_by_team_table <- rvest::html_table(sal_by_team)
# Extract tables from web page

sal_by_team_table <- sal_by_team_table[[4]]
# Keep the 4th table, drop the rest.

sal_by_team_df <- as.data.frame(
  cbind(sal_by_team_table$'Team Name',
        sal_by_team_table$'# Players',
        sal_by_team_table$'Payroll Sort'))
# Make a dataframe of the three columns of interest.

sal_by_team_df <- head(sal_by_team_df, -1)
# Remove the last row (TOTAL) of the table

sal_by_team_df$V2 <- as.numeric(sal_by_team_df$V2)

sal_by_team_df$V3 <- as.numeric(sal_by_team_df$V3)

sal_by_team_df$yearID=year

# Create column for League ID consistent with Lahman R package
sal_by_team_df$lgID="AL"
# Default to AL, change others as needed to NL

sal_by_team_df$lgID[sal_by_team_df$V1=="Arizona Diamondbacks"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Atlanta Braves"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Chicago Cubs"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Cincinnati Reds"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Colorado Rockies"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Florida Marlins"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Miami Marlins"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Houston Astros" &
                      year<=2012] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Los Angeles Dodgers"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Milwaukee Brewers" &
                      year>=2013] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Philadelphia Phillies"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Pittsburgh Pirates"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="San Diego Padres"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="San Francisco Giants"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="St. Louis Cardinals"] <- "NL"
sal_by_team_df$lgID[sal_by_team_df$V1=="Washington Nationals"] <- "NL"


# Create column for Team ID consistent with Lahman R package
sal_by_team_df$teamID="ARI"

sal_by_team_df$teamID[sal_by_team_df$V1=="Atlanta Braves"] <- "ATL"
sal_by_team_df$teamID[sal_by_team_df$V1=="Baltimore Orioles"] <- "BAL"
sal_by_team_df$teamID[sal_by_team_df$V1=="Boston Red Sox"] <- "BOS"
sal_by_team_df$teamID[sal_by_team_df$V1=="Chicago Cubs"] <- "CHN"
sal_by_team_df$teamID[sal_by_team_df$V1=="Chicago White Sox"] <- "CHA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Cincinnati Reds"] <- "CIN"
sal_by_team_df$teamID[sal_by_team_df$V1=="Cleveland Indians"] <- "CLE"
sal_by_team_df$teamID[sal_by_team_df$V1=="Cleveland Guardians"] <- "CLE"
sal_by_team_df$teamID[sal_by_team_df$V1=="Colorado Rockies"] <- "COL"
sal_by_team_df$teamID[sal_by_team_df$V1=="Detroit Tigers"] <- "DET"
sal_by_team_df$teamID[sal_by_team_df$V1=="Houston Astros"] <- "HOU"
sal_by_team_df$teamID[sal_by_team_df$V1=="Kansas City Royals"] <- "KCA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Los Angeles Angels"] <- "LAA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Anaheim Angels"] <- "ANA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Los Angeles Dodgers"] <- "LAN"
sal_by_team_df$teamID[sal_by_team_df$V1=="Miami Marlins"] <- "MIA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Florida Marlins"] <- "FLA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Milwaukee Brewers"] <- "MIL"
sal_by_team_df$teamID[sal_by_team_df$V1=="Minnesota Twins"] <- "MIN"
sal_by_team_df$teamID[sal_by_team_df$V1=="New York Mets"] <- "NYN"
sal_by_team_df$teamID[sal_by_team_df$V1=="New York Yankees"] <- "NYA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Oakland Athletics"] <- "OAK"
sal_by_team_df$teamID[sal_by_team_df$V1=="Philadelphia Phillies"] <- "PHI"
sal_by_team_df$teamID[sal_by_team_df$V1=="Pittsburgh Pirates"] <- "PIT"
sal_by_team_df$teamID[sal_by_team_df$V1=="San Diego Padres"] <- "SDN"
sal_by_team_df$teamID[sal_by_team_df$V1=="San Francisco Giants"] <- "SFN"
sal_by_team_df$teamID[sal_by_team_df$V1=="Seattle Mariners"] <- "SEA"
sal_by_team_df$teamID[sal_by_team_df$V1=="St. Louis Cardinals"] <- "SLN"
sal_by_team_df$teamID[sal_by_team_df$V1=="Tampa Bay Rays"] <- "TBA"
sal_by_team_df$teamID[sal_by_team_df$V1=="Texas Rangers"] <- "TEX"
sal_by_team_df$teamID[sal_by_team_df$V1=="Toronto Blue Jays"] <- "TOR"
sal_by_team_df$teamID[sal_by_team_df$V1=="Washington Nationals"] <- "NAT"
sal_by_team_df$teamID[sal_by_team_df$V1=="Montreal Expos"] <- "MON"

# -------------------------------------------------------
# Add Franchise ID to table

sal_by_team_df$franchID="ARI"

sal_by_team_df$franchID[sal_by_team_df$V1=="Atlanta Braves"] <- "ATL"
sal_by_team_df$franchID[sal_by_team_df$V1=="Baltimore Orioles"] <- "BAL"
sal_by_team_df$franchID[sal_by_team_df$V1=="Boston Red Sox"] <- "BOS"
sal_by_team_df$franchID[sal_by_team_df$V1=="Chicago Cubs"] <- "CHC"
sal_by_team_df$franchID[sal_by_team_df$V1=="Chicago White Sox"] <- "CHW"
sal_by_team_df$franchID[sal_by_team_df$V1=="Cincinnati Reds"] <- "CIN"
sal_by_team_df$franchID[sal_by_team_df$V1=="Cleveland Indians"] <- "CLE"
sal_by_team_df$franchID[sal_by_team_df$V1=="Cleveland Guardians"] <- "CLE"
sal_by_team_df$franchID[sal_by_team_df$V1=="Colorado Rockies"] <- "COL"
sal_by_team_df$franchID[sal_by_team_df$V1=="Detroit Tigers"] <- "DET"
sal_by_team_df$franchID[sal_by_team_df$V1=="Houston Astros"] <- "HOU"
sal_by_team_df$franchID[sal_by_team_df$V1=="Kansas City Royals"] <- "KCR"
sal_by_team_df$franchID[sal_by_team_df$V1=="Los Angeles Angels"] <- "ANA"
sal_by_team_df$franchID[sal_by_team_df$V1=="Anaheim Angels"] <- "ANA"
sal_by_team_df$franchID[sal_by_team_df$V1=="Los Angeles Dodgers"] <- "LAN"
sal_by_team_df$franchID[sal_by_team_df$V1=="Miami Marlins"] <- "FLA"
sal_by_team_df$franchID[sal_by_team_df$V1=="Florida Marlins"] <- "FLA"
sal_by_team_df$franchID[sal_by_team_df$V1=="Milwaukee Brewers"] <- "MIL"
sal_by_team_df$franchID[sal_by_team_df$V1=="Minnesota Twins"] <- "MIN"
sal_by_team_df$franchID[sal_by_team_df$V1=="New York Mets"] <- "NYM"
sal_by_team_df$franchID[sal_by_team_df$V1=="New York Yankees"] <- "NYY"
sal_by_team_df$franchID[sal_by_team_df$V1=="Oakland Athletics"] <- "OAK"
sal_by_team_df$franchID[sal_by_team_df$V1=="Philadelphia Phillies"] <- "PHI"
sal_by_team_df$franchID[sal_by_team_df$V1=="Pittsburgh Pirates"] <- "PIT"
sal_by_team_df$franchID[sal_by_team_df$V1=="San Diego Padres"] <- "SDP"
sal_by_team_df$franchID[sal_by_team_df$V1=="San Francisco Giants"] <- "SFG"
sal_by_team_df$franchID[sal_by_team_df$V1=="Seattle Mariners"] <- "SEA"
sal_by_team_df$franchID[sal_by_team_df$V1=="St. Louis Cardinals"] <- "STL"
sal_by_team_df$franchID[sal_by_team_df$V1=="Tampa Bay Rays"] <- "TBD"
sal_by_team_df$franchID[sal_by_team_df$V1=="Texas Rangers"] <- "TEX"
sal_by_team_df$franchID[sal_by_team_df$V1=="Toronto Blue Jays"] <- "TOR"
sal_by_team_df$franchID[sal_by_team_df$V1=="Washington Nationals"] <- "WSN"
sal_by_team_df$franchID[sal_by_team_df$V1=="Montreal Expos"] <- "WSN"

#salary_by_team_df

"salary_by_team_df"
