cmake_minimum_required(VERSION 3.13)
project(untitled ASM)

add_executable(chacha20 main.s file.s cpu.s fetch.s decode.s graphics.s handler.s)

target_link_options(chacha20 PRIVATE -nostartfiles -nostdlib)