package fr.quilicicf.bashrc.rtfm;

import com.google.common.base.Splitter;
import fr.quilicicf.bashrc.parser.AbstractBashrcParser;
import fr.quilicicf.bashrc.parser.MethodDescription;
import fr.quilicicf.bashrc.parser.ParserType;
import fr.quilicicf.bashrc.parser.ParsingState;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import static fr.quilicicf.bashrc.BashrcUtils.BASHRC;
import static fr.quilicicf.bashrc.BashrcUtils.DOC_PATH;
import static fr.quilicicf.bashrc.BashrcUtils.endProgram;
import static fr.quilicicf.bashrc.parser.ParserType.DOC;
import static java.lang.String.format;
import static java.nio.charset.StandardCharsets.UTF_8;
import static java.nio.file.Files.exists;
import static java.nio.file.Files.newBufferedWriter;
import static java.nio.file.StandardOpenOption.CREATE;

public class RtfmGenerator extends AbstractBashrcParser {
    private static Logger LOGGER = LoggerFactory.getLogger(RtfmGenerator.class);

    private Stats stats;

    private String beautifyTitleLine(String line) {
        return line
                .replaceAll("#", "")
                .trim()
                .replaceAll(" ", "_");
    }

    public void build() {
        deleteFolderIfExists(DOC_PATH);
        createFolder(DOC_PATH);

        stats = new Stats();
        state = new ParsingState();

        List<Path> allFiles = gatherFiles(BASHRC);
        List<String> allLines = gatherLines(allFiles, BASHRC);
        stats.setLinesNumber(allLines.size());

        allLines.forEach(this::processLine);

        LOGGER.info("Bashrc documentation built: " +
                "\t" + stats.getLinesNumber() + " lines" +
                "\t" + stats.getAliasesNumber() + " aliases" +
                "\t" + stats.getMethodsNumber() + " methods");
    }

    @Override
    public ParserType getType() {
        return DOC;
    }

    protected void processAliasLine(String line) {
        logLineInfo("Alias", line);
        stats.incrementAliasesNumber();

        String name = line.substring(6, line.indexOf('='));
        logLineInfo("Alias > name", name);
        state.getCurrentMethodDescription().setName(name);

        writeMethod();
    }

    protected void processBeginMethodLine(String line) {
        logLineInfo("Method", line);
        stats.incrementMethodsNumber();
        state.setInMethod(true);

        String name = line.substring(0, line.indexOf('('));
        logLineInfo("Method > name", name);
        state.getCurrentMethodDescription().setName(name);

        writeMethod();
    }

    protected void processBeginOrEndSubTitleLine(String line) {
        logLineInfo("Begin or end sub-title", line);
        state.toggleInSubTitle();
    }

    protected void processBeginSkipLine(String line) {
        logLineInfo("# !![ ]*", line);
        state.setSkipping(true);
    }

    protected void processBeginTitleLine(String line) {
        logLineInfo("Begin or end title", line);
        state.toggleInFolderTitle();
    }

    protected void processCommentLine(String line) {
        logLineInfo("Comment", line);
        line = line.substring(2, line.length());

        if (line.startsWith("Uses: ")) {
            String dependenciesStr = line
                    .substring(line.indexOf(":") + 1)
                    .trim();
            List<String> dependencies = Splitter.on(", ").splitToList(dependenciesStr);
            logLineInfo("Comment > dependencies", dependenciesStr);
            state.getCurrentMethodDescription().setDependencies(dependencies);

        } else if (line.matches("\\$[0-9]: .*")) {
            String parameter = line
                    .substring(line.indexOf(":") + 1)
                    .trim();
            logLineInfo("Comment > parameter", parameter);
            state.getCurrentMethodDescription().getParameters().add(parameter);

        } else if (line.matches("[a-z]: .*")) {
            String parameter = line
                    .substring(line.indexOf(":") + 1)
                    .trim();
            logLineInfo("Comment > parameter", parameter);
            state.getCurrentMethodDescription().getParameters().add(parameter);

        } else {
            logLineInfo("Comment > description", line);
            state.getCurrentMethodDescription().addDescriptionLine(line);
        }
    }

    protected void processEndMethodLine(String line) {
        logLineInfo("End method", line);
        state.setInMethod(false);
        state.setCurrentMethodDescription(new MethodDescription());
    }

    protected void processExportVariableLine(String line) {
        logLineInfo("Variable", line);
        // TODO: deal with variables
    }

    @Override
    protected void processMethodLine(String line) {
        // never called when type = DOC
    }

    protected void processSubTitleLine(String line) {
        logLineInfo("Sub-title", line);
        state.setSkipping(false);
        state.setCurrentSection(beautifyTitleLine(line));
    }

    protected void processTitleLine(String line) {
        logLineInfo("Folder title", line);
        state.setSkipping(false);
        state.setCurrentFolder(beautifyTitleLine(line));
        state.setCurrentSection(null);
    }

    @Override
    protected void processUnmatchedLine(String line) {
        // Do nothing

    }

    private void writeMethod() {
        // TODO finish (enhance folder creation, see if options exist to create if it does not exist)
        String path = DOC_PATH;
        MethodDescription methodDescription = state.getCurrentMethodDescription();

        if (state.getCurrentFolder() != null) {
            path += "/" + state.getCurrentFolder();
            if (!exists(Paths.get(path))) {
                createFolder(path);
            }
        }

        if (state.getCurrentSection() != null) {
            path += "/" + state.getCurrentSection();
            if (!exists(Paths.get(path))) {
                createFolder(path);
            }
        }

        String methodName = methodDescription.getName();
        path += "/" + methodName + ".doc";
        Path doc = Paths.get(path);

        try (BufferedWriter w = newBufferedWriter(doc, UTF_8, CREATE)) {

            w.write("## __" + methodName + "__\n");
            w.write("  " + methodDescription.getDescription() + "\n\n");

            w.write("### _Parameters_\n\n");
            List<String> parameters = methodDescription.getParameters();
            if (parameters.isEmpty()) {
                w.write("\tNone\n");
            }
            for (String parameter : parameters) {
                w.write("  1. " + parameter + "\n");
            }
            w.write("\n");

            w.write("### _Dependencies_\n\n");
            List<String> dependencies = methodDescription.getDependencies();
            if (dependencies.isEmpty()) {
                w.write("\tNone\n");
            }
            for (String dependency : dependencies) {
                w.write("  - " + dependency + "\n");
            }
            w.write("\n");
        } catch (IOException e) {
            endProgram(
                    format("Impossible to open a writer for file: '%s' because of %s",
                            doc, e.getClass().getSimpleName()));
        }
    }
}
