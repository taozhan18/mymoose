import argparse
import subprocess

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="outer couple")
    parser.add_argument("--n", default="20", type=int, help="number of outer couple")
    args = parser.parse_args()
    for i in range(args.n):
        command = ["python", "run_neu.py", "--n", " 1"]
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        # print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）
        command = ["python", "run_fuel.py", "--n", " 1"]
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        # print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）
        command = ["python", "run_fluid.py", "--n", " 1"]
        result = subprocess.run(command, capture_output=True, text=True)
        # 打印标准输出和错误输出
        # print(result.stdout)  # 打印命令的标准输出
        print(result.stderr)  # 打印命令的错误输出（如果有）
