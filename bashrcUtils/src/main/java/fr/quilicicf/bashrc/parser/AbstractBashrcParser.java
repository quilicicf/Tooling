package fr.quilicicf.bashrc.parser;

import fr.quilicicf.bashrc.BashrcUtils;
import fr.quilicicf.bashrc.ProgramEnder;
import org.slf4j.Logger;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.DirectoryStream;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.google.common.base.Strings.isNullOrEmpty;
import static fr.quilicicf.bashrc.BashrcUtils.endProgram;
import static java.lang.String.format;
import static java.nio.file.FileVisitResult.CONTINUE;
import static java.nio.file.Files.createDirectories;
import static java.nio.file.Files.delete;
import static java.nio.file.Files.exists;
import static java.nio.file.Files.isDirectory;
import static java.nio.file.Files.newDirectoryStream;
import static java.nio.file.Files.readAllLines;
import static java.nio.file.Files.walkFileTree;
import static java.util.Arrays.asList;
import static java.util.regex.Pattern.compile;
import static org.slf4j.LoggerFactory.getLogger;

public abstract class AbstractBashrcParser {
    private static final Logger LOGGER = getLogger(AbstractBashrcParser.class);

    private static final String SOURCE_REGEX = ".*\\.sh";

    protected ParsingState state;
    protected final List<String> allLines = new ArrayList<>();

    public AbstractBashrcParser(final ParsingState state, final List<Path> sourceFolders) {
        this.state = state;

        sourceFolders.stream()
                .map(this::gatherFiles)
                .map(this::gatherLines)
                .forEach(allLines::addAll);
    }

    public abstract void build();

    public abstract ParserType getType();

    protected void createFolder(final String path) {
        try {
            createDirectories(Paths.get(path));
        } catch (final IOException e) {
            endProgram(format("Could not create folder '%s' because of %s", path, e.getClass().getSimpleName()));
        }
    }

    protected void deleteFolderIfExists(final String path) {
        final Path directory = Paths.get(path);
        if (exists(directory)) {
            try {
                walkFileTree(directory, new SimpleFileVisitor<Path>() {
                    @Override
                    public FileVisitResult postVisitDirectory(final Path dir, final IOException exc) throws IOException {
                        delete(dir);
                        return CONTINUE;
                    }

                    @Override
                    public FileVisitResult visitFile(final Path file, final BasicFileAttributes attrs) throws IOException {
                        delete(file);
                        return CONTINUE;
                    }

                });
            } catch (final IOException e) {
                endProgram(format("Could not delete folder '%s' because of %s", path, e.getClass().getSimpleName()));
            }
        }
    }

    private List<Path> gatherFiles(final Path directory) {
        final DirectoryStream<Path> stream;
        final List<Path> paths = new ArrayList<>();
        try {
            stream = newDirectoryStream(directory);
            for (final Path current : stream) {
                if (isDirectory(current)) {
                    paths.addAll(gatherFiles(current));
                } else {
                    final boolean skipFile = !current.toString().matches(SOURCE_REGEX);

                    if (current.toString().contains("gitignore") || skipFile) {
                        LOGGER.debug("Skipping file: " + current.toString());
                        continue;
                    }

                    paths.add(current);
                }
            }
            return paths;
        } catch (final Exception e) {
            throw new ProgramEnder(format("Couldn't list files in: '%s'", directory.toAbsolutePath().toString()));
        }
    }

    private List<String> gatherLines(final List<Path> allFiles) {
        allFiles.sort(Comparator.comparing(o -> o.toAbsolutePath().toString()));

        final List<String> allLines = new ArrayList<>();
        final String lastFile = allFiles.get(0).toAbsolutePath().toString() + "/tititatatoto";
        for (final Path current : allFiles) {
            if (hasChangedDirectory(lastFile, current.toAbsolutePath().toString())) {
                allLines.addAll(asList("#########", "# " + getDirectory(current), "#########"));
            }

            try {
                allLines.addAll(readAllLines(current, StandardCharsets.UTF_8));
            } catch (final Exception e) {
                throw new ProgramEnder(format("Couldn't list lines in file: '%s'", current.toAbsolutePath().toString()));
            }
        }
        return allLines;

    }

    private String getDirectory(final Path current) {
        final Pattern pattern = compile("(/[^/]+)+/([^/]+)/[^/]+");
        final String path = current.toAbsolutePath().toString();
        final Matcher m = pattern.matcher(path);
        if (m.matches()) {
            return m.group(2);
        }
        BashrcUtils.endProgram(format("Could not find directory for Path: '%s'", path));
        return null;
    }

    private boolean hasChangedDirectory(final String lastFile, final String currentFile) {
        final Pattern pattern = compile("(/[^/]+)+/([^/]+)/[^/]+");
        final Matcher lastMatcher = pattern.matcher(lastFile);
        final Matcher currentMatcher = pattern.matcher(currentFile);

        String lastDirectory = "";
        String currentDirectory = "";

        if (lastMatcher.matches()) {
            lastDirectory = lastMatcher.group(2);
        }
        if (currentMatcher.matches()) {
            currentDirectory = currentMatcher.group(2);
        }
        return !lastDirectory.equals(currentDirectory);
    }

    protected void logLineInfo(final String header, final String line) {
        final String output = "| " + header + " | " + line;
        LOGGER.debug(output);
    }

    protected abstract void processAliasLine(String line);

    protected abstract void processBeginMethodLine(String line);

    protected abstract void processBeginOrEndSubTitleLine(String line);

    protected abstract void processBeginSkipLine(String line);

    protected abstract void processBeginTitleLine(String line);

    protected abstract void processCommentLine(String line);

    protected abstract void processEndMethodLine(String line);

    protected abstract void processExportVariableLine(String line);

    protected void processLine(final String line) {
        if (isNullOrEmpty(line.trim())) { // Empty line
            LOGGER.debug("| Empty line |");

        } else if (line.matches("#{3,}")) { // Begin or end title
            processBeginTitleLine(line);

        } else if (line.matches("# .+") && state.isInFolderTitle()) { // Title
            processTitleLine(line);

        } else if (line.matches("# .+") && state.isInSubTitle()) { // Sub-title
            processSubTitleLine(line);

        } else if (line.matches("# !![ ]*")) { // Begin skip
            processBeginSkipLine(line);

        } else if (ParserType.DOC.equals(getType()) && state.isSkipping()) { // Skip
            logLineInfo("Skip", line);

        } else if (line.startsWith("export")) { // Variables
            processExportVariableLine(line);

        } else if (line.startsWith("#---")) { // Begin or end sub-title
            processBeginOrEndSubTitleLine(line);

        } else if (line.matches("#{1,2} .*")) { // Comments
            processCommentLine(line);

        } else if (line.matches("[a-zA-Z0-9_]+\\(\\) \\{")) { // Begin method
            processBeginMethodLine(line);

        } else if ("}".equals(line)) { // End method
            processEndMethodLine(line);

        } else if (state.isInMethod()) { // In method
            processMethodLine(line);
            logLineInfo("In method", line);

        } else if (line.matches("alias ([a-zA-Z0-9])+=.*")) { // Aliases
            processAliasLine(line);

        } else if (line.startsWith("__git_complete")) { // Git complete
            processMethodLine(line);
            logLineInfo("Git complete", line);

        } else {
            processUnmatchedLine(line);
            LOGGER.debug("| No match | " + line);
        }
    }

    protected abstract void processMethodLine(String line);

    protected abstract void processSubTitleLine(String line);

    protected abstract void processTitleLine(String line);

    protected abstract void processUnmatchedLine(String line);

}
