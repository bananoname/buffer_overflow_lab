
# Buffer Overflow Exploitation Lab in Docker

## Objective:
1. Understand what a buffer overflow vulnerability is.
2. Set up a vulnerable environment in Docker.
3. Create and exploit a buffer overflow in a sample application.
4. Learn how to protect the system from buffer overflow attacks.

---

## Step 1: Prepare the Environment

Ensure Docker is installed. If not, follow these steps to install Docker on Ubuntu:

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce
sudo systemctl status docker
```

Check Docker installation:

```bash
docker --version
```

## Step 2: Create a Buffer Overflow Vulnerable Application

### Dockerfile:
Create a working directory for the lab and add a `Dockerfile`.

```bash
mkdir buffer_overflow_lab
cd buffer_overflow_lab
```

Add this content to `Dockerfile`:

```Dockerfile
# Use Ubuntu image
FROM ubuntu:20.04

# Install necessary tools
RUN apt update && apt install -y gcc gdb vim

# Create working directory
WORKDIR /exploit

# Copy vulnerable source code into container
COPY vulnerable.c /exploit

# Compile the application
RUN gcc -o vulnerable vulnerable.c -fno-stack-protector -z execstack

# Run the application on container startup
CMD ["/exploit/vulnerable"]
```

### Vulnerable C Application:
Create a file named `vulnerable.c` with the following code:

```c
#include <stdio.h>
#include <string.h>

void vulnerable_function(char *input) {
    char buffer[64];
    strcpy(buffer, input); // Buffer overflow vulnerability
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

## Step 3: Build and Run the Docker Container

### Build Docker Image:
```bash
docker build -t buffer_overflow_lab .
```

### Run the Container:
```bash
docker run -it buffer_overflow_lab
```

The application `vulnerable` will run inside the Docker container. It will prompt you to input a string.

## Step 4: Exploiting the Buffer Overflow

Pass a long string as input to trigger the buffer overflow:

```bash
./vulnerable $(python3 -c 'print("A" * 80)')
```

The input string exceeds the 64-byte buffer, causing a buffer overflow.

## Step 5: Shellcode Payload

Create a simple payload:

```bash
python3 -c 'print("\x90" * 20 + "\xcc" * 60)' > payload
```

Run the vulnerable program with the generated payload:

```bash
./vulnerable $(cat payload)
```

## Step 6: Debugging with GDB

To understand buffer overflow better, use GDB:

```bash
gdb ./vulnerable
```

Use commands like `run`, `break`, and `info registers` to observe memory behavior when the program crashes.

## Step 7: Protecting Against Buffer Overflow

### Enable Stack Protection:

Recompile the program with stack protection:

```bash
gcc -o vulnerable vulnerable.c -fstack-protector
```

### Enable ASLR (Address Space Layout Randomization):

Ensure that Docker and the operating system use ASLR to make buffer overflow exploitation harder.

---

## Conclusion

In this lab, you learned how to create a vulnerable application, exploit buffer overflow, and how to mitigate such vulnerabilities using stack protection and ASLR.
