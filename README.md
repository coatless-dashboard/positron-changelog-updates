# Positron Changelog Updates Dashboard

Dashboard app for looking at changelog updates for the new Positron IDE by Posit.
The changelog updates are shown by looking at the commit differences between tag comparisons.

In essence, this dashboard application is designed to provide a nice interface
to the GitHub URL for comparing tags.

```
https://github.com/posit-dev/positron/compare/<base>...<compare-to>
```

where `<base>` refers to the earlier tag and `<compare-to>` refers to the later tag.

## Dashboard Apps

The dashboard apps are written in two flavors:

- [{flexdashboard}](https://pkgs.rstudio.com/flexdashboard/): A dashboard written
  inside of R Markdown that takes advantage of Shiny.
- [{bslib}](https://rstudio.github.io/bslib/): A Shiny app that uses the new
  Bootstrap 5 theming engine to create a dashboard.
  
  
<table>
<tr><th>{flexdashboard}</th><th>{bslib}</th></tr>
<tr><td>

[![{flexdashboard} Dashboard Preview](https://github.com/coatless-dashboard/positron-changelog-updates/tree/main/images/flexdashboard-positron-changelog-dashboard.png)](flex-positron-changelog-dash/)

</td><td>

[![{bslib} Dashboard Preview](https://github.com/coatless-dashboard/positron-changelog-updates/tree/main/images/bslib-positron-changelog-dashboard.png)](bslib-positron-changelog-dash/)

</td></tr>
</table>

Due to the use of the [`{gh}`](https://github.com/r-lib/gh) R package to
interact with the GitHub API through [`{curl}`](https://cran.r-project.org/package=curl), the 
`{bslib}` dashboard is unable to be converted over to a shinylive dashboard.
