package fr.quilicicf.bashrc.rtfm;

public class Stats {

    private int aliasesNumber;

    private int methodsNumber;

    private int linesNumber;

    public int getAliasesNumber() {
        return aliasesNumber;
    }

    public int getLinesNumber() {
        return linesNumber;
    }

    public int getMethodsNumber() {
        return methodsNumber;
    }

    public void incrementAliasesNumber() {
        this.aliasesNumber++;
    }

    public void incrementMethodsNumber() {
        this.methodsNumber++;
    }

    public void setLinesNumber(int linesNumber) {
        this.linesNumber = linesNumber;
    }

}
