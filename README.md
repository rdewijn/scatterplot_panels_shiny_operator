# Scatterplot Shiny operator for Tercen

##### Description

The `Scatterplot Shiny operator` is an operator to represent data as scatterplots in Tercen.

##### Usage

Input projection|.
---|---
`x-axis`, `y-axis`         | numeric, X and Y values for scatterplots
`row`           | factor (optional), groups corresponding to different plot panels
`column`        | factor (optional), groups corresponding to different plot panels
`colors`        | factor or numeric (optional), mapping for corresponding to points coloring 
`labels`        | factor or numeric (optional), used for text labels (if labels contains text) or point sizes (bubble plot, if labels are numeric)
Output relations|.
---|---
`Operator view`        | view of the Shiny application

##### Details

The operator takes all the values of a cell and represents a scatterplot. Depending on the assignment of rows, columns and colors in the Tercen projection, the layout will be different.

#### References

https://en.wikipedia.org/wiki/Scatter_plot
