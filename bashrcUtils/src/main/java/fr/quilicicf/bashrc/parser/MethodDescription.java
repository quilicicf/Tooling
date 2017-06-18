package fr.quilicicf.bashrc.parser;

import java.util.ArrayList;
import java.util.List;

import static fr.quilicicf.bashrc.utils.ObjectUtils.isNullOrEmpty;

public class MethodDescription {

    private String name;

    private String description;

    private List<String> parameters;

    private List<String> dependencies;

    public List<String> getDependencies() {
        if (dependencies == null) {
            dependencies = new ArrayList<>();
        }
        return dependencies;
    }

    public String getDescription() {
        return description;
    }

    public String getName() {
        return name;
    }

    public List<String> getParameters() {
        if (parameters == null) {
            parameters = new ArrayList<>();
        }
        return parameters;
    }

    public void setDependencies(List<String> dependencies) {
        this.dependencies = dependencies;
    }

    public void addDescriptionLine(String newLine) {
        this.description = isNullOrEmpty(this.description)
                ? newLine
                : String.format("%s\n%s", this.description, newLine);
    }

    public void setName(String name) {
        this.name = name;
    }
}
