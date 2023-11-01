# after "pip install plotly"
import plotly.graph_objects as go
import pandas as pd

# see https://plotly.com/python/treemaps/
def makeTreemap(ids, labels, parents):

    fig = go.Figure()
    fig.add_trace(go.Treemap(
        ids=ids,
        labels=labels,
        parents=parents,
        branchvalues="remainder",
        maxdepth=10,
        root_color="lightgrey"))

    fig.update_layout(margin = dict(t=10, l=10, r=10, b=10))
    return fig

# see https://plotly.com/python/icicle-charts/
def makeIcicle(ids, labels, parents):

    data = go.Icicle(
        ids=ids,
        labels=labels,
        parents=parents,
        root_color="lightgrey")
    fig = go.Figure(data)
    return fig

# see https://plotly.com/python/sunburst-charts/
def makeSunburst(ids, labels, parents):

    fig = go.Figure()
    fig.add_trace(go.Sunburst(
        ids=ids,
        labels=labels,
        parents=parents,
        branchvalues="remainder",
        domain=dict(column=1),
        maxdepth=10,
        insidetextorientation='horizontal'))

    fig.update_layout(margin = dict(t=10, l=10, r=10, b=10))
    return fig

# see https://plotly.com/python/sankey-diagram/
def makeSankey(ids, labels, parents):

    node = dict(
        pad=15,
        thickness=20,
        line=dict(color="black", width=0.5),
        label=labels,
        color="blue")
    link = dict(source=ids, target=parents, label=labels, value=list(range(1, len(ids))))
    data=[go.Sankey(node=node, link=link)]
    fig = go.Figure(data)

    fig.update_layout(font_size=10)
    return fig


df = pd.read_csv("data/employee-manager.csv", header=0).convert_dtypes()
ids = df[df.columns[2]]
labels = df[df.columns[0]]
parents = df[df.columns[3]]

makeTreemap(ids, labels, parents).show()
print('Generated Treemap chart')

makeIcicle(ids, labels, parents).show()
print('Generated Icicle chart')

makeSunburst(ids, labels, parents).show()
print('Generated Sunburst chart')

makeSankey(ids, labels, parents).show()
print('Generated Sankey chart')
