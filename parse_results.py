import tabulate

def main():
    file_path = "results.txt"

    with open(file_path, "r") as file:
        lines = file.readlines()
    # example line: model_path = 'w2v_slim_finetune_ack1_causal_mask-2024-03-19-13-37' ; dataset_name = 'epic_ello_valid' ; per = 17.17855283706403
    rows = []
    seen_models = set()
    model_map = {}
    for line in lines[1:]:
        results = line.strip().split(" ; ")
        if len(results) != 3:
            continue
        model_path = results[0].split(" = ")[1].strip("'")
        seen_models.add(model_path)
        model_name = f"Model_{len(seen_models)}"
        model_map[model_name] = model_path
        dataset_name = results[1].split(" = ")[1].strip("'")
        per = float(results[2].split(" = ")[1])
        # table[dataset_name] = table.get(dataset_name, []) + [(model_name, per)]
        row_entry = {}
        row_entry["dataset"] = dataset_name
        row_entry["model"] = model_name
        row_entry["per"] = per
        rows.append(row_entry)

    table_1 = []
    table_2 = []
    for model_idx in range(len(seen_models)):
        model = f"Model_{model_idx + 1}"
        print(f"{model} = {model_map[model]}")
        model_rows = [row for row in rows if row["model"] == model]
        dataset_names = [row["dataset"] for row in model_rows]
        per_values = [row["per"] for row in model_rows]
        table_1.append([model] + per_values)
        table_2.append(per_values)
    print(tabulate.tabulate(table_1, headers=["Dataset"] + dataset_names, tablefmt="simple"))
    # make table to print results separated by csv.
    print(tabulate.tabulate(table_2, headers=["Dataset"] + dataset_names, tablefmt="csv"))
if __name__ == "__main__":
    main()
    
