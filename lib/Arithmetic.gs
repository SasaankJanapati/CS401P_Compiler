class Arithmetic {
public int abs(int x) {
    if(x<0){
        return -x;
    }
    return x;
        //return (x < 0) ? -x : x;
    }
    
    public float abs(float x) {
        //return (x < 0) ? -x : x;
        if(x<0){
        return -x;
    }
    return x;
    }
    public double abs(double x) {
        //return (x < 0) ? -x : x;
        if(x<0){
        return -x;
    }
    return x;
    }
    
    public float sqrt(float x) {
        if (x < 0) return -1;
        if (x == 0 || x == 1) return x;

        float guess = x;
        float eps = 0.0000000001;

        while (true) {
            float newGuess = 0.5 * (guess + x / guess);
            if (abs(newGuess - guess) < eps) break;
            guess = newGuess;
        }

        return guess;
    }

    public double sqrt(double x) {
        if (x < 0) return -1; 
        if (x == 0 || x == 1) return x;

        double guess = x;
        double eps = 0.0000000001; 
        while (true) {
            double newGuess = 0.5 * (guess + x / guess);
            if (abs(newGuess - guess) < eps) break;
            guess = newGuess;
        }
        return guess;
    }
    
    public float exp(float x) {
        float term = 1;
        float sum = 1;
        int n = 1;
        float eps = 0.0000000000001;

        while (abs(term) > eps) {
            term = term * x / n;
            sum = sum + term;
            n = n + 1;
        }

        return sum;
    }

    public double exp(double x) {
        double term = 1;   
        double sum = 1;  
        int n = 1;
        double eps =0.0000000000001;

        while (abs(term) > eps) {
            term *= x / n;  
            sum += term;
            n++;
        }
        return sum;
    }
    
    public float power(float base, int exponent) {
        if (exponent == 0) return 1;
        if (exponent < 0) return 1 / power(base, -exponent);

        float result = 1;
        while (exponent > 0) {
            if (exponent % 2 == 1) result = result * base;
            base = base * base;
            exponent = exponent / 2;
        }

        return result;
    }

    public double power(double base, int exp) {
        if (exp == 0) return 1;
        if (exp < 0) return 1.0 / power(base, -exp);

        double result = 1;
        while (exp > 0) {
            if (exp % 2 == 1) result *= base;
            base *= base;
            exp /= 2;
        }
        return result;
    }


    public int max(int a, int b) {
        if(a>b){
        return a;
    }
    return b;
        //return (a > b) ? a : b;
    }
    
     public float max(float a, float b) {
        //return (a > b) ? a : b;
        if(a>b){
        return a;
    }
    return b;
    }

    public double max(double a, double b) {
        //return (a > b) ? a : b;
        if(a>b){
        return a;
    }
    return b;
    }

    public int min(int a, int b) {
        //return (a < b) ? a : b;
        if(a<b){
        return a;
    }
    return b;
    }
    
     public float min(float a, float b) {
        //return (a < b) ? a : b;
        if(a<b){
        return a;
    }
    return b;
    }
    
    public double min(double a, double b) {
        //return (a < b) ? a : b;
        if(a>b){
        return a;
    }
    return b;
    }
};

