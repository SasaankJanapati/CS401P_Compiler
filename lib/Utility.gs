class Utility {
public
    // Swap for int
    void swap(int a, int b) {
        int temp = a;
        a = b;
        b = temp;
    }

    // Swap for float
    public void swap(float a, float b) {
        float temp = a;
        a = b;
        b = temp;
    }

    // Swap for char
    public void swap2(char a, char b) {
        char temp = a;
        a = b;
        b = temp;
    }
};


class Algorithms {

   public Utility util;

    // Insertion 
  public void insert(int arr[10000], int n, int pos, int value) {
        if (pos < 0 || pos > n) return;

         int i = n;
while (i > pos) {
    arr[i] = arr[i - 1];
    i = i - 1;
}


        //for (int i = n; i > pos; i=i-1) {
       //     arr[i] = arr[i - 1];
     //}
        arr[pos] = value;
        n++;
    }

    // Sort
   // public void sort(int arr[10000], int n) {
       // for (int i = 0; i < n - 1; i++) {
           // for (int j = 0; j < n - i - 1; j++) {
              //  if (arr[j] > arr[j + 1]) {
            //        util.swap(arr[j], arr[j + 1]);
          //      }
        //    }
      //  }
    //}
public void sort(int arr[10000], int n) {
    int i = 0;
    while (i < n - 1) {
        int j = 0;
        while (j < n - i - 1) {
            if (arr[j] > arr[j + 1]) {
                util.swap(arr[j], arr[j + 1]);
            }
            j = j + 1;
        }
        i = i + 1;
    }
}


    // Reverse 
public void reverse(int arr[10000], int n) {
    int start = 0;
    int end = n - 1;
    while (start < end) {
        util.swap(arr[start], arr[end]);
        start = start + 1;
        end = end - 1;
    }
}

    //public void reverse(int arr[10000], int n) {
        //int start = 0, end = n - 1;
        //while (start < end) {
           // util.swap(arr[start], arr[end]);
         //   start++;
       //     end--;
     //   }
    //}
};
