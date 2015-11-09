package org.mycore.mir.sword2;

import java.io.IOException;
import java.net.URISyntaxException;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.Map;

import javax.naming.OperationNotSupportedException;
import javax.servlet.http.HttpServletResponse;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRXSL2XMLTransformer;
import org.mycore.datamodel.common.MCRActiveLinkException;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.sword.MCRSwordUtil;
import org.mycore.sword.application.MCRSwordIngester;
import org.mycore.sword.application.MCRSwordLifecycleConfiguration;
import org.swordapp.server.Deposit;
import org.swordapp.server.SwordError;
import org.swordapp.server.SwordServerException;
import org.swordapp.server.UriRegistry;
import org.xml.sax.SAXException;

public class MIRSwordIngester implements MCRSwordIngester {

    private static final Namespace DC_NAMESPACE = Namespace.getNamespace("dc", "http://purl.org/dc/elements/1.1/");
    private static final MCRXSL2XMLTransformer XSL_DC_MODS_TRANSFORMER = new MCRXSL2XMLTransformer("xsl/DC_MODS3-5_XSLT1-0.xsl");
    private MCRSwordLifecycleConfiguration lifecycleConfiguration;

    @Override
    public MCRObjectID ingestMetadata(Deposit entry) throws SwordError, SwordServerException {
        final MCRObjectID newObjectId = MCRObjectID.getNextFreeId(MCRConfiguration.instance().getString("MIR.projectid.default") + "_mods");
        final Map<String, List<String>> dublinCoreMetadata = entry.getSwordEntry().getDublinCore();

        Document dcDocument = buildDCDocument(dublinCoreMetadata);
        Document convertedDocument = convertDCToMods(dcDocument);

        final MCRObject mcrObject = MCRMODSWrapper.wrapMODSDocument(convertedDocument.detachRootElement(), newObjectId.getProjectId());
        mcrObject.setId(newObjectId);
        MCRMetadataManager.create(mcrObject);

        return newObjectId;
    }

    private Document convertDCToMods(Document dcDocument) throws SwordError, SwordServerException {
        final MCRContent mcrContent;
        try {
            mcrContent = XSL_DC_MODS_TRANSFORMER.transform(new MCRJDOMContent(dcDocument));
        } catch (IOException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error while transforming mods2dc!", e);
        }

        Document convertedDocument;
        try {
            convertedDocument = mcrContent.asXML();
        } catch (JDOMException | IOException | SAXException e) {
            throw new SwordServerException("Error getting transform result of mods to dc transformation!", e);
        }
        return convertedDocument;
    }

    public Document buildDCDocument(Map<String, List<String>> dublinCoreMetadata) {
        final Element dcRootElement = new Element("dc");
        final Document dc = new Document(dcRootElement);
        dublinCoreMetadata.entrySet().forEach(dcElementValueEntry -> {
            final String elemenName = dcElementValueEntry.getKey();
            dcElementValueEntry.getValue().forEach(value -> {
                final Element dcElement = new Element(elemenName, DC_NAMESPACE);
                dcElement.setText(value);
                dcRootElement.addContent(dcElement);
            });
        });
        return dc;
    }

    @Override
    public MCRObjectID ingestMetadataResources(Deposit entry) throws SwordError, SwordServerException {
        final MCRObjectID objectID = this.ingestMetadata(entry);
        try {
            final MCRDerivate derivate = MCRSwordUtil.createDerivate(objectID.toString());
            final MCRPath path = MCRPath.getPath(derivate.getId().toString(), "/");
            if (entry.getPackaging() != null && entry.getPackaging().equals(UriRegistry.PACKAGE_SIMPLE_ZIP)) {
                try {
                    MCRSwordUtil.extractZipToPath(entry.getInputStream(), path);
                } catch (NoSuchAlgorithmException | URISyntaxException e) {
                    throw new SwordServerException("Error while extracting ZIP!", e);
                }
            }
        } catch (IOException e) {
            throw new SwordServerException("Error while creating new derivate for object " + objectID.toString(), e);
        }

        return objectID;
    }

    @Override
    public void ingestResource(MCRObject object, Deposit entry) throws SwordServerException, SwordError {
        final MCRObjectID objectID = object.getId();
        try {
            final MCRDerivate derivate = MCRSwordUtil.createDerivate(objectID.toString());
            final MCRPath path = MCRPath.getPath(derivate.getId().toString(), "/");
            if (entry.getPackaging() != null && entry.getPackaging().equals(UriRegistry.PACKAGE_SIMPLE_ZIP)) {
                MCRSwordUtil.extractZipToPath(entry.getInputStream(), path);
            }
        } catch (IOException | URISyntaxException | NoSuchAlgorithmException e) {
            throw new SwordServerException("Error while creating new derivate for object " + objectID.toString(), e);
        }
    }

    @Override
    public void updateMetadata(MCRObject object, Deposit entry, boolean replace) throws SwordServerException, SwordError {
        if (!replace) {
            throw new SwordServerException("Operation is not supported!", new OperationNotSupportedException());
        }
        final Document document = buildDCDocument(entry.getSwordEntry().getDublinCore());
        final Document newMetadata = convertDCToMods(document);
        object.getMetadata().setFromDOM(newMetadata.detachRootElement());
        try {
            MCRMetadataManager.update(object);
        } catch (MCRActiveLinkException e) {
            throw new SwordServerException("Error while updating object!", e);
        }
    }

    @Override
    public void updateMetadataResources(MCRObject object, Deposit entry) throws SwordServerException {
        throw new SwordServerException("Operation is not supported!", new OperationNotSupportedException());
    }

    @Override
    public void init(MCRSwordLifecycleConfiguration lifecycleConfiguration) {
        this.lifecycleConfiguration = lifecycleConfiguration;
    }

    @Override
    public void destroy() {

    }
}