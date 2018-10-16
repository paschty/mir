package org.mycore.mir;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessInterface;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.MCRUtils;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRURLContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.common.xml.MCRXMLHelper;
import org.mycore.common.xsl.MCRXSLTransformerFactory;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaIFS;
import org.mycore.datamodel.metadata.MCRMetaLinkID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.datamodel.niofs.utils.MCRFileCollectingFileVisitor;
import org.mycore.frontend.MCRURL;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mods.MCRMODSWrapper;
import org.xml.sax.SAXException;

@MCRCommandGroup(
    name = "LaadeImport")
public class LaadeImport {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String SRU_URL_TEMPLATE = "http://sru.gbv.de/opac-de-hil8?version=1.1&operation=searchRetrieve&query=pica.sgs=\"$SIGNATURE$\"&maximumRecords=1&recordSchema=picaxml";

    @MCRCommand(syntax = "import laade object {0}")
    public static void importLadaObject(String signature) throws MalformedURLException {
        final MCRXSLTransformer transformer = new MCRXSLTransformer("xsl/LadePica2mods.xsl");
        transformer.setTransformerFactory("net.sf.saxon.TransformerFactoryImpl");

        try {
            final String encodedSignature = URLEncoder.encode(signature, "UTF-8");
            final String picaURL = SRU_URL_TEMPLATE.replace("$SIGNATURE$", encodedSignature);
            final MCRURLContent pica = new MCRURLContent(new URL(picaURL));
            final Document picaDocument = pica.asXML();


            final MCRContent resultingMods = transformer.transform(pica);
            final Document modsDocument = resultingMods.asXML();
            final MCRObject mcrObject = MCRMODSWrapper.wrapMODSDocument(modsDocument.getRootElement(), "mir");
            mcrObject.setId(MCRObjectID.getNextFreeId("mir", "mods"));
            MCRMetadataManager.create(mcrObject);
        } catch (IOException e) {
            throw new MCRException("Error while transforming PICA!", e);
        } catch (JDOMException | SAXException e) {
            throw new MCRException("Error while creating JDOM!", e);
        } catch (MCRAccessException e) {
            throw new MCRException("Error while creating MCRObject!", e);
        }
    }

    @MCRCommand(syntax = "import file for laade object {1} from online folder {0}")
    public static void importFile(String onlineFolder, String mycoreIDString) throws IOException, MCRAccessException {
        final MCRObjectID mycoreID = MCRObjectID.getInstance(mycoreIDString);

        final Path onlineFolderPath = Paths.get(onlineFolder);
        if (!Files.exists(onlineFolderPath)) {
            throw new IOException("The Path " + onlineFolder + " does not exist!");
        }

        if (!MCRMetadataManager.exists(mycoreID)) {
            throw new IOException("The MyCoRe-Object " + mycoreIDString + " does not exist!");
        }

        final MCRMODSWrapper wrapper = new MCRMODSWrapper(MCRMetadataManager.retrieveMCRObject(mycoreID));
        final String signatur = wrapper.getElementValue("mods:location/mods:shelfLocator");

        if (signatur == null || signatur.isEmpty()) {
            LOGGER.info("No signature for object " + mycoreIDString);
            return;
        }

        final Path contentPath = onlineFolderPath.resolve(mapSignature(signatur));

        final MCRFileCollectingFileVisitor<Path> collector = new MCRFileCollectingFileVisitor<Path>();
        Files.walkFileTree(contentPath, collector);
        final ArrayList<Path> files = collector.getPaths();

        final List<Path> imageFiles = files.stream().filter(p -> p.toString().endsWith(".jpg"))
            .collect(Collectors.toList());
        if (imageFiles.size() > 0) {

            final MCRDerivate images = createDerivate(mycoreIDString, "images");
            final MCRObjectID id = images.getId();
            imageFiles.forEach(imagePath -> {
                final Path fileName = contentPath.relativize(imagePath);
                final MCRPath filePath = MCRPath.getPath(id.toString(), fileName.toString());
                LOGGER.info("Import {}", fileName);

                try {
                    Files.copy(imagePath, filePath);
                } catch (IOException e) {
                    throw new MCRException("Error while copying", e);
                }
            });
        }

        final List<Path> mp3Files = files.stream().filter(p -> p.toString().endsWith(".mp3"))
            .collect(Collectors.toList());
        if (imageFiles.size() > 0) {
            final MCRDerivate images = createDerivate(mycoreIDString, "images");
            final MCRObjectID id = images.getId();
            mp3Files.forEach(mp3Path -> {
                final Path fileName = contentPath.relativize(mp3Path);
                final MCRPath filePath = MCRPath.getPath(id.toString(), fileName.toString());
                LOGGER.info("Import {}", fileName);
                try {
                    Files.copy(mp3Path, filePath);
                } catch (IOException e) {
                    throw new MCRException("Error while copying", e);
                }
            });
        }
    }

    private static String mapSignature(String old) {
        return old.replace('-', '_').replace(' ', '_');
    }

    public static MCRDerivate createDerivate(String documentID, String label)
        throws MCRPersistenceException, IOException, MCRAccessException {
        final String projectId = MCRObjectID.getInstance(documentID).getProjectId();
        MCRObjectID oid = MCRObjectID.getNextFreeId(projectId, "derivate");
        final String derivateID = oid.toString();

        MCRDerivate derivate = new MCRDerivate();
        derivate.setId(oid);
        derivate.setLabel(label);

        String schema = MCRConfiguration.instance().getString("MCR.Metadata.Config.derivate", "datamodel-derivate.xml")
            .replaceAll(".xml",
                ".xsd");
        derivate.setSchema(schema);

        MCRMetaLinkID linkId = new MCRMetaLinkID();
        linkId.setSubTag("linkmeta");
        linkId.setReference(documentID, null, null);
        derivate.getDerivate().setLinkMeta(linkId);

        MCRMetaIFS ifs = new MCRMetaIFS();
        ifs.setSubTag("internal");
        ifs.setSourcePath(null);

        derivate.getDerivate().setInternals(ifs);

        LOGGER.debug("Creating new derivate with ID {}", derivateID);
        MCRMetadataManager.create(derivate);

        if (MCRConfiguration.instance().getBoolean("MCR.Access.AddDerivateDefaultRule", true)) {
            MCRAccessInterface AI = MCRAccessManager.getAccessImpl();
            Collection<String> configuredPermissions = AI.getAccessPermissionsFromConfiguration();
            for (String permission : configuredPermissions) {
                MCRAccessManager.addRule(derivateID, permission, MCRAccessManager.getTrueRule(),
                    "default derivate rule");
            }
        }

        final MCRPath rootDir = MCRPath.getPath(derivateID, "/");
        if (Files.notExists(rootDir)) {
            rootDir.getFileSystem().createRoot(derivateID);
        }

        return derivate;
    }

}
