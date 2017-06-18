package fr.quilicicf.bashrc;

import org.apache.log4j.PatternLayout;
import org.apache.log4j.spi.LoggingEvent;

public class LogLayout extends PatternLayout {

    @Override
    public String format(LoggingEvent event) {
        return event.getLevel() + " " + event.getMessage() + "\n";
    }
}
