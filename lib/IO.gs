class IOHandler {
    //READ CHARACTER 
    public char readChar() {
        char c[1];
        sys_read(0, c, 1);;  // fd = 0 for stdin
        char ans;
        ans=c[0];
        return ans;
    }

    //WRITE CHARACTER
    public void writeChar(char c) {
        char arr[1];
        arr[0] = c;
        sys_write(1, arr, 1);;  // fd = 1 for stdout
    }

    //READ STRING
    public void readString(char arr[], int size) {
        int i = 0;
        char c;
        while (i < size - 1) {
            c = readChar();
            if (c == '\n' || c == '\r') break;
            arr[i] = c;
            i++;
        }
        arr[i] = '\0';
    }

    //STRING → INT
    public int stringToInt(char arr[]) {
        int i = 0, num = 0, sign = 1;
        if (arr[0] == '-') {
            sign = -1;
            i++;
        }
        while (arr[i] != '\0') {
            if (arr[i] >= '0' && arr[i] <= '9') {
                num = num * 10 + (arr[i] - '0');
            } else break;
            i++;
        }
        return sign * num;
    }

    //INT → STRING
    public void intToString(int x, char arr[]) {
        int i = 0;
        int isNeg = 0;
        if (x == 0) {
            arr[i++] = '0';
            arr[i] = '\0';
            return;
        }
        if (x < 0) {
            isNeg = 1;
            x = -x;
        }

        while (x > 0) {
            arr[i++] = (x % 10) + '0';
            x /= 10;
        }
        if (isNeg==1) arr[i++] = '-';
        arr[i] = '\0';

        // Reverse array
        for (int j = 0; j < i / 2; j++) {
            char temp = arr[j];
            arr[j] = arr[i - j - 1];
            arr[i - j - 1] = temp;
        }
    }

    // DOUBLE → STRING
    public void doubleToString(double val, char arr[]) {
    int neg = 0;
    if (val < 0) {
        neg = 1;
        val = -val;
    }

    // Extract integer part manually
    int intPart = 0;
    double temp = val;
    while (temp >= 1.0) {
        temp = temp - 1.0;
        intPart = intPart + 1;
    }

    // Extract fractional part
    double frac = val - intPart;

    char intBuf[50];
    intToString(intPart, intBuf);

    int i = 0, j = 0;

    if (neg == 1) {
        arr[i++] = '-';
    }

    // Copy integer part
    while (intBuf[j] != '\0') {
        arr[i++] = intBuf[j++];
    }

    arr[i++] = '.';

    // Handle fractional part up to 6 decimal digits
    for (int k = 0; k < 6; k++) {
        frac = frac * 10.0;

        // Extract one digit manually (again no casting)
        int digit = 0;
        while (frac >= 1.0) {
            frac = frac - 1.0;
            digit = digit + 1;
        }

        arr[i++] = '0' + digit;
    }

    arr[i] = '\0';
}


    //READ INT
    public int readInt() {
        char buf[50];
        readString(buf, 50);
        return stringToInt(buf);
    }

    //PRINT STRING
    public void printString(char arr[]) {
        int i = 0;
        while (arr[i] != '\0') {
            writeChar(arr[i]);
            i++;
        }
    }

    //PRINT INT
    public void printInt(int x) {
        char buf[50];
        intToString(x, buf);
        printString(buf);
    }

    //PRINT DOUBLE
    public void printDouble(double x) {
        char buf[100];
        doubleToString(x, buf);
        printString(buf);
    }
};
