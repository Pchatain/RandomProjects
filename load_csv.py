import pandas as pd
import fire

def main(path):
    df = pd.read_csv(path)
    print(df.head())
    
if __name__ == "__main__":
    fire.Fire(main)