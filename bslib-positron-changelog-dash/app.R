library(shiny)
library(bslib)
library(bsicons)
library(DT)
library(ggplot2)
library(gh)
library(dplyr)
library(purrr)
library(lubridate)

# Function to get all tags in a repository
get_all_tags <- function(repo) {
  owner <- strsplit(repo, "/")[[1]][1]
  repo_name <- strsplit(repo, "/")[[1]][2]

  tags <- gh("/repos/:owner/:repo/tags", owner = owner, repo = repo_name, .limit = Inf)
  map_chr(tags, "name")
}

# Function to get commits between two tags
get_commits_between_tags <- function(repo, base_tag, compare_tag) {
  owner <- strsplit(repo, "/")[[1]][1]
  repo_name <- strsplit(repo, "/")[[1]][2]

  base_sha <- gh("/repos/:owner/:repo/git/ref/tags/:tag",
                 owner = owner, repo = repo_name, tag = base_tag)$object$sha
  compare_sha <- gh("/repos/:owner/:repo/git/ref/tags/:tag",
                    owner = owner, repo = repo_name, tag = compare_tag)$object$sha

  commits <- gh("/repos/:owner/:repo/compare/:base...:head",
                owner = owner, repo = repo_name, base = base_sha, head = compare_sha)

  map_df(commits$commits, function(commit) {
    message_header <- strsplit(commit$commit$message, "\n")[[1]]
    list(
      sha = commit$sha,
      message = message_header[1],
      author = commit$commit$author$name,
      full_message = commit$commit$message,
      date = as.POSIXct(commit$commit$author$date, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    )
  })
}

# Set repository
repo <- "posit-dev/positron"

ui <- page_navbar(
  title = "Changelog Dashboard",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  nav_panel(
    "Overview",
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Tags"),
        selectInput("base_tag", "Base Tag:", choices = get_all_tags(repo), selected = "2024.06.1-54"),
        selectInput("compare_tag", "Compare Tag:", choices = get_all_tags(repo))
      ),
      card(
        card_header("Statistics"),
        value_box(
          title = "Total Commits",
          value = textOutput("total_commits"),
          showcase = bsicons::bs_icon("code-slash", size = "1.5rem")
        ),
        value_box(
          title = "Date Range",
          value = textOutput("date_range"),
          showcase = bsicons::bs_icon("calendar-date", size = "1.5rem")
        )
      ),
    ),
    layout_columns(
      col_widths = 12,
      card(
        card_header("Commits Table"),
        DTOutput("commits_table")
      )
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Commits by Author"),
        plotOutput("author_plot")
      ),
      card(
        card_header("Commits Over Time"),
        plotOutput("time_plot")
      )
    )
  )
)

server <- function(input, output, session) {
  commits <- reactive({
    get_commits_between_tags(repo, input$base_tag, input$compare_tag)
  })

  output$total_commits <- renderText({
    nrow(commits())
  })

  output$date_range <- renderText({
    paste(
      format(min(commits()$date), "%Y-%m-%d"),
      "to",
      format(max(commits()$date), "%Y-%m-%d")
    )
  })

  output$commits_table <- renderDT({
    commits() %>%
      select(Date = date, Message = message) %>%
      arrange(desc(Date)) %>%
      select(Message)
  }, options = list(pageLength = 10, autoWidth = TRUE))

  output$author_plot <- renderPlot({
    commits() %>%
      count(author) %>%
      ggplot(aes(x = reorder(author, n), y = n)) +
      geom_col() +
      coord_flip() +
      labs(x = "Author", y = "Number of Commits", title = "Commits by Author")
  })

  output$time_plot <- renderPlot({
    commits() %>%
      mutate(date = as.Date(date)) %>%
      count(date) %>%
      ggplot(aes(x = date, y = n)) +
      geom_line() +
      geom_point() +
      labs(x = "Date", y = "Number of Commits", title = "Commits Over Time")
  })
}

shinyApp(ui, server)
