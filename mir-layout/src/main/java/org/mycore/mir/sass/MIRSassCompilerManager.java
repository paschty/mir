package org.mycore.mir.sass;

import io.bit3.jsass.CompilationException;
import io.bit3.jsass.Compiler;
import io.bit3.jsass.Options;
import io.bit3.jsass.Output;
import io.bit3.jsass.context.FileContext;
import io.bit3.jsass.context.StringContext;
import io.bit3.jsass.importer.Import;
import io.bit3.jsass.importer.Importer;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.security.NoSuchAlgorithmException;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.MCRUtils;
import org.mycore.common.config.MCRConfiguration;

import com.yahoo.platform.yui.compressor.CssCompressor;

/**
 * Compiles .scss to .css or .min.css using different sources ({@link Importer}s)
 *
 * @author Sebastian Hofmann (mcrshofm)
 * @see MIRServletContextResourceImporter
 */
public class MIRSassCompilerManager {

    private static final String DEVELOPER_MODE_CONFIG_KEY = "MIR.SASS.DeveloperMode";
    private static final String LINE_BREAK_CONFIG_KEY = "MIR.SASS.Compress.LineBreak";
    private static final Logger LOGGER = LogManager.getLogger();
    private static final MCRConfiguration MCR_CONFIGURATION = MCRConfiguration.instance();

    private Map<String, String> fileCompiledContentMap = new ConcurrentHashMap<>();
    private Map<String, Date> fileLastCompileDateMap = new ConcurrentHashMap<>();
    private Map<String, String> fileMD5Map = new ConcurrentHashMap<>();

    public static MIRSassCompilerManager getInstance() {
        return MIR_SASS_COMPILER_MANAGER_HOLDER.instance;
    }

    /**
     * Gets the compiled(&compressed) CSS
     *
     * @param file     the path to a .scss file. File should end with .css or .min.css (The compiler will look for the .scss file, then compiles and decides to minify or not).
     * @param importer a additional list of importers
     * @return Optional with the compiled css as string. Empty optional if the fileName is not valid.
     * @throws CompilationException if {@link Compiler#compile(FileContext)} throws
     */
    public synchronized Optional<String> getCSSFile(String file, List<Importer> importer) throws CompilationException, IOException {
        if (!isDeveloperMode() && fileCompiledContentMap.containsKey(file)) {
            return Optional.of(fileCompiledContentMap.get(file));
        } else {
            return Optional.ofNullable(compile(file, importer));
        }
    }

    /**
     * @param name the name of file
     * @return the time when the specific file was compiled last time.
     */
    public Optional<Date> getLastCompiled(String name) {
        return Optional.ofNullable(fileLastCompileDateMap.get(name));
    }

    /**
     * @param name the name of file
     * @return the md5 hash of the last compiled specific file.
     */
    public Optional<String> getLastMD5(String name) {
        return Optional.ofNullable(fileMD5Map.get(name));
    }

    /**
     * Just compiles a file and fills all maps.
     *
     * @param name the name of the file (with .min.css or .css ending)
     * @return the compiled css
     * @throws CompilationException
     */
    private String compile(String name, List<Importer> importer) throws CompilationException, IOException {
        Options options = new Options();
        Collection<Importer> importerList = options.getImporters();
        importer.forEach(importerList::add);

        String realFileName = name.replace(".min.css", ".scss").replace(".css", ".scss");

        Optional<Import> importedStartStylesheet = importer.stream()
                .map(i -> i.apply(realFileName, null))
                .filter(i -> i != null)
                .map(i -> i.stream().findFirst())
                .filter(Optional::isPresent)
                .map(Optional::get)
                .findFirst();
        if (!importedStartStylesheet.isPresent()) {
            return null;
        }

        Import firstImport = importedStartStylesheet.get();

        StringContext context = new StringContext(firstImport.getContents(), firstImport.getAbsoluteUri(), firstImport.getAbsoluteUri(), options);
        Compiler compiler = new Compiler();
        Output output = compiler.compile(context);

        if (output.getErrorStatus() != 0) {
            LOGGER.error(output.getErrorMessage());
            throw new CompilationException(output.getErrorStatus(), output.getErrorMessage());
        }

        String css = output.getCss();
        boolean compress = name.endsWith(".min.css");
        if (compress) {
            try {
                CssCompressor cssCompressor = new CssCompressor(new StringReader(css));
                int lineBreaks = MCR_CONFIGURATION.getInt(LINE_BREAK_CONFIG_KEY, 7999);
                StringWriter out = new StringWriter(css.length());
                cssCompressor.compress(out, lineBreaks);
                css = out.toString();
            } catch (IOException e) {
                throw new RuntimeException("Read from StringReader produces IOException! (this should not happen)", e);
            }
        }

        this.fileCompiledContentMap.put(name, css);
        this.fileLastCompileDateMap.put(name, new Date());

        try {
            this.fileMD5Map.put(name, MCRUtils.asMD5String(1, null, css));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error while generating md5 of result css!", e);
        }

        return css;

    }

    public boolean isDeveloperMode() {
        return MCR_CONFIGURATION.getBoolean(DEVELOPER_MODE_CONFIG_KEY, false);
    }

    private static final class MIR_SASS_COMPILER_MANAGER_HOLDER {
        public static final MIRSassCompilerManager instance = new MIRSassCompilerManager();
    }


}