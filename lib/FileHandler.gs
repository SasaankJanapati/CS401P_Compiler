//define O_RDONLY  0   // open for reading olyy
//define O_WRONLY  1   // open for writing only
//define O_RDWR    2   // open for reading and writing
//define O_CREAT   64  // create file if it does not exist
//define O_TRUNC   512 // truncate file if it exists
//define O_APPEND  1024 // append mode
class FileHandler {

    private int fd;         // file descriptor
    private int isOpen;    // flag to check if file is open

   public FileHandler() {
        fd = -1;
        isOpen = 0;
    };

    public int fopen(char filename[10000], int mode) {
        int flags = 0;

        if (mode == 0){       flags = 0; }                   // read
        else if (mode == 1){  flags = 577;} // write (create/truncate)
        else if (mode == 2){  flags = 1089;} // append

        fd = sys_open(filename, flags);; // using syscall
        if (fd < 0) {
            isOpen = 0;
            return -1; // error
        }

        isOpen = 1;
        return 0; // success
    }

    public void fclose() {
        if (isOpen==1) {
            sys_close(fd);;
            fd = -1;
            isOpen = 0;
        }
    }

    public int fread(char buffer[10000], int size) {
        if (isOpen==0){ return -1;}
        int bytesRead = sys_read(fd, buffer, size);;
        return bytesRead;
    }


    public int fwrite(char buffer[10000], int size) {
        if (isOpen==0){ return -1;}
        int bytesWritten = sys_write(fd, buffer, size);;
        return bytesWritten;
    }


    public int is_open() {
        return isOpen;
    }
};
