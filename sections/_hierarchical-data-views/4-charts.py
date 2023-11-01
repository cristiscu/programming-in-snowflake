# after "pip install plotly"
import plotly.graph_objects as go
import pandas as pd

# see https://plotly.com/python/treemaps/
def makeTreemap(labels, parents):

    data = go.Treemap(
        ids=labels,
        labels=labels,
        parents=parents,
        root_color="lightgrey")
    fig = go.Figure(data)
    return fig

# see https://plotly.com/python/icicle-charts/
def makeIcicle(labels, parents):

    data = go.Icicle(
        ids=labels,
        labels=labels,
        parents=parents,
        root_color="lightgrey")
    fig = go.Figure(data)
    return fig

# see https://plotly.com/python/sunburst-charts/
def makeSunburst(labels, parents):

    data = go.Sunburst(
        ids=labels,
        labels=labels,
        parents=parents,
        insidetextorientation='horizontal')
    fig = go.Figure(data)
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
    return fig


df = pd.read_csv("data/employee-manager.csv", header=0).convert_dtypes()
labels = df[df.columns[0]]
parents = df[df.columns[1]]

makeTreemap(labels, parents).show()
print('Generated Treemap chart')

makeIcicle(labels, parents).show()
print('Generated Icicle chart')

makeSunburst(labels, parents).show()
print('Generated Sunburst chart')

makeSankey(labels, parents).show()
print('Generated Sankey chart')
