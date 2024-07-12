import fire
import time

import matplotlib.pyplot as plt
import numpy as np
import matplotlib.image as mpimg

def plot(image_path, positions, driver, people, weights, name=""):
    car_image = mpimg.imread(image_path)
    if weights is None:
        weights = [1] * len(people)
    weights = [w / sum(weights) for w in weights]

    # Randomly assign seats
    people = list(np.random.choice(people, len(people), replace=False, p=weights))
    people = driver + people

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.imshow(car_image, extent=[-0.5, 2.5, -0.5, 3.5])

    for i, person in enumerate(people):
        col, row = positions[i]
        ax.text(col, row, person, ha='center', va='center', fontsize=6,
                bbox=dict(boxstyle="round,pad=0.3", edgecolor='black', facecolor='lightblue'))

    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 3.5)
    ax.axis('off')  # Hide axes

    day = time.strftime("%Y-%m-%d")
    hour = int(time.strftime("%H"))
    if hour < 12:
        hour = "AM"
    else:
        hour = "PM"
    file_name = f"seating_chart_{day}_{hour}" + name  + ".png"
    plt.savefig(file_name)

def van():
    print("Van")
    image_path = "van.png"

    driver = ["Chris"]
    front_seat_princesses = ["Henry", "Nick"]
    normal_people = ["Peter", "Pieter", "Clark", "Rielly", "Christian", "Evan"]
    back_seat_kings = ["Gus", "Hedge"]

    weights = [25] * 2 + [8] * len(normal_people) + [1] * 2
    probs = [w / sum(weights) for w in weights]
    for prob in probs:
        print(f"{prob:.2f}", end=", ")
    print()

    positions = [(0.4, 2.1), (1, 2.1), (1.5, 2.1),  # Front row
                (0.3, 1.35), (0.9, 1.35), (1.5, 1.35),  # Middle row
                (0.3, 0.75), (0.9, 0.75), (1.5, 0.75),  # Back row
                (0.6, 0), (1.4, 0)]  # Two seats in the trunk
    people = front_seat_princesses + normal_people + back_seat_kings
    plot(image_path, positions, driver, people, weights)

def cars():
    print("Cars")
    image_path = "car.png"

    driver = ["Chris"]
    # spares =  ["Gus", "Hedge"]
    all_people = ["Henry", "Nick"] + ["Peter", "Pieter", "Clark", "Rielly", "Christian", "Evan"]
    positions = [(0.4, 2.1), (1.5, 2.1),  # Front row
                (0.3, 1.35), (0.9, 1.35), (1.5, 1.35),  # Middle row
    ]
    i = 0
    while all_people:
        people_i = np.random.choice(all_people, min(4, len(all_people)), replace=False)
        if len(people_i) < 4:
            people_i = list(people_i) + [None] * (4 - len(people_i))
        plot(image_path, positions, driver, people_i, None, str(i))
        i += 1
        all_people = [p for p in all_people if p not in people_i]

def main(vehicle="van"):
    if vehicle == "van":
        van()
    elif vehicle == "cars":
        cars()
    else:
        raise ValueError(f"Invalid vehicle `{vehicle}`")

if __name__ == "__main__":
    fire.Fire(main)