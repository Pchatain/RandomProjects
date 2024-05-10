import torch


def main():
    a = torch.randn(100, 384)
    def model(f):
        mult = f.clone()[0]
        return f * mult
    ref = model(a)
    out1 = model(a[:2, :])
    out2 = model(a)
    new = torch.cat([out1, out2[2:]], dim=0)
    assert torch.allclose(ref, new)


if __name__ == "__main__":
    main()