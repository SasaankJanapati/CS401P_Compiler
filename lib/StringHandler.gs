
class StringHandler {
    // length
   public int length(char str[10000]) {
        int len = 0;
        while (str[len] != '\0') {
            len++;
        }
        return len;
    }

    // substr
   public void substr(char str[10000], int start, int len, char res[10000]) {
        int n = length(str);
        if (start < 0 || start >= n) {
            res[0] = '\0'; // invalid start
            return;
        }
        int i;
        for (i = 0; i < len && (start + i) < n; i++) {
            res[i] = str[start + i];
        }
        res[i] = '\0';
    }


    // compare
   public int compare(char s1[10000], char s2[10000]) {
        int i = 0;
        while (s1[i] != '\0' && s2[i] != '\0') {
            if (s1[i] > s2[i]) {
                return 1;
            }
            else if(s1[i]<s2[i]){
                return -1;
            }                 
            i++;
        }
        return 0;
    }

    public void insert(char str[10000], int pos, char c) {
        int n = length(str);
        if (pos < 0) pos = 0;
        if (pos > n) pos = n;

        for (int i = n; i >= pos; i--) {
            str[i + 1] = str[i];
        }
        str[pos] = c;
    }

    //  erase
   public void erase(char str[10000], int pos, int len) {
        int n = length(str);
        if (pos < 0 || pos >= n) return;

        for (int i = pos; i + len < n; i++) {
            str[i] = str[i + len];
        }
        str[n - len] = '\0';
    }

    // islower
   public bool islower(char c) {
        return (c >= 'a' && c <= 'z');
    }

   // isupper
   public bool isupper(char c) {
        return (c >= 'A' && c <= 'Z');
    }

    // tolower
   public char tolower(char c) {
        if (isupper(c)==1) return c + ('a' - 'A');
        return c;
    }

    // toupper
   public char toupper(char c) {
        if (islower(c)==1) return c - ('a' - 'A');
        return c;
    }

    //isalpha
   public bool isalpha(char c) {
        return (islower(c)==1 || isupper(c)==1);
    }

    // isalnum
   public bool isalnum(char c) {
        return (isalpha(c)==1 || isnum(c)==1);
    }

    // isnum (check digit)
   public bool isnum(char c) {
        return (c >= '0' && c <= '9');
    }
};