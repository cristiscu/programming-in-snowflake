# Hierarchical Data Viewer

Display your parent-child data pairs in a better manner.

* *Source tab*: in an editable data frame.
* *Hierarchy tab*: with children indented below their parents, and the full path to the root node.
* *Format tab*: with a different data format (JSON, XML, YAML, or JSON Path)
* *Graph tab*: graphical representation, with nodes and edges between any parent and child.

The app comes with a few employee-manager pairs, displayed by default. But you may pass your own table or view name returning similar child-parent pairs, with one single top root node with no parent. Assuming you installed the app with its default name, you must grant read-only access to your own data with:

**`GRANT USAGE on DATABASE db TO APPLICATION hierarchical_data_app;`**
**`GRANT USAGE on SCHEMA db.schema TO APPLICATION hierarchical_data_app;`**
**`GRANT SELECT on TABLE/VIEW db.schema.name TO APPLICATION hierarchical_data_app;`**
