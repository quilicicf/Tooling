package fr.quilicicf.bashrc.parser;

import fr.quilicicf.bashrc.BashrcUtils;
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
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.google.common.base.Strings.isNullOrEmpty;
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
import static java.util.Collections.sort;
import static java.util.regex.Pattern.compile;
import static org.slf4j.LoggerFactory.getLogger;

public abstract class AbstractBashrcParser {
    private static Logger LOGGER = getLogger(AbstractBashrcParser.class);

    protected static final String SOURCE_REGEX = ".*\\.sh";

    protected ParsingState state;

    public abstract void build();

    public abstract ParserType getType();

    protected void createFolder(String path) {
        try {
            createDirectories(Paths.get(path));
        } catch (IOException e) {
            BashrcUtils.endProgram(
                    format("Could not create folder '%s' because of ",
                            path, e.getClass().getSimpleName()));
        }
    }

    protected void deleteFolderIfExists(String path) {
        Path directory = Paths.get(path);
        if (exists(directory)) {
            try {
                walkFileTree(directory, new SimpleFileVisitor<Path>() {
                    @Override
                    public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                        delete(dir);
                        return CONTINUE;
                    }

                    @Override
                    public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                        delete(file);
                        return CONTINUE;
                    }

                });
            } catch (IOException e) {
                BashrcUtils.endProgram(
                        format("Could not delete folder '%s' because of ",
                                path, e.getClass().getSimpleName()));
            }
        }
    }

    protected List<Path> gatherFiles(Path directory) {
        DirectoryStream<Path> stream;
        List<Path> paths = new ArrayList<>();
        try {
            stream = newDirectoryStream(directory);
            for (Path current : stream) {
                if (isDirectory(current)) {
                    paths.addAll(gatherFiles(current));
                } else {
                    boolean skipFile = !current.toString().matches(SOURCE_REGEX);

                    if (current.toString().contains("gitignore") || skipFile) {
                        LOGGER.debug("Skipping file: " + current.toString());
                        continue;
                    }

                    paths.add(current);
                }
            }
            return paths;
        } catch (Exception e) {
            BashrcUtils.endProgram(format("Couldn't list files in: '%s'", directory.toAbsolutePath().toString()));
            return null;
        }
    }

    protected List<String> gatherLines(List<Path> allFiles, Path directory) {
        sort(allFiles, (o1, o2) -> o1.toAbsolutePath().toString().compareTo(o2.toAbsolutePath().toString()));

        List<String> allLines = new ArrayList<>();
        String lastFile = BashrcUtils.BASHRC.toAbsolutePath().toString() + "/tititatatoto";
        try {
            for (Path current : allFiles) {
                if (hasChangedDirectory(lastFile, current.toAbsolutePath().toString())) {
                    allLines.addAll(asList("#########", "# " + getDirectory(current), "#########"));
                }
                allLines.addAll(readAllLines(current, StandardCharsets.UTF_8));
            }
            return allLines;
        } catch (Exception e) {
            BashrcUtils.endProgram(format("Couldn't list files in: '%s'", directory.toAbsolutePath().toString()));
            return null;
        }

    }

    private String getDirectory(Path current) {
        Pattern pattern = compile("(/[^/]+)+/([^/]+)/[^/]+");
        String path = current.toAbsolutePath().toString();
        Matcher m = pattern.matcher(path);
        if (m.matches()) {
            return m.group(2);
        }
        BashrcUtils.endProgram(format("Could not find directory for Path: '%s'", path));
        return null;
    }

    private boolean hasChangedDirectory(String lastFile, String currentFile) {
        Pattern pattern = compile("(/[^/]+)+/([^/]+)/[^/]+");
        Matcher lastMatcher = pattern.matcher(lastFile);
        Matcher currentMatcher = pattern.matcher(currentFile);

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

    protected void logLineInfo(String header, String line) {
        String output = "| " + header + " | " + line;
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

    protected void processLine(String line) {
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
