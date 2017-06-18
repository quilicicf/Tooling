package fr.quilicicf.bashrc;

import fr.quilicicf.bashrc.build.BashrcBuilder;
import fr.quilicicf.bashrc.parser.AbstractBashrcParser;
import fr.quilicicf.bashrc.rtfm.RtfmGenerator;
import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.log4j.Level;
import org.apache.log4j.LogManager;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class BashrcUtils {

    public static Path BASHRC;

    public static Path BASHRC_REFINED = Paths.get(System.getProperty("user.home") + "/.bashrc");

    public static String DOC_PATH;

    public static void main(String[] args) {

        Options options = new Options()
                .addOption("p", "path", true, "The path to the bashrc")
                .addOption("d", "debug", false, "Set log level to debug")
                .addOption("rtfm", false, "Launches documentation build")
                .addOption("build", false, "Launches refined bashrc build");

        CommandLineParser cliParser = new BasicParser();
        try {
            CommandLine cmd = cliParser.parse(options, args);

            if (cmd.hasOption("d")) {
                LogManager.getRootLogger().setLevel(Level.DEBUG);
            }

            if (cmd.hasOption("p")) {
                String bashrcPath = cmd.getOptionValue("p");
                BASHRC = Paths.get(bashrcPath);
                DOC_PATH = System.getProperty("user.home") + "/.bashrcDoc";
                if (!Files.exists(BASHRC)) {
                    endProgram("The bashrc path you provided points to no file");
                }
            } else {
                endProgram("You must give the path to the bashrc !");
            }

            List<AbstractBashrcParser> parsers = new ArrayList<>();

            if (cmd.getArgList().contains("rtfm")) {
                RtfmGenerator rtfm = new RtfmGenerator();
                parsers.add(rtfm);
            }

            if (cmd.getArgList().contains("build")) {
                BashrcBuilder builder = new BashrcBuilder();
                parsers.add(builder);
            }

            parsers.forEach(AbstractBashrcParser::build);
        } catch (ParseException e) {
            // TODO: display help
        }
    }

    public static void endProgram(String errorMessage) {
        if (errorMessage != null) {
            System.out.println(errorMessage);
            // TODO: display help
            System.exit(1);
        } else {
            System.exit(0);
        }
    }
}
