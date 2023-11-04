import json

class QueryProfiler:

    # format long numbers as strings
    # see https://stackoverflow.com/questions/579310/formatting-long-numbers-as-strings
    def _human_format(self, num):
        num = float('{:.3g}'.format(num))
        magnitude = 0
        while abs(num) >= 1000: magnitude += 1; num /= 1000.0
        return '{}{}'.format(f'{num:f}'.rstrip('0').rstrip('.'), ['', 'K', 'M', 'B', 'T'][magnitude])

    # Query Profile graph
    def getQueryProfile(self, rows):

        lastNodeId, nodes, edges = None, "", ""
        for row in rows:
            nodeId = str(row["OPERATOR_ID"])
            step = str(row["OPERATOR_TYPE"])
            id = str(row["OPERATOR_ID"])

            exectime = json.loads(str(row["EXECUTION_TIME_BREAKDOWN"]))
            perc = float(exectime["overall_percentage"])

            stats = json.loads(str(row["OPERATOR_STATISTICS"]))
            rowsI = self._human_format(stats["input_rows"]) if 'input_rows' in stats else ""
            rowsO = self._human_format(stats["output_rows"]) if 'output_rows' in stats else ""
            rows = f'\\n({rowsI} \u2192 {rowsO} rows)'

            # add current node w/ label: Join [7] (3.6%) (23K --> 1M rows)
            nodes += f'\tn{nodeId} [label="{step} [{id}] ({perc:.0%}){rows}"];\n'

            # add edges from current node
            parent = row["PARENT_OPERATORS"]
            if parent is not None:
                parentIds = json.loads(parent)
                for parentId in parentIds:
                    edges += f'\tn{nodeId} -> n{parentId};\n'
            elif lastNodeId is not None:
                edges += f'\tn{nodeId} -> n{lastNodeId};\n'
            lastNodeId = nodeId

        graph = ('digraph {\n'
            + '\tgraph [rankdir="BT"]\n'
            + '\tnode [shape="rect"]\n\n'
            + f'{nodes}\n'
            + f'{edges}'
            + '}')
        return graph
