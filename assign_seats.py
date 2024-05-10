import matplotlib.pyplot as plt
import numpy as np
import matplotlib.image as mpimg

car_image = mpimg.imread('bus.png')

# Names of people and seat positions
people = ['Person 1', 'Person 2', 'Person 3', 'Person 4', 'Person 5',
          'Person 6', 'Person 7', 'Person 8', 'Person 9', 'Person 10', 'Person 11']
driver = ["Chris"]
front_seat_princesses = ["Henry", "Nick"]
normal_people = ["Peter", "Pieter", "Clark", "Rielly", "Christian", "Evan"]
back_seat_kings = ["Gus", "Alex"]
people = front_seat_princesses + normal_people + back_seat_kings
weights = [25] * 2 + [8] * len(normal_people) + [1] * 2
print(weights)
weights = [w / sum(weights) for w in weights]
seats = np.arange(1, 12)  # Assuming seat numbers are from 1 to 11

# Shuffle people list
people = list(np.random.choice(people, len(people), replace=False, p=weights))
people = driver + people
# Create a bus diagram
fig, ax = plt.subplots(figsize=(10, 5))  # Customize the size as needed
ax.imshow(car_image, extent=[-0.5, 2.5, -0.5, 3.5])  # Adjust 'extent' to scale image
# Positions for each seat, adjusting for different rows
positions = [(0.4, 2.1), (1, 2.1), (1.5, 2.1),  # Front row
             (0.3, 1.35), (1, 1.35), (1.5, 1.35),  # Middle row
             (0.3, 0.75), (1, 0.75), (1.5, 0.75),  # Back row
             (0.6, 0), (1.4, 0)]  # Two seats in the trunk

for i, person in enumerate(people):
    col, row = positions[i]
    ax.text(col, row, person, ha='center', va='center', fontsize=6,
            bbox=dict(boxstyle="round,pad=0.3", edgecolor='black', facecolor='lightblue'))

ax.set_xlim(-0.5, 2.5)
ax.set_ylim(-0.5, 3.5)
ax.axis('off')  # Hide axes
plt.show()
