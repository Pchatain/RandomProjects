import fire

def main(arg1):
    print(arg1)
    for i in arg1:
        print(i)

if __name__ == "__main__":
    fire.Fire(main)