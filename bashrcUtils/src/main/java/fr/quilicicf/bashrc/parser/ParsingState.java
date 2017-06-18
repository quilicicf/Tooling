package fr.quilicicf.bashrc.parser;

public class ParsingState {

    private boolean inFolderTitle;

    private boolean skipping;

    private boolean inMethod;

    private String currentFolder;

    private String currentSection;

    private boolean inSubTitle;

    private MethodDescription currentMethodDescription = new MethodDescription();

    public String getCurrentFolder() {
        return currentFolder;
    }

    public MethodDescription getCurrentMethodDescription() {
        return currentMethodDescription;
    }

    public String getCurrentSection() {
        return currentSection;
    }

    public boolean isInFolderTitle() {
        return inFolderTitle;
    }

    public boolean isInMethod() {
        return inMethod;
    }

    public boolean isInSubTitle() {
        return inSubTitle;
    }

    public boolean isSkipping() {
        return skipping;
    }

    public void setCurrentFolder(String currentFolder) {
        this.currentFolder = currentFolder;
    }

    public void setCurrentMethodDescription(MethodDescription currentMethodDescription) {
        this.currentMethodDescription = currentMethodDescription;
    }

    public void setCurrentSection(String currentSection) {
        this.currentSection = currentSection;
    }

    public void setInMethod(boolean inMethod) {
        this.inMethod = inMethod;
    }

    public void setSkipping(boolean skipping) {
        this.skipping = skipping;
    }

    public void toggleInFolderTitle() {
        this.inFolderTitle = !inFolderTitle;
    }

    public void toggleInSubTitle() {
        this.inSubTitle = !inSubTitle;
    }
}
