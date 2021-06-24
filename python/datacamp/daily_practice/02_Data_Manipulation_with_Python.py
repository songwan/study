############### Transforming Data

# Print the head of the homelessness data
print(homelessness.head())

# Import pandas using the alias pd
import pandas as pd

# Print the values of homelessness
print(homelessness.values)

# Print the column index of homelessness
print(homelessness.columns)

# Print the row index of homelessness
print(homelessness.index)

# Sort homelessness by individual
homelessness_ind = homelessness.sort_values(by=['individuals'])

# Print the top few rows
print(homelessness_ind.head())

# Select the individuals column
individuals=homelessness[['individuals']]

# Print the head of the result

print(individuals.head())

# Filter for rows where individuals is greater than 10000
ind_gt_10k = homelessness[homelessness['individuals']>10000]

# See the result
print(ind_gt_10k)

# Subset for rows in South Atlantic or Mid-Atlantic regions
south_mid_atlantic=homelessness[homelessness['region'].isin(['South Atlantic','Mid-Atlantic'])]
print(south_mid_atlantic)

homelessness.region

# Add total col as sum of individuals and family_members
homelessness['total'] = homelessness['individuals'] + homelessness['family_members']

# Add p_individuals col as proportion of individuals
homelessness['p_individuals'] = homelessness['individuals'] / homelessness['total']

# See the result
print(homelessness)

############### Aggregating Data



############### Slicing and Indexing




############### Creating and Visualizing DataFrames