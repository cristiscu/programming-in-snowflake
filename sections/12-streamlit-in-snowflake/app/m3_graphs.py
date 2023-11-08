import pandas as pd

# digraph with edges only
def getEdges(df, idx_label, idx_parent):
    
    edges = ""
    for _, row in df.iterrows():
        isRoot = pd.isna(row.iloc[idx_parent])
        if not isRoot:
            edges += f"\t{row.iloc[idx_label]} -> {row.iloc[idx_parent]};\n"
    
    return f"digraph {{\n{edges}}}\n"
