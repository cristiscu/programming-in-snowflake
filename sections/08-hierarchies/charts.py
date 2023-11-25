import pandas as pd
import plotly.graph_objects as go
#import numpy as np
#import plotly.figure_factory as ff

# see https://plotly.com/python/treemaps/
def makeTreemap(labels, parents):

    data = go.Treemap(
        ids=labels,
        labels=labels,
        parents=parents,
        root_color="lightgrey")
    fig = go.Figure(data)
    fig.write_html(f'charts/treemap.html')
    return fig

# see https://plotly.com/python/icicle-charts/
def makeIcicle(labels, parents):

    data = go.Icicle(
        ids=labels,
        labels=labels,
        parents=parents,
        root_color="lightgrey")
    fig = go.Figure(data)
    fig.write_html(f'charts/icicle.html')
    return fig

# see https://plotly.com/python/sunburst-charts/
def makeSunburst(labels, parents):

    data = go.Sunburst(
        ids=labels,
        labels=labels,
        parents=parents,
        insidetextorientation='horizontal')
    fig = go.Figure(data)
    fig.write_html(f'charts/sunburst.html')
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
    fig.write_html(f'charts/sankey.html')
    return fig

"""
# see https://plotly.com/python/dendrogram/
# TODO: learn more
def makeDendrogram(labels, parents):

    fig = ff.create_dendrogram(
        X=np.random.rand(len(labels), len(labels)+2),
        labels=list(labels),
        orientation='left')
    fig.write_html(f'charts/dendrogram.html')
    return fig
"""

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

# makeDendrogram(labels, parents).show()
# print('Generated Dendrogram chart')
