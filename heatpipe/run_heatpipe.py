import numpy as np
import subprocess
from tqdm.auto import tqdm
import argparse

dis_center = 16
initial_x = 13.8564
initial_y = 8.0
coord = np.array(
    [
        [initial_x, initial_y],
        [initial_x + 1 * dis_center * 3**0.5, initial_y],
        [initial_x + 2 * dis_center * 3**0.5, initial_y],
        [initial_x + 3 * dis_center * 3**0.5, initial_y],
        [initial_x + 3**0.5 / 2 * dis_center, initial_y + dis_center * 1.5],
        [initial_x + 3**0.5 / 2 * dis_center + 1 * dis_center * 3**0.5, initial_y + dis_center * 1.5],
        [initial_x + 3**0.5 / 2 * dis_center + 2 * dis_center * 3**0.5, initial_y + dis_center * 1.5],
        [initial_x + 3**0.5 * dis_center + 0 * dis_center * 3**0.5, initial_y + dis_center * 3],
        [initial_x + 3**0.5 * dis_center + 1 * dis_center * 3**0.5, initial_y + dis_center * 3],
        [initial_x + dis_center * 3**0.5 * 1.5, initial_y + dis_center * 4.5],
        [initial_x + 3**0.5 / 2 * dis_center, initial_y + 1 / 2 * dis_center],
        [initial_x + 3**0.5 / 2 * dis_center + 1 * dis_center * 3**0.5, initial_y + 1 / 2 * dis_center],
        [initial_x + 3**0.5 / 2 * dis_center + 2 * dis_center * 3**0.5, initial_y + 1 / 2 * dis_center],
        [initial_x + 3**0.5 * dis_center, initial_y + 2 * dis_center],
        [initial_x + 3**0.5 * dis_center * 2, initial_y + 2 * dis_center],
        [initial_x + dis_center * 3**0.5 * 1.5, initial_y + dis_center * 3.5],
    ]
)
coord_x = np.array(
    [
        13.8564,
        27.7128064605510,
        41.569212921102036,
        55.42561938165305,
        69.28202584220406,
        83.1384323027550,
        96.99483876330612,
    ]
)
coord_y = np.array([8.0, 16, 32, 40, 56, 64])


def gen_flux(l_b, u_b):
    flux = []
    for i in range(len(coord)):
        flux.append(round(np.random.uniform(l_b, u_b) * 1e6, 0))
    flux_ = np.zeros((7, 6))
    for i in range(len(coord)):
        ind_x = np.argmin(np.abs(coord[i, 0] - coord_x))
        ind_y = np.argmin(np.abs(coord[i, 1] - coord_y))
        flux_[ind_x, ind_y] = flux[i]
    return flux_


def gen_flux1(l_b, u_b):
    flux = []
    for i in range(len(coord)):
        flux.append(round(np.random.uniform(l_b, u_b) * 1e6, 0))
    return flux


def replacement(Z):
    data = dict()
    for i in range(len(coord_y)):
        for j in range(len(coord_x)):
            data += "%.1f " % Z[j, i]
    return {"data": data}


def replacement_inp(flux):
    replace = dict()
    for i in range(len(flux)):
        key = "b" + str(i + 1)
        replace[key] = flux[i]
    return replace


def write_inp(base_file, out_file, replacements):
    #'./inpbase.txt' './neutroninp/phi.txt fluidT.txt fuelT.txt'
    with open(base_file, "r", encoding="utf-8") as base:
        template = base.read()
    src = template % replacements
    with open(out_file, "w", encoding="utf-8") as file:
        file.write(src)


def main(n, index=0, mpi=4):
    flux = []
    for i in tqdm(range(n), desc="calculate loop time step", total=n):
        l_b, u_b = 1, 5
        l_b, u_b = 760 * 1e-6, 850 * 1e-6
        Z = gen_flux1(l_b, u_b)
        flux.append(Z)
        replacements = replacement_inp(Z)
        write_inp("./represent_base.i", "./represent.i", replacements)
        command = ["mpiexec", "-n", str(mpi), "../workspace-opt", "-i", "represent.i"]
        # 执行命令
        result = subprocess.run(command, capture_output=True, text=True)
        # print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）

        outfile = "./output/represent_out_" + str(index) + "_" + str(i + 1) + ".e"
        command = ["mv", "./represent_out.e", outfile]
        result = subprocess.run(command, capture_output=True, text=True)
        print(result.stderr)  # 打印命令的错误输出（如果有）
    np.save("./output/flux_" + str(index) + ".npy", np.array(flux))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate data")
    parser.add_argument("--n", default="100", type=int, help="number of sample")
    parser.add_argument("--index", default="1", type=int, help="start index")
    parser.add_argument("--mpi", default="4", type=int, help="mpiexec")
    args = parser.parse_args()
    main(args.n, args.index, args.mpi)
