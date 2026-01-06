import pandas as pd
import os

# This file goes through the HTML code of the NFL injury reports page and parses it
#   into a usable .csv that can be merged with other .csv's to make a SQL Database.

input_file = '/Users/matthewhartstein/Downloads/bye_weeks.csv'
output_csv = "/Users/matthewhartstein/PyCharmMiscProject/data/bye_weeks_long.csv"

df = pd.read_csv(input_file)
df.columns = df.columns.str.strip()

team_col = df.columns[0]
year_cols = df.columns[1:]

long_df = df.melt(
    id_vars=[team_col],
    value_vars=year_cols,
    var_name="season_year",
    value_name="bye_week"
)

long_df = long_df.rename(columns={team_col: "team"})
long_df = long_df.dropna(subset=["bye_week"])
long_df["season_year"] = pd.to_numeric(long_df["season_year"], errors="coerce")
long_df["bye_week"] = pd.to_numeric(long_df["bye_week"], errors="coerce")
long_df = long_df.dropna(subset=["season_year", "bye_week"])
long_df["season_year"] = long_df["season_year"].astype(int)
long_df["bye_week"] = long_df["bye_week"].astype(int)

os.makedirs(os.path.dirname(output_csv), exist_ok=True)
long_df.to_csv(output_csv, index=False)

print(f"✅ Saved {len(long_df)} rows to {output_csv}")
print(long_df.head())
