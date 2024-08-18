import numpy as np
from scipy.interpolate import make_interp_spline
import subprocess
import netCDF4 as nc
from tqdm.auto import tqdm
import argparse

phi = np.load("./output/nft_phi.npy")
try:
    read_from_other_field = True
    T_fluid = np.load("./output/nft_Tfluid.npy")[:, 0, 1:, 0].transpose(0, 2, 1)  # b, 64, nt
except:
    read_from_other_field = False
    print("using constant fluid temperature")


def write_inp(base_file, out_file, replacements):
    #'./inpbase.txt' './solidinp/phi.txt fluidT.txt fuelT.txt'
    with open(base_file, "r", encoding="utf-8") as base:
        template = base.read()
    src = template % replacements
    with open(out_file, "w", encoding="utf-8") as file:
        file.write(src)


def replacements(function, batch, Lx=0.0076, Ly=0.75, Lt=5, nx=8, ny=64, nt=16, bias_x=0, bias_y=0, bias_t=0, dim=2):
    # phi: Lx=0.0076, Ly=0.75, Lt=5, nx=8, ny=64, nt=16
    # Tfuel: Lx=0.0076, Ly=0.75, Lt=5, nx=8, ny=64, nt=16
    # Tfluid: Lx=0.0114, Ly=0.75, Lt=5, nx=12, ny=64, nt=16, bias_y = 0.0075
    dx = Lx / nx
    dy = Ly / ny
    dt = Lt / nt
    coor_x_str = "%.5f" % bias_x
    coor_t_str = ""
    data = ""
    for i in range(nx):
        coor_x_str = coor_x_str + " %.5f" % (dx * (i + 1) + bias_x)
    if read_from_other_field == False or dim == 2:
        coor_y_str = "%.5f" % bias_y
        for i in range(ny):
            coor_y_str = coor_y_str + " %.5f" % (dy * (i + 1) + bias_y)
    else:
        coor_y_str = ""
        for i in range(ny):
            coor_y_str = coor_y_str + " %.5f" % (dy * i + dy / 2 + bias_y)
    for i in range(nt):
        coor_t_str = coor_t_str + "%.5f " % (dt * (i + 1) + bias_t)

    x_values = np.array(list(map(float, coor_x_str.split())))
    y_values = np.array(list(map(float, coor_y_str.split())))
    t_values = np.array(list(map(float, coor_t_str.split())))

    X, Y, T = np.meshgrid(x_values, y_values, t_values, indexing="ij")
    if dim == 2:
        Z = function(batch)
        # print(Z.shape, X.shape)
        for i in range(nt):
            for j in range(len(y_values)):
                for k in range(len(x_values)):
                    data += "%.1f " % Z[k, j, i]
        replacements = {"x_coor": coor_x_str, "y_coor": coor_y_str, "t_coor": coor_t_str, "data": data}
    else:
        Z = function(batch, X, Y, T)
        for i in range(nt):
            for j in range(len(y_values)):
                data += "%.1f " % Z[j, i]
        replacements = {"y_coor": coor_y_str, "t_coor": coor_t_str, "data": data}
    inputs = Z
    return replacements, inputs


def gen_power(i):
    phi_ = phi[i, 1:, :9].transpose(1, 2, 0)
    return phi_


def gen_Tf(batch, x, *arg):
    try:
        return T_fluid[batch]
    except:
        nx, ny, nt = x.shape
        cos_z = 200 * np.sin(np.linspace(0, 3.14, 80))[:65].reshape(65, 1)
        return np.ones((ny, nt)) * 560 + cos_z


def gen_neu_inp(batch):
    replacements_phi, phi = replacements(
        function=gen_power,
        batch=batch,
        Lx=0.0076,
        Ly=0.75,
        Lt=5,
        nx=8,
        ny=64,
        nt=16,
        bias_x=0,
        bias_y=0,
        bias_t=0,
        dim=2,
    )
    replacements_T_fluid, Tfluid = replacements(
        function=gen_Tf,
        batch=batch,
        Lx=0.0114,
        Ly=0.75,
        Lt=5,
        nx=12,
        ny=64,
        nt=16,
        bias_x=0.0076,
        bias_y=0,
        bias_t=0,
        dim=1,
    )
    write_inp("./inp1D_base.txt", "./solidinp/T_fluid.txt", replacements_T_fluid)
    write_inp("./inp_base.txt", "./solidinp/phi.txt", replacements_phi)
    inp_file = ["'solidinp/phi.txt'", "'solidinp/T_fluid.txt'"]
    replacements_inp = {"power_file": inp_file[0], "Ty_file": inp_file[1]}
    write_inp(base_file="./solid_base.i", out_file="./solid.i", replacements=replacements_inp)
    return phi, Tfluid


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
    u = dataset.variables["vals_nod_var1"]
    flux = np.array(dataset.variables["vals_elem_var1eb1"]).reshape(1, num_time_steps, 64, 8).transpose(0, 1, 3, 2)
    # flux1 = dataset.variables["vals_nod_var3"]

    unique_x = unique_within_tolerance(np.array(x_coords), 1e-6)
    unique_y = unique_within_tolerance(np.array(y_coords), 1e-3)

    time_steps = u.shape[0]
    # print("the shape is: ", time_steps, len(unique_x), len(unique_y))
    z_matrix = np.zeros((1, time_steps, len(unique_x), len(unique_y)))
    mask = np.zeros((len(unique_x), len(unique_y)))
    for i in range(len(x_coords)):
        x_index = np.argmin(np.abs(x_coords[i] - unique_x))
        y_index = np.argmin(np.abs(y_coords[i] - unique_y))
        mask[x_index, y_index] = 1
        z_matrix[0, :, x_index, y_index] = u[:, i]
        # z_matrix[1, :, x_index, y_index] = flux[:, i]
        # z_matrix[2, :, x_index, y_index] = flux1[:, i]
    z_matrix = (z_matrix[:, :, 1:, 1:] + z_matrix[:, :, :-1, :-1]) / 2
    assert np.mean(mask) == 1, "An element has not been assigned a value"
    return np.concatenate((z_matrix, flux), axis=0)


def main(n=1):
    # this file should be run in current file path

    phi_all = []
    Tfluid_all = []
    outputs_all = []
    for i in tqdm(range(n), desc="calculate loop time step", total=n):

        phi, Tfluid = gen_neu_inp(i)
        # 构建命令
        command = ["mpiexec", "-n", "1", "../../workspace-opt", "-i", "solid.i"]
        # 执行命令
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        # print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）
        outputs = read_e_to_np("./solid_exodus.e")
        phi_all.append(phi)
        Tfluid_all.append(Tfluid)
        outputs_all.append(outputs)
    phi_all = np.array(phi_all)
    Tfluid_all = np.array(Tfluid_all)
    outputs_all = np.array(outputs_all)
    print("T_fuel: ", outputs_all.shape)
    print("T_fluid: ", Tfluid_all.shape)
    print("phi_all: ", phi_all.shape)
    np.save("./output/n_to_fuel", np.array(phi_all))
    np.save("./output/fluid_to_fuel", np.array(Tfluid_all))
    np.save("./output/nft_Tfuel", np.array(outputs_all))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate data")
    parser.add_argument("--n", default="1", type=int, help="number of sample")
    args = parser.parse_args()
    main(args.n)
