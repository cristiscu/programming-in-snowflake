import pandas as pd
import plotly.graph_objects as go

# see https://plotly.com/python/treemaps/
def makeTreemap(labels, parents):

    data = go.Treemap(
        ids=labels,
        labels=labels,
        parents=parents,
        root_color="lightgrey")
    fig = go.Figure(data)
    #fig.write_html(utils.getFullPath('charts/treemap.html'))
    return fig

# see https://plotly.com/python/icicle-charts/
def makeIcicle(labels, parents):

    data = go.Icicle(
        ids=labels,
        labels=labels,
        parents=parents,
        root_color="lightgrey")
    fig = go.Figure(data)
    #fig.write_html(utils.getFullPath('charts/icicle.html'))
    return fig

# see https://plotly.com/python/sunburst-charts/
def makeSunburst(labels, parents):

    data = go.Sunburst(
        ids=labels,
        labels=labels,
        parents=parents,
        insidetextorientation='horizontal')
    fig = go.Figure(data)
    #fig.write_html(utils.getFullPath('charts/sunburst.html'))
    return fig

# see https://plotly.com/python/sankey-diagram/
def makeSankey(labels, parents):

    data = go.Sankey(
        node=dict(label=labels),
        link=dict(
            source=[list(labels).index(x) for x in labels],
            target=[-1 if pd.isna(x) else list(labels).index(x) for x in parents],
            label=labels,
            value=list(range(1, len(labels)))))
    fig = go.Figure(data)
    #fig.write_html(utils.getFullPath('charts/sankey.html'))
    return fig
