package no.oranheim.macos.watchservice.osx;import static no.oranheim.macos.watchservice.osx.Finder.*;public class MacFinderInfo {    /* Finder flags (finderFlags, fdFlags and frFlags) *//* Any flag reserved or not specified should be set to 0. *//* If a flag applies to a file, but not to a folder, make sure to check *//* that the item is not a folder by checking ((ParamBlockRec.ioFlAttrib & ioDirMask) == 0) */    @SuppressWarnings("unused")    private static final int kIsOnDesk = 0x0001, /* Files and folders (System 6) */            kColor = 0x000E, /* Files and folders */    /* bit 0x0020 was kRequireSwitchLaunch, but is now reserved for future use*/    kIsShared = 0x0040, /* Files only (Applications only) */    /* If clear, the application needs to write to */                                               /* its resource fork, and therefore cannot be */                                               /* shared on a server */    kHasNoINITs = 0x0080, /* Files only (Extensions/Control Panels only) */    /* This file contains no INIT resource */    kHasBeenInited = 0x0100, /* Files only */    /* Clear if the file contains desktop database */                                               /* resources ('BNDL', 'FREF', 'open', 'kind'...) */                                               /* that have not been added yet. Set only by the Finder */                                               /* Reserved for folders - make sure this bit is cleared for folders */                                               /* bit 0x0200 was the letter bit for AOCE, but is now reserved for future use */    kHasCustomIcon = 0x0400, /* Files and folders */            kIsStationery = 0x0800, /* Files only */            kNameLocked = 0x1000, /* Files and folders */            kHasBundle = 0x2000, /* Files only */            kIsInvisible = 0x4000, /* Files and folders */            kIsAlias = 0x8000; /* Files only */    /*  Constants for nodeFlags field of FSCatalogInfo */    private static final int kFSNodeLockedMask = 0x0001,            kFSNodeIsDirectoryMask = 0x0010;    private static final LabelColor gray = new LabelColor(207, 207, 207, "gray"),            purple = new LabelColor(229, 188, 236, "purple"),            blue = new LabelColor(160, 212, 255, "blue"),            green = new LabelColor(206, 238, 152, "green"),            yellow = new LabelColor(251, 245, 151, "yellow"),            orange = new LabelColor(255, 206, 145, "orange"),            red = new LabelColor(255, 156, 156, "red"),            defaultColor = new LabelColor(0, 0, 0, "default");    private int creator, type;    private short flags, nodeFlags, label;    @SuppressWarnings("unused")    private void setCreator(int creator) {        this.creator = creator;    }    public String getCreator() {        byte[] b = new byte[4];        pokeInt(b, 0, creator);        try {            return new String(b, "UTF-8");        } catch (java.io.UnsupportedEncodingException uee) {            uee.printStackTrace();        }        return null;    }    @SuppressWarnings("unused")    private void setType(int type) {        this.type = type;    }    public String getType() {        byte[] b = new byte[4];        pokeInt(b, 0, type);        try {            return new String(b, "UTF-8");        } catch (java.io.UnsupportedEncodingException uee) {            uee.printStackTrace();        }        return null;    }    @SuppressWarnings("unused")    private void setFinderFlags(short flags) {        this.flags = flags;    }    public boolean isInvisible() {        return (flags & kIsInvisible) != 0;    }    public boolean isNameLocked() {        return (flags & kNameLocked) != 0;    }    public boolean isStationery() {        return (flags & kIsStationery) != 0;    }    public boolean isAlias() {        return (flags & kIsAlias) != 0;    }    public boolean isCustomIcon() {        return (flags & kHasCustomIcon) != 0;    }    @SuppressWarnings("unused")    private void setNodeFlags(short nodeFlags) {        this.nodeFlags = nodeFlags;    }    public boolean isLocked() {        return (nodeFlags & kFSNodeLockedMask) != 0;    }    public boolean isDir() {        return (nodeFlags & kFSNodeIsDirectoryMask) != 0;    }    @SuppressWarnings("unused")    private void setLabel(short label) {        this.label = label;    }    public LabelColor getLabelColor() {        switch (label) {            case 1:                return gray;            case 3:                return purple;            case 4:                return blue;            case 2:                return green;            case 5:                return yellow;            case 7:                return orange;            case 6:                return red;            default:                return defaultColor;        }    }    public Object getAttribute(String attr) {        if (attr.equals(CREATOR)) return getCreator();        if (attr.equals(TYPE)) return getType();        if (attr.equals(INVISIBLE)) return isInvisible();        if (attr.equals(NAME_LOCKED)) return isNameLocked();        if (attr.equals(STATIONERY)) return isStationery();        if (attr.equals(ALIAS)) return isAlias();        if (attr.equals(CUSTOM_ICON)) return isCustomIcon();        if (attr.equals(LOCKED)) return isLocked();        if (attr.equals(LABEL)) return getLabelColor();        return null;    }    private final void pokeInt(byte[] a, int index, int i) {        a[index] = (byte) (i >> 24);        a[index + 1] = (byte) (i >> 16);        a[index + 2] = (byte) (i >> 8);        a[index + 3] = (byte) (i);    }}