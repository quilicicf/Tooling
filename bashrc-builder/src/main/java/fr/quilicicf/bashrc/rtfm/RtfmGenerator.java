package fr.quilicicf.bashrc.rtfm;

import com.google.common.base.Splitter;
import fr.quilicicf.bashrc.parser.AbstractBashrcParser;
import fr.quilicicf.bashrc.parser.MethodDescription;
import fr.quilicicf.bashrc.parser.ParserType;
import fr.quilicicf.bashrc.parser.ParsingState;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static fr.quilicicf.bashrc.Main.DOC_PATH;
import static fr.quilicicf.bashrc.Main.endProgram;
import static fr.quilicicf.bashrc.parser.ParserType.DOC;
import static java.lang.String.format;
import static java.nio.charset.StandardCharsets.UTF_8;
import static java.nio.file.Files.exists;
import static java.nio.file.Files.newBufferedWriter;
import static java.nio.file.StandardOpenOption.CREATE;

public class RtfmGenerator extends AbstractBashrcParser {
    private static final Logger LOGGER = LoggerFactory.getLogger(RtfmGenerator.class);

    private Stats stats;

    public RtfmGenerator(final List<Path> sourceFolders) {
        super(new ParsingState(), sourceFolders);
    }

    private String beautifyTitleLine(final String line) {
        return line
                .replaceAll("#", "")
                .trim()
                .replaceAll(" ", "_");
    }

    @Override
    public void build() {
        deleteFolderIfExists(DOC_PATH);
        createFolder(DOC_PATH);

        stats = new Stats();
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

    @Override
    protected void processAliasLine(final String line) {
        logLineInfo("Alias", line);
        stats.incrementAliasesNumber();

        final String name = line.substring(6, line.indexOf('='));
        logLineInfo("Alias > name", name);
        state.getCurrentMethodDescription().setName(name);

        writeMethod();
    }

    @Override
    protected void processBeginMethodLine(final String line) {
        logLineInfo("Method", line);
        stats.incrementMethodsNumber();
        state.setInMethod(true);

        final String name = line.substring(0, line.indexOf('('));
        logLineInfo("Method > name", name);
        state.getCurrentMethodDescription().setName(name);

        writeMethod();
    }

    @Override
    protected void processBeginOrEndSubTitleLine(final String line) {
        logLineInfo("Begin or end sub-title", line);
        state.toggleInSubTitle();
    }

    @Override
    protected void processBeginSkipLine(final String line) {
        logLineInfo("# !![ ]*", line);
        state.setSkipping(true);
    }

    @Override
    protected void processBeginTitleLine(final String line) {
        logLineInfo("Begin or end title", line);
        state.toggleInFolderTitle();
    }

    @Override
    protected void processCommentLine(String line) {
        logLineInfo("Comment", line);
        line = line.substring(2, line.length());

        if (line.startsWith("Uses: ")) {
            final String dependenciesStr = line
                    .substring(line.indexOf(":") + 1)
                    .trim();
            final List<String> dependencies = Splitter.on(", ").splitToList(dependenciesStr);
            logLineInfo("Comment > dependencies", dependenciesStr);
            state.getCurrentMethodDescription().setDependencies(dependencies);

        } else if (line.matches("\\$[0-9]: .*")) {
            final String parameter = line
                    .substring(line.indexOf(":") + 1)
                    .trim();
            logLineInfo("Comment > parameter", parameter);
            state.getCurrentMethodDescription().getParameters().add(parameter);

        } else if (line.matches("[a-z]: .*")) {
            final String parameter = line
                    .substring(line.indexOf(":") + 1)
                    .trim();
            logLineInfo("Comment > parameter", parameter);
            state.getCurrentMethodDescription().getParameters().add(parameter);

        } else {
            logLineInfo("Comment > description", line);
            state.getCurrentMethodDescription().addDescriptionLine(line);
        }
    }

    @Override
    protected void processEndMethodLine(final String line) {
        logLineInfo("End method", line);
        state.setInMethod(false);
        state.setCurrentMethodDescription(new MethodDescription());
    }

    @Override
    protected void processExportVariableLine(final String line) {
        logLineInfo("Variable", line);
        // TODO: deal with variables
    }

    @Override
    protected void processMethodLine(final String line) {
        // never called when type = DOC
    }

    @Override
    protected void processSubTitleLine(final String line) {
        logLineInfo("Sub-title", line);
        state.setSkipping(false);
        state.setCurrentSection(beautifyTitleLine(line));
    }

    @Override
    protected void processTitleLine(final String line) {
        logLineInfo("Folder title", line);
        state.setSkipping(false);
        state.setCurrentFolder(beautifyTitleLine(line));
        state.setCurrentSection(null);
    }

    @Override
    protected void processUnmatchedLine(final String line) {
        // Do nothing

    }

    private void writeMethod() {
        // TODO finish (enhance folder creation, see if options exist to create if it does not exist)
        String path = DOC_PATH;
        final MethodDescription methodDescription = state.getCurrentMethodDescription();

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

        final String methodName = methodDescription.getName();
        path += "/" + methodName + ".doc";
        final Path doc = Paths.get(path);

        try (final BufferedWriter w = newBufferedWriter(doc, UTF_8, CREATE)) {

            w.write("## __" + methodName + "__\n");
            w.write("  " + methodDescription.getDescription() + "\n\n");

            w.write("### _Parameters_\n\n");
            final List<String> parameters = methodDescription.getParameters();
            if (parameters.isEmpty()) {
                w.write("\tNone\n");
            }
            for (final String parameter : parameters) {
                w.write("  1. " + parameter + "\n");
            }
            w.write("\n");

            w.write("### _Dependencies_\n\n");
            final List<String> dependencies = methodDescription.getDependencies();
            if (dependencies.isEmpty()) {
                w.write("\tNone\n");
            }
            for (final String dependency : dependencies) {
                w.write("  - " + dependency + "\n");
            }
            w.write("\n");
        } catch (final IOException e) {
            endProgram(
                    format("Impossible to open a writer for file: '%s' because of %s",
                            doc, e.getClass().getSimpleName()));
        }
    }
}
