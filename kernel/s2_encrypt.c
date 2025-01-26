#include <linux/kernel.h>
#include <linux/syscalls.h>
#include <linux/uaccess.h>
#include <linux/errno.h>

// Static function performing all tasks
static long do_s2_encrypt(char __user *input, int key) {
    char buffer[256];
    int ret, i;

    // Validate the key
    if (key < 1 || key > 5) {
        return -EINVAL;
    }

    // Copy input from user space to kernel space
    ret = strncpy_from_user(buffer, input, sizeof(buffer));
    if (ret < 0) {
        return -EFAULT;
    }

    // Encrypt the string by adding the key to each character
    for (i = 0; buffer[i] != '\0'; i++) {
        buffer[i] += key;
    }

    // Print the encrypted string to the kernel log
    printk(KERN_INFO "Encrypted string: %s\n", buffer);

    return 0;
}

// System call definition using SYSCALL_DEFINE2 that calls the static function
SYSCALL_DEFINE2(s2_encrypt, char __user *, input, int, key) {
    return do_s2_encrypt(input, key);
}

