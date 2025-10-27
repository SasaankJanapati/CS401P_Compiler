// Helper IO functions (like from IOHandler)
void writeChar(char c) {
    char buf[1];
    buf[0] = c;
    sys_write(1, buf, 1);;   // stdout
}

void writeString(char arr[]) {
    int i = 0;
    while (arr[i] != '\0') {
        writeChar(arr[i]);
        i++;
    }
}

void intToString(int x, char arr[]) {
    int i = 0, neg = 0;
    if (x == 0) {
        arr[i++] = '0';
        arr[i] = '\0';
        return;
    }
    if (x < 0) {
        neg = 1;
        x = -x;
    }
    while (x > 0) {
        arr[i++] = (x % 10) + '0';
        x /= 10;
    }
    if (neg==1) arr[i++] = '-';
    arr[i] = '\0';
    // reverse
    for (int j = 0; j < i / 2; j++) {
        char tmp = arr[j];
        arr[j] = arr[i - j - 1];
        arr[i - j - 1] = tmp;
    }
}

void doubleToString(double val, char arr[]) {
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


// ==========================================================
// Vector for int
// ==========================================================
class VectorInt {
private
    int arr[1000];
    private  int vsize;

public
    VectorInt() {
        vsize = 0;
    };

public
    void push_back(int val) {
        if (vsize < 1000) {
            arr[vsize] = val;
            vsize++;
        }
    }

public
    void pop_back() {
        if (vsize > 0) vsize--;
    }

public
    int size() {
        return vsize;
    }

public
    int at(int index) {
        if (index < 0 || index >= vsize) return -1;
        return arr[index];
    }

public
    void set(int index, int val) {
        if (index < 0 || index >= vsize) return;
        arr[index] = val;
    }

public
    void clear() {
        vsize = 0;
    }

public
    bool empty() {
        return (vsize == 0);
    }

public
    void print() {
        int i;
        for (i = 0; i < vsize; i++) {
            char buf[50];
            intToString(arr[i], buf);
            writeString(buf);
            writeChar(' ');
        }
        writeChar('\n');
    }
};

// ==========================================================
// Vector for float
// ==========================================================
class VectorFloat {
private
    float arr[1000];
    private int vsize;

public
    VectorFloat() {
        vsize = 0;
    };

public
    void push_back(float val) {
        if (vsize < 1000) {
            arr[vsize] = val;
            vsize++;
        }
    }

public
    void pop_back() {
        if (vsize > 0) vsize--;
    }

public
    int size() {
        return vsize;
    }

public
    float at(int index) {
        if (index < 0 || index >= vsize) return -1.0;
        return arr[index];
    }

public
    void set(int index, float val) {
        if (index < 0 || index >= vsize) return;
        arr[index] = val;
    }

public
    void clear() {
        vsize = 0;
    }

public
    bool empty() {
        return (vsize == 0);
    }

public
    void print() {
        int i;
        for (i = 0; i < vsize; i++) {
            char buf[100];
            doubleToString(arr[i], buf);
            writeString(buf);
            writeChar(' ');
        }
        writeChar('\n');
    }
};

// ==========================================================
// Vector for char
// ==========================================================
class VectorChar {
private
    char arr[1000];
   private int vsize;

public
    VectorChar() {
        vsize = 0;
    };

public
    void push_back(char val) {
        if (vsize < 1000) {
            arr[vsize] = val;
            vsize++;
        }
    }

public
    void pop_back() {
        if (vsize > 0) vsize--;
    }

public
    int size() {
        return vsize;
    }

public
    char at(int index) {
        if (index < 0 || index >= vsize) return '\0';
        return arr[index];
    }

public
    void set(int index, char val) {
        if (index < 0 || index >= vsize) return;
        arr[index] = val;
    }

public
    void clear() {
        vsize = 0;
    }

public
    bool empty() {
        return (vsize == 0);
    }

public
    void print() {
        int i;
        for (i = 0; i < vsize; i++) {
            writeChar(arr[i]);
            writeChar(' ');
        }
        writeChar('\n');
    }
};
