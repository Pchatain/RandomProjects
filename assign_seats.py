import matplotlib.pyplot as plt
import numpy as np

# Names of people and seat positions
people = ['Person 1', 'Person 2', 'Person 3', 'Person 4', 'Person 5',
          'Person 6', 'Person 7', 'Person 8', 'Person 9', 'Person 10', 'Person 11']
seats = np.arange(1, 12)  # Assuming seat numbers are from 1 to 11

# Shuffle people list
np.random.shuffle(people)

# Create a bus diagram
fig, ax = plt.subplots(figsize=(10, 5))  # Customize the size as needed
for i, person in enumerate(people):
    row = i // 4  # Assuming 4 seats per row
    col = i % 4
    ax.text(col, row, person, ha='center', va='center', fontsize=12,
            bbox=dict(boxstyle="round,pad=0.3", edgecolor='black', facecolor='lightblue'))
    ax.add_patch(plt.Rectangle((col-0.5, row-0.5), 1, 1, edgecolor='black', facecolor='none'))

ax.set_xlim(-0.5, 3.5)
ax.set_ylim(-0.5, 2.5)
ax.axis('off')  # Hide axes
plt.show()
