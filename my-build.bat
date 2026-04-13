@echo off
title AIMake - llama.cpp和sd.cpp的Windows编译工具

llvm-objdump -v >nul 2>nul
if %ERRORLEVEL% neq 0 (
	echo llvm-mingw 未找到 请配置环境变量
	pause &exit
)

set LLAMA_CPP_DIR=E:\src\llama.cpp
set SD_CPP_DIR=E:\src\stable-diffusion.cpp
:: CPU后端必须根据你自己的CPU选择, 否则AVX指令集不兼容无法运行
:: 如果不懂CPU配什么，问 AI 或写 ggml-cpu-x64
:: alderlake 是 Intel 12/13/14 代处理器
:: 只有 METAL VULKAN OPENCL 后端才需要换 SD_USE_CUDA 宏为对应名称
:: 很明显, batch 脚本只能在 Windows 上运行, Sycl 需要很多 CMake 配置我没 port
:: 需要 Webp 支持可以加 -DSD_USE_WEBP
set SD_CPP_LINK_ARG=-lggml-cpu-alderlake -lggml-cuda -DSD_USE_CUDA
set BIN_DIR=E:\AI\bin
set HEADER_DIR=E:\AI\bin\include
set LIB_DIR=E:\AI\bin\libs
set PROGRAM_DIR=%~dp0
set CLANG_ARG=-Wl,-s,--no-insert-timestamp -lstdc++ -flto=full -O3 -DLLAMA_SHARED -DLLAMA_BUILD -I"%HEADER_DIR%" -L"%LIB_DIR%"

echo 请确认：7
echo.
echo Llama.cpp源码目录：%LLAMA_CPP_DIR%
echo Stable-diffusion.cpp源码目录：%SD_CPP_DIR%
echo GGML二进制目录：%BIN_DIR%
echo 头文件目录：%HEADER_DIR%
echo 链接库目录：%LIB_DIR%
echo AIMake目录(应以\结尾)：%PROGRAM_DIR%
echo.

pause
cd /d %BIN_DIR%
cls

:main
title AIMake - llama.cpp和sd.cpp的Windows编译工具

echo ========================================================
echo   AIMake - llama.cpp和sd.cpp的Windows编译工具
echo ========================================================
echo   [1] 更新头文件与导出库 (.h / .a)
echo   [2] 编译 llama.dll
echo   [3] 编译 llama-common.o (静态/通用组件)
echo   [4] 编译 mtmd.dll
echo   [5] 编译 llama 工具 (cli, server, imatrix...)
echo   [6] 编译 stable-diffusion.dll
echo   [7] 编译 sd 工具
echo   [0] 退出
echo --------------------------------------------------------
set /p opt="请选择操作: "

if "%opt%"=="0" exit /b
goto step%opt%
cls
echo 输入无效.
goto main

:step1
del /f /s /q "%HEADER_DIR%\gguf.h" "%HEADER_DIR%\ggml*.h" "%HEADER_DIR%\llama*.h" "%HEADER_DIR%\mtmd*.h" >nul
copy "%LLAMA_CPP_DIR%\ggml\include\*.h" "%HEADER_DIR%" /y >nul
copy "%LLAMA_CPP_DIR%\include\*.h" "%HEADER_DIR%" /y >nul
copy "%LLAMA_CPP_DIR%\tools\mtmd\*.h" "%HEADER_DIR%" /y >nul

pushd "%LIB_DIR%"

del /f /s /q "libggml*.a" "libllama.a" "libmtmd.a" >nul

setlocal enabledelayedexpansion

for %%F in (
    "%BIN_DIR%\ggml*.dll"
    "%BIN_DIR%\llama.dll"
    "%BIN_DIR%\mtmd.dll"
) do (
    if exist "%%F" (
        gendef "%%F"
        set "dll=%%~nF"
        dlltool -d !dll!.def -l lib!dll!.a -D !dll!.dll
    )
)

endlocal

del /f /s /q "*.def" >nul

popd

goto done

:step2
clang -I"%LLAMA_CPP_DIR%\src" "%PROGRAM_DIR%_llama.cpp" -I"%LLAMA_CPP_DIR%\ggml\src" -lggml-base -lggml -DLLAMA_SHARED -o %BIN_DIR%\llama.dll -shared %CLANG_ARG%

if %ERRORLEVEL% neq 0 (
	title 编译失败
	echo 编译失败 请确认你有应用联合编译所需的补丁
	echo.
	pause
	cls
	goto main
)

goto done

:step3
pushd "%LLAMA_CPP_DIR%"
call :proc_git
if "%GIT_REV%"=="" (
    set "GIT_REV=unknown"
)
popd

pushd "%LIB_DIR%"

clang -I"%LLAMA_CPP_DIR%\common" -I"%LLAMA_CPP_DIR%\vendor" "%PROGRAM_DIR%_common.cpp" -c -D_WIN32_WINNT=0xA00 -ffunction-sections -fdata-sections -flto=full -o "llama-common.o" -DLLAMA_COMMON_BUILD_COMMIT=\"%GIT_REV%\" %CLANG_ARG%

popd

if %ERRORLEVEL% neq 0 (
	title 编译失败
	echo 编译失败 请确认你有应用联合编译所需的补丁
	echo.
	pause
	cls
	goto main
)

goto done

:step4
clang -I"%LLAMA_CPP_DIR%\tools\mtmd" -I"%LLAMA_CPP_DIR%\vendor" "%PROGRAM_DIR%_mtmd.cpp" -lllama -lggml -lggml-base -o %BIN_DIR%\mtmd.dll -shared %CLANG_ARG%

if %ERRORLEVEL% neq 0 (
	title 编译失败
	echo 编译失败 请确认你有应用联合编译所需的补丁
	echo.
	pause
	cls
	goto main
)

goto done

:step5
set ARGS= -I"%LLAMA_CPP_DIR%\common" -I"%LLAMA_CPP_DIR%\vendor" -lmtmd -lggml-base -lggml -lllama -lws2_32 "%LIB_DIR%\llama-common.o" -I"%LLAMA_CPP_DIR%\tools"

start /b "cli" clang "%PROGRAM_DIR%_cli.cpp" -I"%LLAMA_CPP_DIR%\tools\server" %ARGS% -o llama-cli.exe %CLANG_ARG%
start /b "perplexity" clang "%LLAMA_CPP_DIR%\tools\perplexity\perplexity.cpp" %ARGS% -o llama-perplexity.exe %CLANG_ARG%
start /b "imatrix" clang "%LLAMA_CPP_DIR%\tools\imatrix\imatrix.cpp" %ARGS% -o llama-imatrix.exe %CLANG_ARG%
start /b "bench" clang "%LLAMA_CPP_DIR%\tools\llama-bench\llama-bench.cpp" %ARGS% -o llama-bench.exe %CLANG_ARG%
start /b "quantize" clang "%LLAMA_CPP_DIR%\tools\quantize\quantize.cpp" %ARGS% -o llama-quantize.exe %CLANG_ARG%
clang "%PROGRAM_DIR%_server.cpp" %ARGS% -D_WIN32_WINNT=0xA00 -o llama-server.exe %CLANG_ARG%

if %ERRORLEVEL% neq 0 (
	title 编译失败
	echo 编译失败 请确认你有应用联合编译所需的补丁
	echo.
	pause
)

cls
goto main

:step6
pushd "%SD_CPP_DIR%"
call :proc_git
if "%GIT_REV%"=="" (
    set "GIT_REV=unknown"
)
popd

clang -I"%SD_CPP_DIR%\thirdparty" -I"%SD_CPP_DIR%\include" -I"%SD_CPP_DIR%\src" -I"%SD_CPP_DIR%\src\vocab"" "%PROGRAM_DIR%_sd.cpp" --shared -DGGML_MAX_NAME=256 -lggml -lggml-base %SD_LINK_ARG% -DSD_BUILD_DLL -o stable-diffusion.dll %CLANG_ARG% -D"SDCPP_BUILD_COMMIT=%GIT_REV%" %SD_CPP_LINK_ARG%

if %ERRORLEVEL% neq 0 (
	title 编译失败
	echo 编译失败 请确认你有应用联合编译所需的补丁
	echo.
	pause
)

del /f /s /q "%HEADER_DIR%\stable-diffusion.h" >nul
copy "%SD_CPP_DIR%\include\*.h" "%HEADER_DIR%" /y >nul

pushd "%LIB_DIR%"

gendef "%BIN_DIR%\stable-diffusion.dll"
dlltool -d stable-diffusion.def -l libstable-diffusion.a -D stable-diffusion.dll

del /f /s /q "*.def" >nul

popd

cls
goto main

:step7
start /b "cli" clang -I"%SD_CPP_DIR%\thirdparty" -I"%SD_CPP_DIR%\include" -I"%SD_CPP_DIR%\examples"  "%PROGRAM_DIR%_sd_cli.cpp" -lstable-diffusion -o sd-cli.exe %CLANG_ARG%
clang -I"%SD_CPP_DIR%\thirdparty" -I"%SD_CPP_DIR%\include" -I"%SD_CPP_DIR%\examples" "%PROGRAM_DIR%_sd_server.cpp" -lstable-diffusion -DSD_SAFE_LORA -o sd-server.exe -D_WIN32_WINNT=0xA00 -lws2_32 %CLANG_ARG%

if %ERRORLEVEL% neq 0 (
	title 编译失败
	echo 编译失败 请确认你有应用联合编译所需的补丁
	echo.
	pause
)

cls
goto main

:done
echo.
echo 操作成功
timeout /t 1 >nul
cls
goto main

:get_git_rev
set "GIT_REV=unknown"
pushd "%~1"
for /f "tokens=*" %%i in ('git rev-parse --short HEAD 2^>nul') do set "GIT_REV=%%i"
popd
exit /b

:proc_git
setlocal enabledelayedexpansion

for /f "tokens=*" %%i in ('git describe --tags --abbrev^=7 --dirty^=+ --always') do set "GIT_ID=%%i"

:: 2. 逻辑处理：
:: Git describe 的格式通常是 [TAG]-[COUNT]-g[HASH][DIRTY]
:: 我们的目标是把最后两部分 (次数和哈希) 归为“后半部分”，其余归为“Tag”

set "TAG_PART="
set "REV_PART="

:: 将字符串按 "-" 分隔，并计算总段数
set "count=0"
for %%a in (%GIT_ID:-= %) do (
    set /a count+=1
)

:: 再次循环，根据位置分配内容
set "current=0"
for %%a in (%GIT_ID:-= %) do (
    set /a current+=1
    
    :: 最后两段 (提交次数 和 g+哈希) 属于后半部分
    set /a rev_threshold=%count% - 1
    
    if !current! LSS !rev_threshold! (
        if "!TAG_PART!"=="" (set "TAG_PART=%%a") else (set "TAG_PART=!TAG_PART!-%%a")
    ) else (
        if "!REV_PART!"=="" (set "REV_PART=%%a") else (set "REV_PART=!REV_PART!-%%a")
    )
)

endlocal & set "GIT_TAG=%TAG_PART%" & set "GIT_REV=%REV_PART%"
exit /b
