// termios.gs — terminal control library (struct + raw mode)

class Termios {

    public int clflag;

    public Termios() {
        clflag = 0;
    };

    public void copyFrom(Termios src) {
        clflag = src.clflag;
    }
};


class TerminalHandler {
private
    Termios Eorigtermios;

public
    void disableRawMode() {
        tcsetattr(0, 2, Eorigtermios);  // STDINFILENO = 0, TCSAFLUSH = 2
    }

    public void enableRawMode() {
        tcgetattr(0, Eorigtermios);
        sys_write(1, "Raw mode enabled.\n", 18);;

        Termios raw;
        raw.copyFrom(Eorigtermios);
        raw.clflag = (raw.clflag / 4 )*4 ;  // simulate ECHO | ICANON
        tcsetattr(0, 2, raw);
    }

    public void tcgetattr(int fd, Termios &t) {
        // simulate system terminal state read
        t.clflag = 1;
    }

    public void tcsetattr(int fd, int flag, Termios t) {
        // simulate applying terminal attributes
        sys_write(1, "Termios attributes set.\n", 25);;
    }
};
