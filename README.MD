## 一个让编译在Windows上变得亲民的脚本

适合：
- 觉得MSVC在C盘拉屎的人
- 需要给llama.cpp/sd.cpp加功能，提PR或者跟进上游并且自己用的人

前置需求：
- 预编译的GGML二进制，可以从 llama.cpp 的 Release 下载
  - 其实也就是CUDA编译不了而已
- [LLVM-MinGW](https://github.com/mstorsjo/llvm-mingw)工具链，并配置环境变量

使用：
- 打开 my-build.bat 编辑其中的目录定义，然后运行即可
- 当然，你必须用我的 llama.cpp和sd.cpp 分支，反正你可以看到我修改了哪里
- 不定时更新，毕竟联合编译总是要跟进