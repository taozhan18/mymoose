import numpy as np
from scipy.interpolate import make_interp_spline
import subprocess
import netCDF4 as nc
from tqdm.auto import tqdm
import argparse

T = np.load("./output/nft_Tfuel.npy")
flux = np.load("./output/nft_Tfuel.npy")[:, 1, 1:, -1]


def write_inp(base_file, out_file, replacements):
    #'./inpbase.txt' './neutroninp/phi.txt fluidT.txt fuelT.txt'
    with open(base_file, "r", encoding="utf-8") as base:
        template = base.read()
    src = template % replacements
    with open(out_file, "w", encoding="utf-8") as file:
        file.write(src)


def replacements(function, batch, Lx=0.0076, Ly=0.75, Lt=5, nx=8, ny=64, nt=32, bias_x=0, bias_y=0, bias_t=0, dim=2):
    # phi: Lx=0.0076, Ly=0.75, Lt=5, nx=8, ny=64, nt=32
    # Tfuel: Lx=0.0076, Ly=0.75, Lt=5, nx=8, ny=64, nt=32
    # Tfluid: Lx=0.0114, Ly=0.75, Lt=5, nx=12, ny=64, nt=32, bias_y = 0.0075
    dx = Lx / nx
    dy = Ly / ny
    dt = Lt / nt
    coor_x_str = ""
    coor_y_str = ""
    coor_t_str = ""
    data = ""
    for i in range(nx):
        coor_x_str = coor_x_str + " %.5f" % (dx * i + dx / 2 + bias_x)
    for i in range(ny):
        coor_y_str = coor_y_str + " %.5f" % (dy * i + dy / 2 + bias_y)
    for i in range(nt):
        coor_t_str = coor_t_str + "%.5f " % (dt * (i + 1) + bias_t)

    x_values = np.array(list(map(float, coor_x_str.split())))
    y_values = np.array(list(map(float, coor_y_str.split())))
    t_values = np.array(list(map(float, coor_t_str.split())))

    X, Y, T = np.meshgrid(x_values, y_values, t_values, indexing="ij")
    Z = function(batch)
    for i in range(nt):
        for j in range(len(y_values)):
            data += "%.1f " % Z[j, i]
    replacements = {"y_coor": coor_y_str, "t_coor": coor_t_str, "data": data}
    inputs = Z
    return replacements, inputs


def gen_flux(batch, *arg):
    return flux[batch].transpose(1, 0)


def gen_neu_inp(batch):
    replacements_flux, flux = replacements(
        function=gen_flux,
        batch=batch,
        Lx=0.0114,
        Ly=0.75,
        Lt=5,
        nx=12,
        ny=64,
        nt=32,
        bias_x=0,
        bias_y=0,
        bias_t=0,
        dim=1,
    )
    # replacements_D_fluid = replacements(function=gen_D_fluid, Lx=0.0076, Ly=0.75, Lt=5, nx=12, ny=64, nt=32, bias_x = 0, bias_y = 0, bias_t = 0)
    write_inp("./inp1D_base.txt", "./fluidinp/flux.txt", replacements_flux)
    inp_file = ["'./fluidinp/flux.txt'"]
    replacements_inp = {"flux_file": inp_file[0]}
    write_inp(base_file="./fluid_base.i", out_file="./fluid.i", replacements=replacements_inp)
    return flux


def read_e_to_np(file_path):
    def unique_within_tolerance(arr, tol):
        # 首先对数组进行排序
        sorted_arr = np.sort(arr)
        # 初始化一个空列表来存储唯一元素
        unique = [sorted_arr[0]]
        for i in range(1, len(sorted_arr)):
            # 如果当前元素与列表中最后一个元素的差的绝对值大于容忍度，则添加到列表中
            if np.abs(sorted_arr[i] - unique[-1]) > tol:
                unique.append(sorted_arr[i])
        # 将列表转换回NumPy数组
        return np.array(unique)

    dataset = nc.Dataset(file_path, "r")

    # 获取节点坐标
    x_coords = dataset.variables["coordx"][:]
    y_coords = dataset.variables["coordy"][:]
    if "coordz" in dataset.variables:
        z_coords = dataset.variables["coordz"][:]
    else:
        z_coords = [0.0] * len(x_coords)

    # 获取节点数
    num_nodes = len(x_coords)

    # 获取单元连接信息
    connectivity = dataset.variables["connect1"][:]
    blocks = dataset.variables["eb_names"][:]
    num_blocks = len(blocks)

    # 获取时间步
    time_steps = dataset.variables["time_whole"][:]
    num_time_steps = len(time_steps)
    T_fluid = np.array(dataset.variables["vals_elem_var1eb1"]).reshape(1, num_time_steps, 64, 12)
    pressure = np.array(dataset.variables["vals_elem_var2eb1"]).reshape(1, num_time_steps, 64, 12)
    vel_x = np.array(dataset.variables["vals_elem_var3eb1"]).reshape(1, num_time_steps, 64, 12)
    vel_y = np.array(dataset.variables["vals_elem_var4eb1"]).reshape(1, num_time_steps, 64, 12)

    unique_x = unique_within_tolerance(np.array(x_coords), 1e-6)
    unique_y = unique_within_tolerance(np.array(y_coords), 1e-3)

    # print("the shape is: ", num_time_steps, len(unique_x), len(unique_y))
    z_matrix = np.concatenate((T_fluid, pressure, vel_x, vel_y), axis=0).transpose(0, 1, 3, 2)
    return z_matrix


def main(n=2):
    # this file should be run in current file path
    flux_all = []
    outputs_all = []
    for i in tqdm(range(n), desc="calculate loop time step", total=n):
        flux = gen_neu_inp(i)
        # 构建命令
        command = ["mpiexec", "-n", "3", "../../../workspace-opt", "-i", "fluid.i"]
        # 执行命令
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        # print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）
        outputs = read_e_to_np("./fluid_out.e")
        flux_all.append(flux)
        outputs_all.append(outputs)
    np.save("./output/flux_to_fluid", np.array(flux_all))
    np.save("./output/nft_Tfluid", np.array(outputs_all))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate data")
    parser.add_argument("--n", default="2000", type=int, help="number of sample")
    args = parser.parse_args()
    main(args.n)
