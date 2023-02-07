package fr.quilicicf.bashrc;

public class ProgramEnder extends RuntimeException {
    public ProgramEnder(final String message) {
        super(message);
    }
}
