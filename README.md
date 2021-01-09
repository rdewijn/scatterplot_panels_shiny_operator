# Scatterplot Shiny operator for Tercen

##### Description

The `Scatterplot Shiny operator` is an operator to represent data as scatterplots in Tercen.

##### Usage

Input projection|.
---|---
`y-axis`        | numeric, measurement to represent 
`row`           | factor (optional), groups corresponding to different plot panels
`column`        | factor (optional), groups corresponding to different plot panels
`colors`        | factor (optional), groups for corresponding to points coloring 

Output relations|.
---|---
`Operator view`        | view of the Shiny application

##### Details

The operator takes all the values of a cell and represents a scatterplot. Depending on the assignment of rows, columns and colors in the Tercen projection, the layout will be different.

#### References

https://en.wikipedia.org/wiki/Scatter_plot
