import argparse
import subprocess
import numpy as np


def L2_norm(array):
    array = array.reshape(-1)
    norm = np.sum(array**2) ** 0.5
    return norm


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="outer couple")
    parser.add_argument("--n", default="20", type=int, help="number of outer couple")
    args = parser.parse_args()
    for i in range(args.n):
        command = ["python", "run_neu.py"]
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）
        command = ["python", "run_fuel.py"]
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）
        command = ["python", "run_fluid.py"]
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有
        if i > 0:
            neu_old = neu
            solid_old = solid
            fluid_old = fluid
        neu = np.load("./output/nft_phi.npy")
        solid = np.load("./output/nft_Tfuel.npy")
        fluid = np.load("./output/nft_Tfluid.npy")
        if i > 0:
            relative_loss_neu = L2_norm(neu_old - neu) / L2_norm(neu)
            relative_loss_solid = L2_norm(solid_old - solid) / L2_norm(solid)
            relative_loss_fluid = L2_norm(fluid_old - fluid) / L2_norm(fluid)
            print(
                "loss in iter " + str(i) + " of neu, solid and fluid: ",
                relative_loss_neu,
                relative_loss_solid,
                relative_loss_fluid,
            )
            if all(num < 1e-3 for num in [relative_loss_neu, relative_loss_solid, relative_loss_fluid]):
                print("converse in", i)
                break
    print("up to max iteratiopn")
