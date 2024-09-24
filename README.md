# Mục tiêu bài lab:
1. Hiểu rõ lỗ hổng buffer overflow là gì.
2. Tìm hiểu cách cấu hình môi trường chứa lỗ hổng trên Docker.
3. Tạo và khai thác một lỗi buffer overflow trên ứng dụng mẫu.
4. Cách bảo vệ hệ thống khỏi các cuộc tấn công buffer overflow.

# Bước 1: Chuẩn bị môi trường
Trước tiên, bạn cần cài đặt Docker trên hệ thống của mình. Nếu Docker chưa được cài đặt, bạn có thể làm theo các bước sau:

## Cài đặt Docker trên Ubuntu:
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce
sudo systemctl status docker
```
## Kiểm tra Docker:
```
docker --version
```
# Bước 2: Tạo ứng dụng có lỗ hổng Buffer Overflow
- Chúng ta sẽ tạo một ứng dụng C/C++ đơn giản có chứa lỗ hổng buffer overflow để thực hiện khai thác.

## Tạo Dockerfile:
- Tạo một thư mục làm việc cho lab và thêm file Dockerfile trong thư mục đó. Ví dụ:

```
mkdir buffer_overflow_lab
cd buffer_overflow_lab
```
Tạo file **Dockerfile** với nội dung sau:

```
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
```
## Tạo ứng dụng C với lỗ hổng buffer overflow:
Tạo file vulnerable.c với nội dung như sau:
```
#include <stdio.h>
#include <string.h>

void vulnerable_function(char *input) {
    char buffer[64];
    strcpy(buffer, input); // Lỗi buffer overflow
    printf("Input: %s\n", buffer);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <input>\n", argv[0]);
        return 1;
    }
    vulnerable_function(argv[1]);
    return 0;
}
```
Lưu file **vulnerable.c** trong cùng thư mục với **Dockerfile**.

# Bước 3: Build và chạy Docker container
## Build Docker image:
```
docker build -t buffer_overflow_lab .
```
## Chạy container:
```
docker run -it buffer_overflow_lab
```
Lúc này, bạn sẽ thấy ứng dụng **vulnerable** chạy bên trong **container** Docker. Ứng dụng này đang chờ bạn nhập chuỗi ký tự.


# Bước 4: Khai thác lỗi Buffer Overflow
Lỗi buffer overflow xảy ra khi bạn truyền vào một chuỗi quá dài, vượt quá kích thước của bộ nhớ đệm (buffer) mà chương trình có thể xử lý. Điều này có thể dẫn đến việc ghi đè các vùng bộ nhớ nhạy cảm, bao gồm cả địa chỉ trả về (return address), và có thể giúp hacker thực thi mã độc.

## Thử nghiệm chuỗi đầu vào:
Chạy lệnh sau trong Docker container để kiểm tra:
```
./vulnerable $(python3 -c 'print("A" * 80)')
```
Trong lệnh trên, chuỗi ký tự A được truyền vào có độ dài 80 ký tự, lớn hơn kích thước của buffer (64 bytes) trong mã nguồn. Khi đó, chương trình sẽ gặp lỗi buffer overflow.
## Quan sát kết quả:
Bạn sẽ thấy chương trình gặp lỗi hoặc có thể gây ra hành vi bất thường do bộ nhớ bị ghi đè. Trong một môi trường thật, bạn có thể khai thác lỗ hổng này để thực thi mã lệnh, tuy nhiên trong bài lab chúng ta chỉ quan sát lỗi để hiểu rõ cơ chế.
# Bước 5: Tạo một shellcode đơn giản
Bước tiếp theo là tạo một shellcode để thử và kiểm soát hành vi của chương trình. Tuy nhiên, phần này chỉ nên làm trong môi trường thí nghiệm để đảm bảo an toàn.

Một ví dụ shellcode đơn giản bằng Python:
```
python3 -c 'print("\x90" * 20 + "\xcc" * 60)' > payload
```
Sau đó chạy chương trình với **payload**:
```
./vulnerable $(cat payload)
```
# Bước 6: Sử dụng GDB để gỡ lỗi chương trình
Để hiểu rõ hơn về buffer overflow, bạn có thể sử dụng GDB để gỡ lỗi chương trình. Trong Docker container, chạy lệnh sau để khởi động GDB:
```
gdb ./vulnerable
```
Các lệnh trong GDB như **run, break, info registers** sẽ giúp bạn quan sát tình trạng bộ nhớ và thanh ghi CPU khi chương trình bị lỗi.
# Bước 7: Bảo vệ khỏi Buffer Overflow

Sau khi đã hiểu cách khai thác buffer overflow, chúng ta cần tìm cách bảo vệ hệ thống khỏi lỗ hổng này.
## Bật các cơ chế bảo vệ trong Docker:
1. **Stack Protector:** Bật trình bảo vệ ngăn xếp khi biên dịch chương trình:

```
gcc -o vulnerable vulnerable.c -fstack-protector
```
2.** Address Space Layout Randomization (ASLR):** Docker và hệ điều hành có thể sử dụng ASLR để ngăn chặn buffer overflow bằng cách làm ngẫu nhiên vị trí bộ nhớ của chương trình.
# Bước 8: Tổng kết
Trong bài lab này, bạn đã học cách tạo một chương trình đơn giản có lỗ hổng buffer overflow và cách khai thác lỗ hổng đó trong môi trường Docker. Quan trọng hơn, bạn đã thấy được cách phòng tránh và bảo vệ ứng dụng khỏi các cuộc tấn công buffer overflow.

