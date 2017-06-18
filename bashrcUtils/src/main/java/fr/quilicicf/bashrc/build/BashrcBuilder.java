package fr.quilicicf.bashrc.build;

import com.google.common.base.Joiner;
import fr.quilicicf.bashrc.parser.AbstractBashrcParser;
import fr.quilicicf.bashrc.parser.ParserType;
import fr.quilicicf.bashrc.parser.ParsingState;
import org.slf4j.Logger;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import static fr.quilicicf.bashrc.BashrcUtils.BASHRC;
import static fr.quilicicf.bashrc.BashrcUtils.BASHRC_REFINED;
import static fr.quilicicf.bashrc.BashrcUtils.endProgram;
import static java.lang.String.format;
import static java.nio.charset.StandardCharsets.UTF_8;
import static java.nio.file.Files.delete;
import static java.nio.file.Files.exists;
import static java.nio.file.Files.newBufferedWriter;
import static java.nio.file.StandardOpenOption.CREATE_NEW;
import static org.slf4j.LoggerFactory.getLogger;

public class BashrcBuilder extends AbstractBashrcParser {
    private static Logger LOGGER = getLogger(BashrcBuilder.class);

    private List<String> parsedLines = new ArrayList<>();

    @Override
    public void build() {
        state = new ParsingState();
        List<Path> allFiles = gatherFiles(BASHRC);
        List<String> allLines = gatherLines(allFiles, BASHRC);

        allLines.forEach(this::processLine);

        writeRefinedBashrc();
        LOGGER.info("Refined bashrc built");
    }

    @Override
    public ParserType getType() {
        return ParserType.BUILD;
    }

    @Override
    protected void processAliasLine(String line) {
        parsedLines.add(line);
    }

    @Override
    protected void processBeginMethodLine(String line) {
        parsedLines.add(line);
        state.setInMethod(true);
    }

    @Override
    protected void processBeginOrEndSubTitleLine(String line) {
        // Do nothing
    }

    @Override
    protected void processBeginSkipLine(String line) {
        // Do nothing
    }

    @Override
    protected void processBeginTitleLine(String line) {
        // Do nothing
    }

    @Override
    protected void processCommentLine(String line) {
        // Do nothing
    }

    @Override
    protected void processEndMethodLine(String line) {
        parsedLines.add(line);
        state.setInMethod(false);
    }

    @Override
    protected void processExportVariableLine(String line) {
        parsedLines.add(line);
    }

    @Override
    protected void processMethodLine(String line) {
        parsedLines.add(line);
    }

    @Override
    protected void processSubTitleLine(String line) {
        // Do nothing
    }

    @Override
    protected void processTitleLine(String line) {
        // Do nothing
    }

    private void writeRefinedBashrc() {
        if (exists(BASHRC_REFINED)) {
            try {
                delete(BASHRC_REFINED);
            } catch (IOException e) {
                // Do nothing
            }
        }

        try (BufferedWriter w = newBufferedWriter(BASHRC_REFINED, UTF_8, CREATE_NEW)) {

            w.write(Joiner.on("\n").join(parsedLines));
        } catch (Exception e) {
            endProgram(
                    format("Impossible to open a writer for file: '%s' because of %s",
                            BASHRC_REFINED, e.getClass().getSimpleName()));
        }
    }

    @Override
    protected void processUnmatchedLine(String line) {
        parsedLines.add(line);
    }

}
