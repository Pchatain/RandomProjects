import fire
import time

import matplotlib.pyplot as plt
import numpy as np
import matplotlib.image as mpimg
import tabulate

STATS = False

def plot(image_path, positions, driver, people, weights, name=""):
    car_image = mpimg.imread(image_path)
    if weights is None:
        weights = [1] * len(people)
    weights = [w / sum(weights) for w in weights]

    # Randomly assign seats
    people = list(np.random.choice(people, len(people), replace=False, p=weights))
    people = driver + people
    if STATS:
        return people
    print(name)
    for i in range(len(people)):
        print(f"{i}={people[i]}", end=", ")
        if i % 3 == 2:
            print()
        

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
    file_name = f"{day}_{hour}" + name  + ".png"
    ax.set_title(f"Seating Chart {day} {hour}{name}")
    plt.savefig(file_name)

def van(name=""):
    if not STATS: print("Van")
    image_path = "van.png"

    driver = ["Chris"]
    front_seat_princesses, fsp_w = ["Henry", "Nick"], 8
    normal_people, np_w = ["PeterC", "Pieter", "Clark", "Rielly", "Christian", "Evan"], 8
    back_seat_kings, bsk_w = ["Gus", "Hedge"], 1

    weights = [fsp_w] * len(front_seat_princesses) + [np_w] * len(normal_people) + [bsk_w] * len(back_seat_kings)
    probs = [w / sum(weights) for w in weights]
    if not STATS:
        for prob in probs:
            print(f"{prob:.2f}", end=", ")
        print()

    positions = [(0.4, 2.1), (1, 2.1), (1.5, 2.1),  # Front row
                (0.3, 1.35), (0.9, 1.35), (1.5, 1.35),  # Middle row
                (0.3, 0.75), (0.9, 0.75), (1.5, 0.75),  # Back row
                (0.6, 0), (1.4, 0)]  # Two seats in the trunk
    people = front_seat_princesses + normal_people + back_seat_kings
    return plot(image_path, positions, driver, people, weights, name=name)

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
        van(name="_from_hotel")
        van(name="_from_boathouse")
    elif vehicle == "cars":
        cars()
    else:
        raise ValueError(f"Invalid vehicle `{vehicle}`")
    
def stats():
    n_trials = 10000
    trial1 = van()
    ppl_map = {}
    for person in trial1:
        ppl_map[person] = {}
        for i in range(len(trial1)):
            ppl_map[person][i] = 0

    for i in range(n_trials):
        trial_i = van()
        for j, person in enumerate(trial_i):
            ppl_map[person][j] += 1
    for person in trial1:
        for i in range(len(trial1)):
            ppl_map[person][i] = ppl_map[person][i] * 100 / n_trials
    # for person in ppl_map:
        # print(f"{person}: {([ppl_map[person][k] for k in range(len(trial1))])}")
    # Prepare data for tabulate
    headers = ['Seat'] + trial1
    table_data = []
    for i in range(len(trial1)):
        row = [i] + [f"{ppl_map[person][i]:.2f}%" for person in trial1]
        table_data.append(row)

    # Print the table
    table = tabulate.tabulate(table_data, headers=headers, tablefmt='grid')
    print(table)
    
    # chris: [100%, 0, 0, 0,...,0]
    # clark: [15%, 13%, 17%, ..., 5%]
    # ...
if __name__ == "__main__":
    if STATS:
        stats()
    else:
        fire.Fire(main)