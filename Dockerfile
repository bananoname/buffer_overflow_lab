# Sử dụng image Ubuntu
FROM ubuntu:20.04

# Cài đặt các công cụ cần thiết
RUN apt update && apt install -y gcc gdb vim

# Tạo thư mục làm việc
WORKDIR /exploit

# Sao chép mã nguồn có lỗ hổng vào container
COPY vulnerable.c /exploit

# Biên dịch ứng dụng
RUN gcc -o vulnerable vulnerable.c -fno-stack-protector -z execstack

# Chạy ứng dụng khi container khởi động
CMD ["/exploit/vulnerable"]
