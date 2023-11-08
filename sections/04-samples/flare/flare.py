# converts flare.json --> flare.csv - (child, parent) hierarchy
import json

with open("flare.json", "r") as f:
    j = json.loads(f.read())

set = set()
with open("flare.csv", "w") as f:
    f.write("child,parent\n")
    f.write("flare,\n")

    for obj in j:
        parts = obj["name"].split('.')
        for i in range(len(parts) - 1):
            key = f"{parts[i+1]},{parts[i]}\n"
            if key not in set:
                f.write(key)
                set.add(key)
