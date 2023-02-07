package fr.quilicicf.bashrc;

import fr.quilicicf.bashrc.build.BashrcBuilder;
import fr.quilicicf.bashrc.parser.AbstractBashrcParser;
import fr.quilicicf.bashrc.rtfm.RtfmGenerator;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.log4j.Level;
import org.apache.log4j.LogManager;

import static java.nio.file.Files.exists;

public class Main {

    public static Path BASHRC_REFINED = Paths.get(System.getProperty("user.home") + "/.bashrc");

    public static String DOC_PATH;

    public static void main(final String[] args) {

        final Options options = new Options()
                .addOption("p", "path", true, "The path to the bashrc folder")
                .addOption("s", "secretPath", true, "The path to the secret bashrc folder")
                .addOption("d", "debug", false, "Set log level to debug")
                .addOption("rtfm", false, "Launches documentation build")
                .addOption("build", false, "Launches refined bashrc build");

        final CommandLineParser cliParser = new DefaultParser();
        try {
            final List<Path> sourceFolders = new ArrayList<>();
            final CommandLine cmd = cliParser.parse(options, args);

            if (cmd.hasOption("d")) {
                LogManager.getRootLogger().setLevel(Level.DEBUG);
            }

            if (cmd.hasOption("p")) {
                final String bashrcPath = cmd.getOptionValue("p");
                final Path bashrcFolder = Paths.get(bashrcPath);
                sourceFolders.add(bashrcFolder);
                DOC_PATH = System.getProperty("user.home") + "/.bashrcDoc";
                if (!exists(bashrcFolder)) {
                    endProgram("The bashrc path you provided points to no file");
                }
            } else {
                endProgram("You must give the path to the bashrc !");
            }

            if (cmd.hasOption("s")) {
                final String secretBashrcPath = cmd.getOptionValue("s");
                final Path secretBashrcFolder = Paths.get(secretBashrcPath);
                sourceFolders.add(secretBashrcFolder);
                if (!exists(secretBashrcFolder)) {
                    endProgram("The secret bashrc path you provided points to no file");
                }
            }

            final List<AbstractBashrcParser> parsers = new ArrayList<>();

            if (cmd.getArgList().contains("rtfm")) {
                final RtfmGenerator rtfm = new RtfmGenerator(sourceFolders);
                parsers.add(rtfm);
            }

            if (cmd.getArgList().contains("build")) {
                final BashrcBuilder builder = new BashrcBuilder(sourceFolders);
                parsers.add(builder);
            }

            parsers.forEach(AbstractBashrcParser::build);
        } catch (final ParseException e) {
            // TODO: display help
        } catch (final ProgramEnder e) {
            endProgram(e.getMessage());
        }
    }

    public static void endProgram(final String errorMessage) {
        if (errorMessage != null) {
            System.out.println(errorMessage);
            // TODO: display help
            System.exit(1);
        } else {
            System.exit(0);
        }
    }
}
