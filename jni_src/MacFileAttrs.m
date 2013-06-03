#import <CoreFoundation/CoreFoundation.h>#import <JavaNativeFoundation/JavaNativeFoundation.h>#import "MacFileAttrs.h"#import <sys/xattr.h>   NSString * const CREATOR = @"creator";   NSString * const TYPE = @"type";   NSString * const COLOR = @"label";   NSString * const INVISIBLE = @"invisible";   NSString * const NAME_LOCKED = @"name_locked";   NSString * const STATIONERY = @"stationery";   NSString * const ALIAS = @"alias";   NSString * const CUSTOM_ICON = @"custom_icon";   NSString * const LOCKED = @"locked";   static JNF_CLASS_CACHE(jc_MacFinderInfo, "us/hall/trz/osx/MacFinderInfo");   static JNF_CLASS_CACHE(jc_MacLSInfo, "us/hall/trz/osx/MacLSInfo");   static JNF_CLASS_CACHE(jc_MacCocoaInfo, "us/hall/trz/osx/MacCocoaInfo");   static JNF_CLASS_CACHE(jc_MacXAttrInfo, "us/hall/trz/osx/MacXAttrInfo");   static JNF_CLASS_CACHE(jc_Boolean, "java/lang/Boolean");   static JNF_CLASS_CACHE(jc_Integer, "java/lang/Integer");   static JNF_CLASS_CACHE(jc_Long, "java/lang/Long");   static JNF_CLASS_CACHE(jc_String, "java/lang/String");   static JNF_CLASS_CACHE(jc_HashMap, "java/util/HashMap");   static JNF_MEMBER_CACHE(jm_valueI,jc_Integer,"value","I");   static JNF_MEMBER_CACHE(jm_longValue,jc_Long,"longValue","()J");   static JNF_CLASS_CACHE(jc_Short,"java/lang/Short");   static JNF_MEMBER_CACHE(jm_valueS,jc_Short,"value","S");   static JNF_CLASS_CACHE(jc_IOException,"java/io/IOException");   static JNF_CTOR_CACHE(jm_MacFinderInfo_ctor, jc_MacFinderInfo, "()V");   static JNF_CTOR_CACHE(jm_MacLSInfo_ctor, jc_MacLSInfo, "()V");   static JNF_CTOR_CACHE(jm_MacCocoaInfo_ctor,jc_MacCocoaInfo, "()V");   static JNF_CTOR_CACHE(jm_MacXAttrInfo_ctor,jc_MacXAttrInfo, "()V");   static JNF_CTOR_CACHE(jm_HashMap_ctor,jc_HashMap,"()V");   static JNF_CTOR_CACHE(jm_Boolean_ctor,jc_Boolean,"(Z)V");   static JNF_MEMBER_CACHE(jm_setCreator, jc_MacFinderInfo, "setCreator","(I)V");   static JNF_MEMBER_CACHE(jm_setType, jc_MacFinderInfo, "setType","(I)V");   static JNF_MEMBER_CACHE(jm_setLSCreator, jc_MacLSInfo, "setCreator","(I)V");   static JNF_MEMBER_CACHE(jm_setLSType, jc_MacLSInfo, "setType","(I)V");   static JNF_MEMBER_CACHE(jm_setLSFlags, jc_MacLSInfo, "setFlags","(I)V");   static JNF_MEMBER_CACHE(jm_setAppDefault, jc_MacLSInfo, "setAppDefault","(Ljava/lang/String;)V");   static JNF_MEMBER_CACHE(jm_setApplications, jc_MacLSInfo, "setApplications","([Ljava/lang/Object;)V");    static JNF_MEMBER_CACHE(jm_setKind, jc_MacLSInfo, "setKind","(Ljava/lang/String;)V");   static JNF_MEMBER_CACHE(jm_setFinderFlags, jc_MacFinderInfo, "setFinderFlags","(S)V");   static JNF_MEMBER_CACHE(jm_setNodeFlags, jc_MacFinderInfo, "setNodeFlags","(S)V");   static JNF_MEMBER_CACHE(jm_setLabel, jc_MacFinderInfo, "setLabel","(S)V");    static JNF_MEMBER_CACHE(jm_setXAttrMap, jc_MacXAttrInfo, "setXAttrMap","(Ljava/util/Map;)V");   static JNF_MEMBER_CACHE(jm_setMap, jc_MacCocoaInfo, "setMap","(Ljava/util/Map;)V");   static JNF_MEMBER_CACHE(jm_put, jc_HashMap, "put","(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");/******************************************************************************* * *******************************************************************************/ JNIEXPORT void JNICALL Java_us_hall_trz_osx_MacAttrUtils_setFinderInfo(JNIEnv *env, jclass clazz, jstring jfilePath, jstring jattribute, jobject jvalue) {	JNF_COCOA_ENTER(env);	char tempstr[1024];	const char* filePath;	filePath = JNFGetStringUTF8Chars(env, jfilePath);    NSString *attribute = JNFJavaToNSString(env, jattribute);	FSCatalogInfo catalogInfo;	FSRef ref;	OSErr err;	int whichInfo;	err = FSPathMakeRef((const UInt8 *)filePath, &ref, NULL);	if (err == noErr) {	   if ([attribute isEqualToString: LOCKED]) {	      whichInfo = kFSCatInfoNodeFlags;	      err = FSGetCatalogInfo(&ref, kFSCatInfoNodeFlags, &catalogInfo, NULL, NULL, NULL);	   }	   else {	      whichInfo = kFSCatInfoFinderInfo;	      err = FSGetCatalogInfo(&ref, kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);	   }	   if (err != noErr) {	      sprintf(tempstr,"Error accessing %s = %d",filePath,err);	      (*env)->ThrowNew(env,jc_IOException.cls,tempstr);	   }	   else {	      if ([attribute isEqualToString:CREATOR] || [attribute isEqualToString:TYPE]) {                 if(JNFIsInstanceOf(env,jvalue,&jc_Integer)) {                    OSType ostype = (OSType)JNFGetIntField(env,jvalue,jm_valueI);                    if ([attribute isEqualToString: CREATOR])              	       ((FileInfo*)catalogInfo.finderInfo)->fileCreator = ostype;                    else                        ((FileInfo*)catalogInfo.finderInfo)->fileType = ostype;              	 }                 else {                    sprintf(tempstr,"Error accessing %s. Setting creator with non-Integer argument",filePath);                    (*env)->ThrowNew(env,jc_IOException.cls,tempstr);                 }              }              else if ([attribute isEqualToString:COLOR]) {                 if (JNFIsInstanceOf(env,jvalue,&jc_Short)) {                    int label = JNFGetShortField(env,jvalue,jm_valueS);                    ((FileInfo*)catalogInfo.finderInfo)->finderFlags &= ~kColor;                    ((FileInfo*)catalogInfo.finderInfo)->finderFlags |= (label << 1) & kColor;              	 }              	 else {              	    sprintf(tempstr,"Error accessing %s. Setting label color with non-short argument",filePath);              	    (*env)->ThrowNew(env,jc_IOException.cls,tempstr);              	 }              	                  }              else if (JNFIsInstanceOf(env,jvalue,&jc_Boolean)) {              	 if ([attribute isEqualToString: INVISIBLE]) {              	    if (jvalue)	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags |= kIsInvisible;	            else 	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags & ~kIsInvisible;	         }	         else if ([attribute isEqualToString: NAME_LOCKED]) {	            if (jvalue)	      	       ((FileInfo*)catalogInfo.finderInfo)->finderFlags |= kNameLocked;	            else 	    	       ((FileInfo*)catalogInfo.finderInfo)->finderFlags & ~kNameLocked;	      	 }	         else if ([attribute isEqualToString: STATIONERY]) {	            if (jvalue)	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags |= kIsStationery;	            else	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags & ~kIsStationery;	         }	         else if ([attribute isEqualToString: ALIAS]) {	            if (jvalue)	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags |= kIsAlias;	            else 	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags & ~kIsAlias;	         }	         else if ([attribute isEqualToString: CUSTOM_ICON]) {	            if (jvalue)	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags |= kHasCustomIcon;	            else	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags & ~kHasCustomIcon;	         }	         else if ([attribute isEqualToString: LOCKED]) {	            if (jvalue)	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags |= kFSNodeLockedMask;	            else 	               ((FileInfo*)catalogInfo.finderInfo)->finderFlags & ~kFSNodeLockedMask;	         }	      }	   }	   err = FSSetCatalogInfo( &ref, whichInfo, &catalogInfo );	}	else {	   sprintf(tempstr,"Error accessing %s = %d",filePath,err);	   (*env)->ThrowNew(env,jc_IOException.cls,tempstr);			}	JNF_COCOA_EXIT(env);} JNIEXPORT jobject JNICALL Java_us_hall_trz_osx_MacAttrUtils_getFinderInfo(JNIEnv *env, jclass clazz,jstring jfilePath){	jint rc = 0;	jobject info;	JNF_COCOA_ENTER(env);	const char* filePath;	filePath = JNFGetStringUTF8Chars(env, jfilePath);	FSCatalogInfo catalogInfo;	FSRef ref;	OSErr err = FSPathMakeRef((const UInt8 *)filePath, &ref, NULL);	if (err != 0) return 0;	rc = (jint)FSGetCatalogInfo(&ref, kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);	if (rc == 0) {	   FileInfo* fInfo = (FileInfo*) catalogInfo.finderInfo;		   info = JNFNewObject(env, jm_MacFinderInfo_ctor);	   jint ostype;	   ostype = (int)fInfo->fileCreator;	   JNFCallVoidMethod(env, info, jm_setCreator, ostype);    	   ostype = (int)fInfo->fileType;	   JNFCallVoidMethod(env, info, jm_setType, ostype);    	   jshort flags;	   flags = fInfo->finderFlags;	   JNFCallVoidMethod(env, info, jm_setFinderFlags, flags);	   jshort label = (fInfo->finderFlags & kColor) >> 1;	   JNFCallVoidMethod(env, info, jm_setLabel, label);	   rc = (jint)FSGetCatalogInfo(&ref, kFSCatInfoNodeFlags, &catalogInfo, NULL, NULL, NULL);	   if (rc == 0) {	      flags = catalogInfo.nodeFlags;	      JNFCallVoidMethod(env, info, jm_setNodeFlags, flags);	   }	}	JNFReleaseStringUTF8Chars(env, jfilePath, filePath);	JNF_COCOA_EXIT(env);	if (rc != 0) return 0;	return info;}JNIEXPORT jobject JNICALL Java_us_hall_trz_osx_MacAttrUtils_getLSInfo(JNIEnv *env, jclass clazz, jstring jfilePath) {	FSRef ref,outAppRef;	OSErr err;	jobject info;	NSString *appPath = nil;    CFStringRef kindString;	char tempstr[1024];	    JNF_COCOA_ENTER(env);	const char* filePath;	filePath = JNFGetStringUTF8Chars(env,jfilePath);	err = FSPathMakeRef((const UInt8 *)filePath, &ref, NULL);    if (err != noErr) { 	   sprintf(tempstr,"Error accessing %s = %d",filePath,err);//	   (*env)->ThrowNew(env,jc_IOException.cls,tempstr);		       	        return 0;    } 	info = JNFNewObject(env, jm_MacLSInfo_ctor);    LSItemInfoRecord itemInfo;    int request = kLSRequestExtension + kLSRequestTypeCreator + kLSRequestBasicFlagsOnly;    err = LSCopyItemInfoForRef(&ref, request, &itemInfo);    if (err != noErr) return 0; 	jint ostype;	ostype = (int)itemInfo.creator;	JNFCallVoidMethod(env, info, jm_setLSCreator, ostype);    	ostype = (int)itemInfo.filetype;	JNFCallVoidMethod(env, info, jm_setLSType, ostype);    	jint flags;	flags = itemInfo.flags;	JNFCallVoidMethod(env, info, jm_setLSFlags, flags);	err = LSGetApplicationForItem(&ref, kLSRolesAll, &outAppRef, NULL);	if (err == noErr) {    	CFURLRef appUrl = CFURLCreateFromFSRef(kCFAllocatorDefault, &outAppRef);        if (appUrl != NULL)        {        	NSArray * apps;            jobjectArray japps;            appPath = (NSString*) CFURLCopyFileSystemPath(appUrl, kCFURLPOSIXPathStyle);            JNFCallVoidMethod(env, info, jm_setAppDefault, JNFNormalizedJavaStringForPath(env,appPath));            apps = (NSArray *)LSCopyApplicationURLsForURL(appUrl,kLSRolesAll);            CFRelease(appUrl);            japps = JNFNewObjectArray(env,&jc_String,(jsize)[apps count]);            int i=0;            jstring japp;            NSString * app;            for (;i<[apps count]; i++) {            	app = [[apps objectAtIndex: i] path];            	japp = JNFNormalizedJavaStringForPath(env,app);            	(*env)->SetObjectArrayElement(env, japps, i, japp);            }            [apps autorelease];            JNFCallVoidMethod(env, info, jm_setApplications, japps);        }    }    err = LSCopyKindStringForRef(&ref,&kindString);    if (err == noErr) {    	JNFCallVoidMethod(env, info, jm_setKind, JNFNSToJavaString(env,(NSString*)kindString));        CFRelease(kindString);    }	JNF_COCOA_EXIT(env);    if (err != noErr) return 0;    return info;}JNIEXPORT jobject JNICALL Java_us_hall_trz_osx_MacAttrUtils_getMimeType(JNIEnv *env, jclass clazz, jstring jfilePath) {	jobject jmimeType;    JNF_COCOA_ENTER(env);	NSString * file = [JNFNormalizedNSStringForPath(env,jfilePath) stringByResolvingSymlinksInPath];	CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[file pathExtension], NULL);	CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);	CFRelease(UTI);	jmimeType = JNFNSToJavaString(env,(NSString*)MIMEType);	CFRelease(MIMEType);	JNF_COCOA_EXIT(env);	return jmimeType;	}JNIEXPORT jobject JNICALL Java_us_hall_trz_osx_MacAttrUtils_getCocoaInfo(JNIEnv *env, jclass clazz, jstring jfilePath) {	jobject info;	jobject map;    JNF_COCOA_ENTER(env);    info = JNFNewObject(env, jm_MacCocoaInfo_ctor);	map = JNFNewObject(env, jm_HashMap_ctor);	NSString * file = [JNFNormalizedNSStringForPath(env,jfilePath) stringByResolvingSymlinksInPath];	NSDictionary *fileAttributes;	fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:NULL];		jboolean boolAttribute = [fileAttributes fileIsAppendOnly] ? JNI_TRUE : JNI_FALSE;	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileAppendOnly),							JNFNewObject(env,jm_Boolean_ctor,boolAttribute));	boolAttribute = [fileAttributes objectForKey:NSFileBusy] ? JNI_TRUE : JNI_FALSE;	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileBusy),							JNFNewObject(env,jm_Boolean_ctor,boolAttribute));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileModificationDate),							JNFNSToJavaCalendar(env,[fileAttributes fileModificationDate]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileReferenceCount),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileReferenceCount]));	boolAttribute = [fileAttributes fileExtensionHidden] ? JNI_TRUE : JNI_FALSE;	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileExtensionHidden),							JNFNewObject(env,jm_Boolean_ctor,boolAttribute));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileSize),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileSize]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileOwnerAccountName),							JNFNSToJavaString(env,[fileAttributes fileOwnerAccountName]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileGroupOwnerAccountName),							JNFNSToJavaString(env,[fileAttributes fileGroupOwnerAccountName]));		JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFilePosixPermissions),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFilePosixPermissions]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileSystemNumber),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileSystemNumber]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileSystemFileNumber),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileSystemFileNumber]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileHFSCreatorCode),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileHFSCreatorCode]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileHFSTypeCode),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileHFSTypeCode]));	boolAttribute = [fileAttributes fileIsImmutable] ? JNI_TRUE : JNI_FALSE;	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileImmutable),							JNFNewObject(env,jm_Boolean_ctor,boolAttribute));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileCreationDate),							JNFNSToJavaCalendar(env,[fileAttributes objectForKey:NSFileCreationDate]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileOwnerAccountID),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileOwnerAccountID]));	JNFCallObjectMethod(env,map,jm_put,JNFNSToJavaString(env,NSFileGroupOwnerAccountID),							JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileGroupOwnerAccountID]));	JNFCallVoidMethod(env,info,jm_setMap,map);	JNF_COCOA_EXIT(env);	return info;}JNIEXPORT jboolean JNICALL Java_us_hall_trz_osx_MacAttrUtils_isDirectory(JNIEnv *env, jclass clazz, jstring jfilePath) {	BOOL isDir;	NSString * path;    jboolean result;    JNF_COCOA_ENTER(env);	path = JNFNormalizedNSStringForPath(env,jfilePath);	result = JNI_FALSE; 	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)		result = JNI_TRUE;	JNF_COCOA_EXIT(env);	return  result;}	JNIEXPORT void JNICALL Java_us_hall_trz_osx_MacAttrUtils_fileSystemNumbers(JNIEnv *env, jclass clazz, jstring jfilePath,jlongArray jnums) {	NSString * path;    JNF_COCOA_ENTER(env);    jlong buf[2];    (*env)->GetLongArrayRegion(env, jnums, 0, 2, buf);	NSString * file = [JNFNormalizedNSStringForPath(env,jfilePath) stringByResolvingSymlinksInPath];		NSDictionary *fileAttributes;	fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:NULL];		buf[0] = JNFCallLongMethod(env,JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileSystemNumber]),jm_longValue);	buf[1] = JNFCallLongMethod(env,JNFNSToJavaNumber(env,[fileAttributes objectForKey:NSFileSystemFileNumber]),jm_longValue);	(*env)->SetLongArrayRegion(env,jnums,0,2,buf);	JNF_COCOA_EXIT(env);}JNIEXPORT jobject JNICALL Java_us_hall_trz_osx_MacAttrUtils_getXAttrInfo(JNIEnv *env, jclass clazz, jstring jfilePath, jboolean followLink) {	jobject info;	jobject map;    JNF_COCOA_ENTER(env);	const char* filePath;	filePath = JNFGetStringUTF8Chars(env,jfilePath);	size_t namesSize = listxattr( filePath,								NULL, ULONG_MAX,								(followLink ? 0 : XATTR_NOFOLLOW) );	if (namesSize == ULONG_MAX) return 0;	info = JNFNewObject(env, jm_MacXAttrInfo_ctor);	map = JNFNewObject(env, jm_HashMap_ctor);	NSMutableData*	listBuffer = [NSMutableData dataWithLength: namesSize];	namesSize = listxattr( filePath,							[listBuffer mutableBytes], [listBuffer length],							(followLink ? 0 : XATTR_NOFOLLOW) );	char*	nameStart = [listBuffer mutableBytes];	int x;	for( x = 0; x < namesSize; x++ )	{		if( ((char*)[listBuffer mutableBytes])[x] == 0 )	// End of string.		{			jstring name = (*env)->NewStringUTF(env,nameStart);			size_t		dataSize = getxattr( filePath, nameStart,										NULL, ULONG_MAX, 0, (followLink ? 0 : XATTR_NOFOLLOW) );			if( dataSize != ULONG_MAX ) {				NSMutableData*	data = [NSMutableData dataWithLength: dataSize];				getxattr( filePath, nameStart,					[data mutableBytes], [data length], 0, (followLink ? 0 : XATTR_NOFOLLOW) );				jbyteArray attribute = JNFNewByteArray(env,dataSize);				(*env)->SetByteArrayRegion(env,attribute,0,dataSize,[data mutableBytes]);				JNFCallObjectMethod(env,map,jm_put,name,attribute);			}			else NSLog(@"getxattr for size failed");			nameStart = [listBuffer mutableBytes] +x +1;		}	}		JNFCallVoidMethod(env,info,jm_setXAttrMap,map);	JNF_COCOA_EXIT(env);	return info;}