import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="outer couple")
    parser.add_argument("--n", default="20", type=int, help="number of outer couple")
    args = parser.parse_args()
    for i in range(args.n):
        command = ["mpiexec", "-n", "2", "../../workspace-opt", "-i", "neutron.i"]
        command = ["mpiexec", "-n", "1", "../../workspace-opt", "-i", "solid.i"]
        command = ["mpiexec", "-n", "1", "../../workspace-opt", "-i", "fluid.i"]
