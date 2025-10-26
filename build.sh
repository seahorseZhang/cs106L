#!/bin/sh

BUILD_TYPE="debug"  # 默认编译debug模式
SCRIPT_NAME=$(basename "$0")

usage() {
  echo "用法: $SCRIPT_NAME [-f 模式]"
  echo "  模式: debug (默认) 或 release"
  echo "  示例:"
  echo "    $SCRIPT_NAME          # 编译debug版本"
  echo "    $SCRIPT_NAME -f release  # 编译release版本"
  exit 1
}

# 解析命令行参数
while getopts "f:" opt; do
  case $opt in
    f)
      # 转换为小写，支持大小写不敏感输入
      BUILD_TYPE=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
      ;;
    \?)
      echo "错误: 无效选项 -$OPTARG" >&2
      usage
      ;;
    :)
      echo "错误: 选项 -$OPTARG 需要参数 (debug 或 release)" >&2
      usage
      ;;
  esac
done

# 校验模式合法性
if [ "$BUILD_TYPE" != "debug" ] && [ "$BUILD_TYPE" != "release" ]; then
  echo "错误: 模式必须是 'debug' 或 'release'，当前输入: $BUILD_TYPE" >&2
  exit 1
fi

# 定义构建目录（按模式分离，避免冲突）
BUILD_DIR="./build_$BUILD_TYPE"
CMAKE_LISTS_PATH="CMakeLists.txt"  # 假设CMakeLists.txt在脚本同级目录

# 检查CMakeLists.txt是否存在
if [ ! -f "$CMAKE_LISTS_PATH" ]; then
  echo "错误: 未找到 CMakeLists.txt，路径: $CMAKE_LISTS_PATH" >&2
  echo "请确保脚本与CMakeLists.txt在同一目录" >&2
  exit 1
fi

# 创建并进入构建目录
echo "==> 准备构建 $BUILD_TYPE 版本..."
mkdir -p "$BUILD_DIR" || {
  echo "错误: 无法创建构建目录 $BUILD_DIR" >&2
  exit 1
}
cd "$BUILD_DIR" || {
  echo "错误: 无法进入构建目录 $BUILD_DIR" >&2
  exit 1
}

CMAKE_BUILD_TYPE=$(echo "$BUILD_TYPE" | tr '[:lower:]' '[:upper:]')
echo "==> 正在运行 CMake 配置 ($CMAKE_BUILD_TYPE)..."
cmake -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" .. || {
  echo "错误: CMake 配置失败" >&2
  exit 1
}

CPU_CORES=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 4)
echo "==> 正在编译（使用 $CPU_CORES 线程）..."
make -j"$CPU_CORES" || {
  echo "错误: 编译过程失败" >&2
  exit 1
}

# 检查编译产物是否存在（假设可执行文件名为main，根据实际情况修改）
EXECUTABLE="./main"
if [ -f "$EXECUTABLE" ]; then
  echo "==> 成功！$BUILD_TYPE 版本编译完成:"
  echo "    可执行文件: $EXECUTABLE"
else
  echo "警告: 编译完成，但未找到可执行文件 $EXECUTABLE" >&2
  echo "请检查CMakeLists.txt中的add_executable配置" >&2
  exit 1
fi