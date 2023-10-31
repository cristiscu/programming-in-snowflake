# generates 1K rows client-side with fake but realistic test synthetic data
# run from a VSCode Terminal with "python faker-demo.py", after "pip install faker"

from faker import Faker
import pandas as pd

fake = Faker()
output = [{
        "name": fake.name(),
        "address": fake.address(),
        "city": fake.city(),
        "state": fake.state(),
        "email": fake.email()
    } for _ in range(1000)]
df = pd.DataFrame(output)
print(df)